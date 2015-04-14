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
    private var entries: ThreadSafe<[JournalEntry]>
    private let fileManagerQueue: dispatch_queue_t
    private let entriesQueue: dispatch_queue_t
    
    var cacheSize: Int64 {
        get {
            var size: Int64 = 0
            for entry in entries.value {
                size += Int64(entry.size)
            }
            return size
        }
    }
    
    init(absolutePath: String) {
        self.path = absolutePath
        self.entries = ThreadSafe(Array<JournalEntry>())
        self.fileManagerQueue = dispatch_queue_create("\(self.path)FileManagerQueue", nil)
        self.entriesQueue = dispatch_queue_create("\(self.path)EntriesQueue", nil)
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
            self.entries.value.append(newEntry)
        })
        self.persistJournal()
    }
    
    func updateEntry(key: String) -> Void {
        dispatch_sync(self.entriesQueue, { () -> Void in
            for entry in self.entries.value {
                if key == entry.key {
                    entry.timestamp = Int(NSDate.timeIntervalSinceReferenceDate())
                    break
                }
            }
        })
        self.persistJournal()
    }
    
    func getLRUSizesAndTimestamps(sizeInBytes: Int64) -> Slice<(UInt64,Int)> {
        var entriesSlice: Slice<(UInt64,Int)>!
        
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.sort({ $0.timestamp < $1.timestamp })
            
            var count: Int64 = 0
            var upperLimit: Int = 0

            if (self.entries.value.count > 1) {
                for entry in self.entries.value {
                    if count >= sizeInBytes {
                        break
                    }
                    count += Int64(entry.size)
                    ++upperLimit
                }
            }
            
            if (upperLimit <= 0) {
                entriesSlice = Slice<(UInt64,Int)>()
            } else {
                entriesSlice = self.entries.value[0..<upperLimit].map { ($0.size, $0.timestamp) }
            }
        })
        return entriesSlice
    }
    
    func getLRUEntries(count: Int) -> Slice<String> {
        if (count <= 0) {
            return Slice<String>()
        }
        
        var entriesSlice: Slice<String>!
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.sort({ $0.timestamp < $1.timestamp })

            if (count <= self.entries.value.count) {
                entriesSlice = self.entries.value[0..<count].map { $0.key }
            } else {
                println("Failed to get all LRU entries from cache journal, expected \(count), found \(self.entries.value.count)")
                entriesSlice = Slice<String>()
            }
        })
        
        return entriesSlice
    }
    
    func removeLRUEntries(count: Int) -> Void {
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.removeRange(0..<count)
        })
        self.persistJournal()
    }
    
    func getEntries() -> [String] {
        var paths: [String] = [String]()
        dispatch_sync(self.entriesQueue, { () -> Void in
            paths = self.entries.value.map { $0.key }
        })
        return paths
    }
    
    func clear() -> Void {
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.removeAll(keepCapacity: false)
        })
        self.persistJournal()
    }
    
    private func readEntries() {
        if !self.entries.value.isEmpty {
            self.entries.value.removeAll(keepCapacity: false)
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
                entries.value.append(entry)
            }
        }
    }
    
    private func persistJournal() -> Void {
        dispatch_async(self.fileManagerQueue, { () -> Void in
            let newContent = "".join(self.entries.value.map { $0.toString(self.SEP, eol: self.EOL) })
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