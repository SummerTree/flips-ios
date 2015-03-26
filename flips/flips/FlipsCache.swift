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
    
    let loggedUserStorageCache: StorageCache
    let otherUsersStorageCache: StorageCache
    
    public class var sharedInstance : FlipsCache {
        struct Static {
            static let instance : FlipsCache = FlipsCache()
        }
        return Static.instance
    }
    
    init() {
        self.loggedUserStorageCache = StorageCache(cacheID: "loggedUserStorageCache", cacheDirectoryName: "flips_cache", sizeLimitInBytes: 5000000) //5MB
        self.otherUsersStorageCache = StorageCache(cacheID: "otherUsersStorageCache", cacheDirectoryName: "flips_cache", sizeLimitInBytes: 5000000) //5MB
    }
    
    func videoForFlip(flip: Flip, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?, progress: StorageCache.CacheProgressCallback?) -> StorageCache.CacheGetResponse {
        if (flip.backgroundURL == nil || flip.backgroundURL == "") {
            return StorageCache.CacheGetResponse.INVALID_URL
        }
        
        if let loggedUser = User.loggedUser() {
            if (flip.owner != nil && flip.owner.userID == loggedUser.userID) {
                return self.loggedUserStorageCache.get(NSURL(string: flip.backgroundURL)!, success: success, failure: failure, progress: progress)
            }
        }
        
        return self.otherUsersStorageCache.get(NSURL(string: flip.backgroundURL)!, success: success, failure: failure, progress: progress)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.loggedUserStorageCache.put(remoteURL, localPath: localPath)
    }
    
}
