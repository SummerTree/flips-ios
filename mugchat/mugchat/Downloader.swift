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

public typealias MugDownloadFinished = (Mug, NSError?) -> Void
private typealias DownloadFinished = (BackgroundContentType, NSError?) -> Void

let DOWNLOAD_FINISHED_NOTIFICATION_NAME: String = "download_finished_notification"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY: String = "download_finished_notification_param_mug_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY: String = "download_finished_notification_param_fail_key"

public class Downloader : NSObject {
    
    let TIME_OUT_INTERVAL: NSTimeInterval = 60 //secconds
    
    private var downloadInProgressURLs: NSHashTable!
    
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : Downloader {
    struct Static {
        static let instance : Downloader = Downloader()
        }
        return Static.instance
    }
    
    
    // MARK: - Initalization
    
    override init() {
        super.init()
        downloadInProgressURLs = NSHashTable()
    }

    
    // MARK: - Download Private Method
    
    private func downloadDataAndCacheForUrl(urlString: String, withCompletion completion: DownloadFinished, isTemporary: Bool = true) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFURLSessionManager(sessionConfiguration: configuration)
        
        self.downloadInProgressURLs.addObject(urlString)
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.timeoutInterval = self.TIME_OUT_INTERVAL
        
        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil, destination: { (targetPath, response) -> NSURL! in
            let path = CacheHandler.sharedInstance.getFilePathForUrl(urlString, isTemporary: isTemporary)
            return NSURL(fileURLWithPath: path)
            }) { (response, filePath, error) -> Void in
                self.downloadInProgressURLs.removeObject(urlString)
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if let contentType = httpResponse.allHeaderFields["Content-Type"] as? NSString {
                        completion(self.backgroundTypeForContentType(contentType), error)
                    }
                } else {
                    completion(self.backgroundTypeForContentType(""), error)
                }
        }
        
        downloadTask.resume()
    }
    
    
    // MARK: - Download Public Methods

    func downloadDataFromURL(url: NSURL, localURL:NSURL, completion:((success: Bool) -> Void)) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFURLSessionManager(sessionConfiguration: configuration)

        downloadInProgressURLs.addObject(url.absoluteString!)

        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = TIME_OUT_INTERVAL

        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil, destination: { (targetPath, response) -> NSURL! in
            return localURL
        }) { (response, filePath, error) -> Void in
            self.downloadInProgressURLs.removeObject(url.absoluteString!)

            let httpResponse = response as? NSHTTPURLResponse

            if (error != nil) {
                println("Could not download data from URL: \(url.absoluteString!) ERROR: \(error)")
                completion(success: false);
            } else {
                completion(success: true);
            }
        }
        
        downloadTask.resume()
    }

    func downloadDataForMug(mug: Mug, isTemporary: Bool = true) {
        dispatch_async(dispatch_queue_create("download mug queue", nil), { () -> Void in
            var group = dispatch_group_create()
            
            var downloadError: NSError?
            if (self.isValidURL(mug.backgroundURL) && (!self.downloadInProgressURLs.containsObject(mug.backgroundURL))) {
                if (!CacheHandler.sharedInstance.hasCachedFileForUrl(mug.backgroundURL).hasCache) {
                    dispatch_group_enter(group)
                    self.downloadDataAndCacheForUrl(mug.backgroundURL, withCompletion: { (backgroundContentType, error) -> Void in
                        mug.setBackgroundContentType(backgroundContentType)
                        downloadError = error
                        dispatch_group_leave(group);
                        }, isTemporary: isTemporary)
                }
            }
            
            if (self.isValidURL(mug.soundURL) && (!self.downloadInProgressURLs.containsObject(mug.soundURL))) {
                if (!CacheHandler.sharedInstance.hasCachedFileForUrl(mug.soundURL).hasCache) {
                    dispatch_group_enter(group)
                    self.downloadDataAndCacheForUrl(mug.soundURL, withCompletion: { (backgroundContentType, error) -> Void in
                        downloadError = error
                        dispatch_group_leave(group);
                        }, isTemporary: isTemporary)
                }
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            self.sendDownloadFinishedBroadcastForMug(mug, error: downloadError)
        })
    }
    
    private func sendDownloadFinishedBroadcastForMug(mug: Mug, error: NSError?) {
        if (error != nil) {
            println("Error download mug content: \(error)")
        }
        
        var userInfo: Dictionary<String, AnyObject> = [DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY: mug]
        
        var downloadFailed: Bool = (error != nil)
        if (downloadFailed) {
            userInfo.updateValue(downloadFailed, forKey: DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY)
        }
    
        NSNotificationCenter.defaultCenter().postNotificationName(DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil, userInfo: userInfo)
    }
    
    
    // MARK: - Helper Methods
    
    private func backgroundTypeForContentType(contentType: String) -> BackgroundContentType {
        if (contentType.hasPrefix("image")) {
            return BackgroundContentType.Image
        } else if (contentType.hasPrefix("video")) {
            return BackgroundContentType.Video
        }

        return BackgroundContentType.Undefined
    }
    
    // MARK: - Validation Methods
    
    private func isValidURL(url: String?) -> Bool {
        return ((url != nil) && (url != ""))
    }
}
