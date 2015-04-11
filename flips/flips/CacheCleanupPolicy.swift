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


public class CacheCleanupPolicy {
    
    private struct Constants {
        static let KILOBYTE: Int64 = 1024
        static let MEGABYTE: Int64 = 1024*KILOBYTE
        static let CACHE_SIZE_LIMIT_IN_BYTES = 500*MEGABYTE
        static let STORAGE_MINIMUM_FREE_SIZE_IN_BYTES = 50*MEGABYTE
    }
    
    private var caches = [StorageCache]()
    private let cleanupQueue: dispatch_queue_t = dispatch_queue_create("CacheCleanupPolicy", nil)

    public class var sharedInstance: CacheCleanupPolicy {
        struct Static {
            static let instance: CacheCleanupPolicy = CacheCleanupPolicy()
        }
        return Static.instance
    }
    
    func register(cache: StorageCache) -> Void {
        self.caches.append(cache)
    }
    
    func scheduleCleanup() -> Void {
        dispatch_async(self.cleanupQueue, { () -> Void in
            let freeSize = self.freeSizeInBytes()
            if (freeSize >= 0) {
                return
            }
            
            var sizeToRemove = -freeSize
            var entryCount = 0
            
            var sizesAndTimestampsArray = [Slice<(UInt64,Int)>]()
            for i in 0..<self.caches.count {
                let sizesAndTimestamps = self.caches[i].getLRUSizesAndTimestamps(sizeToRemove)
                entryCount += sizesAndTimestamps.count
                sizesAndTimestampsArray.append(sizesAndTimestamps)
            }
            
            var entryCountToRemove = [Int](count: self.caches.count, repeatedValue: 0)
            
            while (sizeToRemove > 0 && entryCount > 0) {
                var minTimestamp: Int = Int.max
                var minIndex = 0
                for i in 0..<sizesAndTimestampsArray.count {
                    if (sizesAndTimestampsArray[i][0].1 < minTimestamp) {
                        minTimestamp = sizesAndTimestampsArray[i][0].1
                        minIndex = i
                    }
                }
                ++entryCountToRemove[minIndex]
                sizeToRemove -= Int64(sizesAndTimestampsArray[minIndex][0].0)
                sizesAndTimestampsArray[minIndex].removeAtIndex(0)
                --entryCount
            }
            
            for i in 0..<self.caches.count {
                self.caches[i].removeLRUEntries(entryCountToRemove[i])
            }
        })
    }
    
    private func freeSizeInBytes() -> Int64 {
        let deviceFreeSpace = self.deviceFreeSpaceInBytes() - Constants.STORAGE_MINIMUM_FREE_SIZE_IN_BYTES
        
        var cachesSize: Int64 = 0
        for cache in self.caches {
            cachesSize += cache.sizeInBytes
        }
        
        let cacheFreeSpace = Constants.CACHE_SIZE_LIMIT_IN_BYTES - cachesSize
        return min(cacheFreeSpace, deviceFreeSpace)
    }
    
    private func deviceFreeSpaceInBytes() -> Int64 {
        var freeSpace: Int64 = 0
        var error: NSError?
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        if let attributes = NSFileManager.defaultManager().attributesOfFileSystemForPath(paths.last as String, error: &error) {
            if let freeFileSystemSizeInBytes = attributes[NSFileSystemFreeSize] as? NSNumber {
                return freeFileSystemSizeInBytes.longLongValue
            }
        }
        
        println("Error getting file system memory info. Domain: \(error?.domain), code: \(error?.code)")
        return Int64.max
    }
    
}
