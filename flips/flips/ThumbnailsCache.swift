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


public class ThumbnailsCache {
    
    let cache: StorageCache
    
    public class var sharedInstance : ThumbnailsCache {
        struct Static {
            static let instance : ThumbnailsCache = ThumbnailsCache()
        }
        return Static.instance
    }
    
    init() {
        self.cache = StorageCache(cacheID: "thumbnailsCache", cacheDirectoryName: "thumbnails_cache", sizeLimitInBytes: 5000000) //5MB
    }
    
    func get(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?) -> StorageCache.CacheGetResponse {
        return self.cache.get(remoteURL, success: success, failure: failure)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.cache.put(remoteURL, localPath: localPath)
    }
    
}