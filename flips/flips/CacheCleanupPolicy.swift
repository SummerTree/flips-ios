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
    
    let KILOBYTE: Int64 = 1024
    let MEGABYTE: Int64 = 1024*1024
    
    let caches: NSHashTable = NSHashTable.weakObjectsHashTable()
    private let sizeLimitInBytes: Int64
    
    public class var sharedInstance: CacheCleanupPolicy {
        struct Static {
            static let instance: CacheCleanupPolicy = CacheCleanupPolicy()
        }
        return Static.instance
    }
    
    init() {
        self.sizeLimitInBytes = 500*MEGABYTE
    }
    
    func register(cache: StorageCache) -> Void {
        caches.addObject(cache)
    }
    
    func freeSizeInBytes() -> Int64 {
        let deviceFreeSpace = self.deviceFreeSpaceInBytes() - 50*MEGABYTE
        
        var cachesSize: Int64 = 0
        let enumerator = self.caches.objectEnumerator()
        var cache: AnyObject? = enumerator.nextObject()
        while (cache != nil) {
            if let actualCache = cache as? StorageCache {
                cachesSize += actualCache.sizeInBytes
            }
            cache = enumerator.nextObject()
        }
        
        let cacheFreeSpace = self.sizeLimitInBytes - cachesSize
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
