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

@objc public class StorageCache {

    public typealias CacheSuccessCallback = (String!) -> Void
    public typealias CacheFailureCallback = (FlipError) -> Void
    
    public enum CacheGetResponse {
        case DATA_IS_READY
        case DOWNLOAD_WILL_START
    }
    
    private let cacheDirectoryPath: NSURL
    private let sizeLimitInBytes: UInt64
    private let cacheJournal: CacheJournal
    
    init(cacheDirectoryName: String, sizeLimitInBytes: UInt64) {
        self.sizeLimitInBytes = sizeLimitInBytes
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        let applicationSupportDirPath = paths.first! as String
        let applicationSupportDirAbsolutePath = NSHomeDirectory().stringByAppendingPathComponent(applicationSupportDirPath)
        let cacheDirectoryAbsolutePath = applicationSupportDirAbsolutePath.stringByAppendingPathComponent(cacheDirectoryName)
        self.cacheDirectoryPath = NSURL(fileURLWithPath: cacheDirectoryAbsolutePath)!
        let journalName = self.cacheDirectoryPath.path!.stringByAppendingPathComponent("\(cacheDirectoryName).cache")
        self.cacheJournal = CacheJournal(absolutePath: journalName)
        self.initCacheDirectory()
        self.cacheJournal.open()
    }
    
    private func initCacheDirectory() {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = true
        
        var error: NSError? = nil
        
        if (fileManager.fileExistsAtPath(cacheDirectoryPath.path!, isDirectory: &isDirectory)) {
            println("Directory exists: \(cacheDirectoryPath)")
        } else {
            fileManager.createDirectoryAtPath(cacheDirectoryPath.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
            if (error != nil) {
                println("Error creating cache dir: \(error)")
            } else {
                println("Directory '\(cacheDirectoryPath)' created!")
            }
        }
        
        cacheDirectoryPath.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey, error: &error)
        if (error != nil) {
            println("Error excluding cache dir from backup: \(error)")
        }
    }
    
    /**
    Asynchronously retrieves an asset. Whenever it's available, the success function is called.
    If the asset is not in the cache by the time this function is called, it's downloaded and
    inserted in the cache before its local path is passed to the success function. If some error occurs
    (e.g. not in cache and no internet connection), the failure function is called with some
    error description.
    
    :param: remoteURL The URL from which the asset will be downloaded if a cache miss has occurred. This path also uniquely identifies the asset.
    :param: success   A function that is called when the asset is successfully available.
    :param: failure   A function that is called when the asset could not be retrieved.
    */
    func get(remoteURL: NSURL, success: CacheSuccessCallback?, failure: CacheFailureCallback?) -> CacheGetResponse {
        let localPath = self.createLocalPath(remoteURL)
        if (self.cacheHit(localPath)) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                success?(localPath)
                return
            }
            self.cacheJournal.updateEntry(localPath)
            return CacheGetResponse.DATA_IS_READY
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            Downloader.sharedInstance.downloadTask(remoteURL,
                localURL: NSURL(fileURLWithPath: localPath)!,
                completion: { (result) -> Void in
                    self.cacheJournal.insertNewEntry(localPath)
                    self.scheduleCleanup()
                    if (result) {
                        success?(localPath)
                    } else {
                        failure?(FlipError(error: "Error downloading media file", details: nil))
                    }
                }
            )
        }
        return CacheGetResponse.DOWNLOAD_WILL_START
    }
    
    /**
    Inserts the data into the cache, identified by its path. This operation is synchronous.
    
    :param: remoteURL The path from which the asset will be downloaded if a cache miss has occurred. This path also uniquely identifies the asset.
    :param: srcPath   The path where the asset is locally saved. The asset will be moved to the cache.
    */
    func put(remoteURL: NSURL, localPath srcPath: String) -> Void {
        let toPath = self.createLocalPath(remoteURL)
        
        let fileManager = NSFileManager.defaultManager()

        if (!self.cacheHit(toPath)) {
            var error: NSError? = nil
            fileManager.moveItemAtPath(srcPath, toPath: toPath, error: &error)
            if (error != nil) {
                println("Error move asset to the cache dir: \(error)")
            }
            self.cacheJournal.insertNewEntry(toPath)
            self.scheduleCleanup()
        }
    }
    
    private func createLocalPath(remoteURL: NSURL) -> String {
        //I think the best approach here would be to generate a Hash based on the actual data,
        //but for now we're just using the last path component.
        return cacheDirectoryPath.path!.stringByAppendingPathComponent(remoteURL.path!.lastPathComponent)
    }
    
    private func cacheHit(localPath: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(localPath)
    }
    
    private func scheduleCleanup() -> Void {
        return;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let cacheOverflow = self.cacheJournal.cacheSize - self.sizeLimitInBytes
            if (cacheOverflow <= 0) {
                return
            }
            
            let leastRecentlyUsed = self.cacheJournal.getLRUEntriesForSize(cacheOverflow)
            let fileManager = NSFileManager.defaultManager()
            for path in leastRecentlyUsed {
                var error: NSError? = nil
                if (!fileManager.removeItemAtPath(path, error: &error)) {
                    println("Could not remove file \(path). Error: \(error)")
                }
            }
            self.cacheJournal.removeLRUEntries(leastRecentlyUsed.count)
        }
    }
    
}