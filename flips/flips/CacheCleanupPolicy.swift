/// Swift Migrator:
///
/// This file contains one or more places using either an index
/// or a range with ArraySlice. While in Swift 1.2 ArraySlice
/// indices were 0-based, in Swift 2.0 they changed to match the
/// the indices of the original array.
///
/// The Migrator wrapped the places it found in a call to the
/// following function, please review all call sites and fix
/// incides if necessary.
@available(*, deprecated=2.0, message="Swift 2.0 migration: Review possible 0-based index")
private func __reviewIndex__<T>(value: T) -> T {
    return value
}

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
            
            var sizesAndTimestampsArray = [ArraySlice<(UInt64,Int)>]()
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
                    if (sizesAndTimestampsArray[i].count > 0 && sizesAndTimestampsArray[i][__reviewIndex__(0)].1 < minTimestamp) {
                        minTimestamp = sizesAndTimestampsArray[i][__reviewIndex__(0)].1
                        minIndex = i
                    }
                }
                entryCountToRemove[minIndex] += 1
                sizeToRemove -= Int64(sizesAndTimestampsArray[minIndex][__reviewIndex__(0)].0)
                sizesAndTimestampsArray[minIndex].removeAtIndex(__reviewIndex__(0))
                entryCount -= 1
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
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        do {
            let attributes = try NSFileManager.defaultManager().attributesOfFileSystemForPath(paths.last!)
            if let freeFileSystemSizeInBytes = attributes[NSFileSystemFreeSize] as? NSNumber {
                return freeFileSystemSizeInBytes.longLongValue
            }
        } catch let error1 as NSError {
            error = error1
        }
        
        print("Error getting file system memory info. Domain: \(error?.domain), code: \(error?.code)")
        return Int64.max
    }
    
}
