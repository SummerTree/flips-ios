//
// Copyright 2015 ArcTouch, Inc.
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
        var size: Int64 = 0
        for entry in entries.value {
            size += Int64(entry.size)
        }
        return size
    }
    
    init(absolutePath: String) {
        self.path = absolutePath
        self.entries = ThreadSafe(Array<JournalEntry>())
        self.fileManagerQueue = dispatch_queue_create("\(self.path)FileManagerQueue", DISPATCH_QUEUE_SERIAL)
        self.entriesQueue = dispatch_queue_create("\(self.path)EntriesQueue", DISPATCH_QUEUE_SERIAL)
    }
    
    func open() {
        if NSFileManager.defaultManager().fileExistsAtPath(self.path) {
            dispatch_async(self.fileManagerQueue, { () -> Void in
                self.readEntries()
            })
        }
    }
    
    func insertNewEntry(key: String) -> Void {
        let attributes = try? NSFileManager.defaultManager().attributesOfItemAtPath(key)
        if (attributes == nil) {
            print("Can't get file (\(key)) attributes, not inserting into cache.")
            return
        }
        let entrySize = (attributes! as NSDictionary).fileSize()
        let entryTimestamp = Int(NSDate.timeIntervalSinceReferenceDate())
        if let keyPath = NSURL(string: key)?.lastPathComponent
        {
            let newEntry = JournalEntry(key: keyPath, size: entrySize, timestamp: entryTimestamp)
            
            dispatch_sync(self.entriesQueue, { () -> Void in
                self.entries.value.append(newEntry)
            })
            
            self.persistJournal()
        }
    }
    
    func updateEntry(key: String) -> Void {
        
        if let keyPath = NSURL(string: key)?.lastPathComponent {
        
            dispatch_sync(self.entriesQueue, { () -> Void in
                
                for entry in self.entries.value {
                    if keyPath == entry.key {
                        entry.timestamp = Int(NSDate.timeIntervalSinceReferenceDate())
                        break
                    }
                }
                
            })
            
            self.persistJournal()
            
        }
        
    }
    
    func getLRUSizesAndTimestamps(sizeInBytes: Int64) -> ArraySlice<(UInt64,Int)> {
        var entriesSlice: ArraySlice<(UInt64,Int)>!
        
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.sortInPlace({ $0.timestamp < $1.timestamp })
            
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
                entriesSlice = ArraySlice<(UInt64,Int)>()
            } else {
                entriesSlice = Array(self.entries.value[0..<upperLimit].map { ($0.size, $0.timestamp) })
            }
        })
        return entriesSlice
    }
    
    func getLRUEntries(count: Int) -> ArraySlice<String> {
        if (count <= 0) {
            return ArraySlice<String>()
        }
        
        var entriesSlice: ArraySlice<String>!
        dispatch_sync(self.entriesQueue, { () -> Void in
            self.entries.value.sortInPlace({ $0.timestamp < $1.timestamp })

            if (count <= self.entries.value.count) {
                entriesSlice = ArraySlice<String>(self.entries.value[0..<count].map { $0.key })
            } else {
                print("Failed to get all LRU entries from cache journal, expected \(count), found \(self.entries.value.count)")
                entriesSlice = ArraySlice<String>()
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
        let fileContent: String?
        do {
            fileContent = try String(contentsOfFile: self.path, encoding: NSUTF8StringEncoding)
        } catch let error1 as NSError {
            error = error1
            fileContent = nil
        }
        
        if let actualError = error {
            print("\(actualError.localizedDescription)")
            return
        }
        
        let actualFileContent = fileContent!
        let lines = actualFileContent.characters.split {$0 == self.EOL}.map { String($0) }
        for line in lines {
            let fields = line.characters.split {$0 == self.SEP}.map { String($0) }
            if fields.count == 3 {
                let key: String = fields[0]
                let size: UInt64 = UInt64(Int((fields[1] as String))!)
                let timestamp: Int = Int((fields[2] as String))!
                let entry = JournalEntry(key: key, size: size, timestamp: timestamp)
                entries.value.append(entry)
            }
        }
    }
    
    private func persistJournal() -> Void {
        dispatch_async(self.fileManagerQueue, { () -> Void in
            let newContent = self.entries.value.map { $0.toString(self.SEP, eol: self.EOL) }.joinWithSeparator("")
            if let outputStream = NSOutputStream(toFileAtPath: self.path, append: false) {
                outputStream.open()
                outputStream.write(newContent, maxLength: newContent.characters.count)
                outputStream.close()
            } else {
                print("Failed to persist cache journal to file \(self.path)")
            }
        })
    }
    
}