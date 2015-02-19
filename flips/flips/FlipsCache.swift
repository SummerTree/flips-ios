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

import Foundation

public class FlipsCache {
    
    let storageCache: StorageCache
    
    public class var sharedInstance : FlipsCache {
        struct Static {
            static let instance : FlipsCache = FlipsCache()
        }
        return Static.instance
    }
    
    init() {
        self.storageCache = StorageCache(cacheDirectoryName: "user_flips", sizeLimitInBytes: 500000000) //500MB
    }
    
    func get(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback, failure: StorageCache.CacheFailureCallback) -> StorageCache.CacheGetResponse {
        return self.storageCache.get(remoteURL, success: success, failure: failure)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> Void {
        self.storageCache.put(remoteURL, localPath: localPath)
    }
    
}