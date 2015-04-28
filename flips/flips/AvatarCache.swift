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


public class AvatarCache {
    
    let cache: StorageCache
    
    public class var sharedInstance : AvatarCache {
        struct Static {
            static let instance : AvatarCache = AvatarCache()
        }
        return Static.instance
    }
    
    init() {
        self.cache = StorageCache(cacheID: "avatarCache", cacheDirectoryName: "avatar_cache", scheduleCleanup: CacheCleanupPolicy.sharedInstance.scheduleCleanup)
        CacheCleanupPolicy.sharedInstance.register(self.cache)
    }
    
    func get(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?) -> StorageCache.CacheGetResponse {
        if (remoteURL.path == nil || remoteURL.path! == "") {
            return StorageCache.CacheGetResponse.INVALID_URL
        }
        
        return self.cache.get(remoteURL, success: success, failure: failure, progress: nil)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.cache.put(remoteURL, localPath: localPath)
    }
    
    func clear() -> Void {
        self.cache.clear()
    }
    
}
