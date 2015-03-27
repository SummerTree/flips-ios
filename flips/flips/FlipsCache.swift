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


public class FlipsCache {
    
    let cache: StorageCache
    
    public class var sharedInstance : FlipsCache {
        struct Static {
            static let instance : FlipsCache = FlipsCache()
        }
        return Static.instance
    }
    
    init() {
        self.cache = StorageCache(cacheID: "allFlipsStorageCache", cacheDirectoryName: "flips_cache", freeSizeInBytes: CacheCleanupPolicy.sharedInstance.freeSizeInBytes)
        CacheCleanupPolicy.sharedInstance.register(self.cache)
    }
    
    func videoForFlip(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?, progress: StorageCache.CacheProgressCallback?) -> StorageCache.CacheGetResponse {
        if (remoteURL.path == nil || remoteURL.path! == "") {
            return StorageCache.CacheGetResponse.INVALID_URL
        }
        
        return self.cache.get(remoteURL, success: success, failure: failure, progress: progress)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.cache.put(remoteURL, localPath: localPath)
    }
    
    func clear() -> Void {
        self.cache.clear()
    }
    
}
