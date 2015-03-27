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


public class ThumbnailsCache {
    
    let cache: StorageCache
    
    public class var sharedInstance : ThumbnailsCache {
        struct Static {
            static let instance : ThumbnailsCache = ThumbnailsCache()
        }
        return Static.instance
    }
    
    init() {
        self.cache = StorageCache(cacheID: "thumbnailsCache", cacheDirectoryName: "thumbnails_cache", freeSizeInBytes: { CacheCleanupPolicy.sharedInstance.freeSizeInBytes() })
        CacheCleanupPolicy.sharedInstance.register(self.cache)
    }
    
    func get(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?) -> StorageCache.CacheGetResponse {
        if (remoteURL.path == nil || remoteURL.path! == "") {
            return StorageCache.CacheGetResponse.INVALID_URL
        }
        
        return self.cache.get(remoteURL, success: success, failure: failure)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.cache.put(remoteURL, localPath: localPath)
    }
    
    func put(remoteURL: NSURL, data: NSData) -> Void {
        self.cache.put(remoteURL, data: data)
    }
    
    func has(remoteURL: NSURL) -> Bool {
        return self.cache.has(remoteURL)
    }
}
