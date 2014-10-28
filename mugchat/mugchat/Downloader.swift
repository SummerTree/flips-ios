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
private typealias DownloadFinished = (NSError?) -> Void

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
        Static.instance.initDownloader()
        return Static.instance
    }
    
    
    // MARK: - Initalization
    
    private func initDownloader() {
        downloadInProgressURLs = NSHashTable()
    }

    
    // MARK: - Download Private Method
    
    private func downloadDataAndCacheForUrl(urlString: String, withCompletion completion: DownloadFinished, isTemporary: Bool = true) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFURLSessionManager(sessionConfiguration: configuration)

        downloadInProgressURLs.addObject(urlString)
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = TIME_OUT_INTERVAL
        
        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil, destination: { (url, urlResponse) -> NSURL! in
            let path = CacheHandler.sharedInstance.getFilePathForUrl(url.absoluteString!, isTemporary: isTemporary)
            return NSURL(string: path)
        }) { (urlResponse, url, error) -> Void in
            self.downloadInProgressURLs.removeObject(urlString)
            
            println("url: \(url)")
            println("urlResponse: \(urlResponse)")
            completion(error)
        }
        
        downloadTask.resume()
    }
    
    
    // MARK: - Download Public Methods
    
    func downloadDataForMug(mug: Mug, isTemporary: Bool = true) {
        if (self.isValidURL(mug.backgroundURL) && (!downloadInProgressURLs.containsObject(mug.backgroundURL))) {
            if (!CacheHandler.sharedInstance.hasCachedFileForUrl(mug.backgroundURL)) {
                self.downloadDataAndCacheForUrl(mug.backgroundURL, withCompletion: { (error) -> Void in
                    self.sendDownloadFinishedBroadcastForMug(mug, error: error)
                }, isTemporary: isTemporary)
            } else {
                self.sendDownloadFinishedBroadcastForMug(mug, error: nil)
            }
        }
        
        if (self.isValidURL(mug.soundURL) && (!downloadInProgressURLs.containsObject(mug.soundURL))) {
            if (!CacheHandler.sharedInstance.hasCachedFileForUrl(mug.soundURL)) {
                self.downloadDataAndCacheForUrl(mug.soundURL, withCompletion: { (error) -> Void in
                    self.sendDownloadFinishedBroadcastForMug(mug, error: error)
                }, isTemporary: isTemporary)
            } else {
                self.sendDownloadFinishedBroadcastForMug(mug, error: nil)
            }
        }
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
    
    
    // MARK: - Validation Methods
    
    private func isValidURL(url: String) -> Bool {
        return !url.isEmpty
    }
}
