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

public typealias CacheSuccessCallback = (AnyObject?) -> Void
public typealias CacheFailureCallback = (FlipError?) -> Void

public class StorageCache {

    init() {
        
    }
    
    /**
    Asynchronously retrieves an asset. Whenever it's available, the success function is called.
    If the asset is not in the cache by the time this function is called, it's downloaded and
    inserted in the cache before it's passed to the success function. If some error occurs
    (e.g. not in cache and no internet connection), the failure function is called with some
    error description.
    
    :param: path    The path from which the asset will be downloaded if a cache miss has occurred.
    :param: success A function that is called when the asset is successfully available.
    :param: failure A function that is called when the asset could not be retrieved.
    */
    func get(path: String, success: CacheSuccessCallback, failure: CacheFailureCallback) -> Void {
        //if cache hit {
        //success(asset)
        //return
        
        //if cache miss {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //download asset
            dispatch_async(dispatch_get_main_queue()) {
                //success(asset)
            }
        }
    }
    
}