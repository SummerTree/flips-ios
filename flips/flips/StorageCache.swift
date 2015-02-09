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

public enum CacheGetResponse {
    case DATA_IS_READY
    case DOWNLOAD_WILL_START
}

public class StorageCache {

    public typealias CacheSuccessCallback = (String!) -> Void
    public typealias CacheFailureCallback = (FlipError) -> Void
    
    private var cacheDirectoryPath: String
    
    init(cacheDirectoryName: String) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        let applicationSupportDirPath = paths.first! as String
        cacheDirectoryPath = "\(NSHomeDirectory())\(applicationSupportDirPath)/\(cacheDirectoryName)"
        self.initCacheDirectory()
    }
    
    private func initCacheDirectory() {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = true
        
        if (fileManager.fileExistsAtPath(cacheDirectoryPath, isDirectory: &isDirectory)) {
            println("Directory exists: \(cacheDirectoryPath)")
        } else {
            var error: NSError?
            fileManager.createDirectoryAtPath(cacheDirectoryPath, withIntermediateDirectories: true, attributes: nil, error: &error)
            if (error != nil) {
                println("Error creating cache dir: \(error)")
            } else {
                println("Directory '\(cacheDirectoryPath)' created!")
            }
        }
    }
    
    /**
    Asynchronously retrieves an asset. Whenever it's available, the success function is called.
    If the asset is not in the cache by the time this function is called, it's downloaded and
    inserted in the cache before its local path is passed to the success function. If some error occurs
    (e.g. not in cache and no internet connection), the failure function is called with some
    error description.
    
    :param: path    The path from which the asset will be downloaded if a cache miss has occurred. This path also uniquely identifies the asset.
    :param: success A function that is called when the asset is successfully available.
    :param: failure A function that is called when the asset could not be retrieved.
    */
    func get(path: String, success: CacheSuccessCallback, failure: CacheFailureCallback) -> CacheGetResponse {
        let localPath = self.createLocalPath(path)
        if self.cacheHit(localPath) {
            dispatch_async(dispatch_get_main_queue()) {
                success(localPath)
            }
            return CacheGetResponse.DATA_IS_READY
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Downloader.sharedInstance.downloadTask(NSURL(fileURLWithPath: path)!,
                localURL: NSURL(fileURLWithPath: localPath)!,
                completion: { (result) -> Void in
                    if (result) {
                        success(localPath)
                    } else {
                        failure(FlipError(error: "Error downloading media file", details: nil))
                    }
                }
            )
            dispatch_async(dispatch_get_main_queue()) {
                success(localPath)
            }
        }
        return CacheGetResponse.DOWNLOAD_WILL_START
    }
    
    /**
    Inserts the data into the cache, identified by its path. This operation is synchronous.
    
    :param: path The path from which the asset will be downloaded if a cache miss has occurred. This path also uniquely identifies the asset.
    :param: data The asset that is to be inserted into the cache.
    */
    func put(path: String, data: NSData) -> Void {
        let localPath = self.createLocalPath(path)
        
        let fileManager = NSFileManager.defaultManager()

        //not overwriting
        if !self.cacheHit(localPath) {
            fileManager.createFileAtPath(localPath, contents: data, attributes: nil)
        }
    }
    
    private func createLocalPath(path: String) -> String {
        //I think the best approach here would be to generate a Hash based on the actual data,
        //but for now we're just using the last path component.
        return "\(cacheDirectoryPath)/\(path.lastPathComponent)"
    }
    
    private func cacheHit(localPath: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localPath)
    }
    
}