//
// Copyright 2014 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

public class CacheJournal {
    
    let SEP: Character = "\t"
    let EOL: Character = "\n"
    
    private let path: String
    private var entries: [JournalEntry]
    private let fileManagerQueue: dispatch_queue_t
    private let entriesQueue: dispatch_queue_t
    
    var cacheSize: Int64 {
        get {
            var size: Int64 = 0
            for entry in entries {
                size += Int64(entry.size)
            }
            return size
        }
    }
    
    init(absolutePath: String) {
        self.path = absolutePath
        self.entries = [JournalEntry]()
        self.fileManagerQueue = dispatch_queue_create(self.path, nil)
        self.entriesQueue = dispatch_queue_create("entriesQueue", nil)
    }
    
    func open() {
        if NSFileManager.defaultManager().fileExistsAtPath(self.path) {
            dispatch_async(self.fileManagerQueue, { () -> Void in
                self.readEntries()
            })
        }
    }
    
    func insertNewEntry(key: String) -> Void {
        let attributes = NSFileManager.defaultManager().attributesOfItemAtPath(key, error: nil)
        if (attributes == nil) {
            println("Can't get file (\(key)) attributes, not inserting into cache.")
            return
        }
        let entrySize = (attributes! as NSDictionary).fileSize()
        let entryTimestamp = Int(NSDate.timeIntervalSinceReferenceDate())
        var newEntry = JournalEntry(key: key, size: entrySize, timestamp: entryTimestamp)
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.append(newEntry)
        })
        self.persistJournal()
    }
    
    func updateEntry(key: String) -> Void {
        dispatch_sync(self.entriesQueue, { () -> Void in
            for entry in self.entries {
                if key == entry.key {
                    entry.timestamp = Int(NSDate.timeIntervalSinceReferenceDate())
                    break
                }
            }
        })
        self.persistJournal()
    }
    
    func getLRUEntriesForSize(sizeInBytes: Int64) -> Slice<String> {
        var entriesSlice: Slice<String>!
        
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.sort({ $0.timestamp < $1.timestamp })
            
            var count: Int64 = 0
            var upperLimit: Int = 0
            for entry in self.entries {
                if count >= sizeInBytes {
                    break
                }
                count += Int64(entry.size)
                ++upperLimit
            }
            
            if upperLimit > 0 {
                entriesSlice = Slice<String>()
            } else {
                entriesSlice = self.entries[0..<upperLimit].map { $0.key }
            }
        })
        return entriesSlice
    }
    
    func removeLRUEntries(count: Int) -> Void {
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.removeRange(0..<count)
        })
        self.persistJournal()
    }
    
    private func readEntries() {
        if !self.entries.isEmpty {
            self.entries.removeAll(keepCapacity: false)
        }
        
        var error: NSError?
        let fileContent = String(contentsOfFile: self.path, encoding: NSUTF8StringEncoding, error: &error)
        
        if let actualError = error {
            println("\(actualError.localizedDescription)")
            return
        }
        
        let actualFileContent = fileContent!
        let lines = split(actualFileContent) {$0 == self.EOL}
        for line in lines {
            let fields = split(line) {$0 == self.SEP}
            if fields.count == 3 {
                let key: String = fields[0]
                let size: UInt64 = UInt64((fields[1] as String).toInt()!)
                let timestamp: Int = (fields[2] as String).toInt()!
                var entry = JournalEntry(key: key, size: size, timestamp: timestamp)
                entries.append(entry)
            }
        }
    }
    
    private func persistJournal() -> Void {
        dispatch_async(self.fileManagerQueue, { () -> Void in
            let newContent = "".join(self.entries.map { $0.toString(self.SEP, eol: self.EOL) })
            if let outputStream = NSOutputStream(toFileAtPath: self.path, append: false) {
                outputStream.open()
                outputStream.write(newContent, maxLength: countElements(newContent))
                outputStream.close()
            } else {
                println("Failed to persist cache journal to file \(self.path)")
            }
        })
    }
    
}