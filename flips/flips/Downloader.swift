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

private typealias DownloadFinished = (NSError?) -> Void
typealias DownloadFinishedCompletion = (error: NSError?) -> Void

let DOWNLOAD_FINISHED_NOTIFICATION_NAME: String = "download_finished_notification"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: String = "download_finished_notification_param_flip_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY: String = "download_finished_notification_param_message_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY: String = "download_finished_notification_param_fail_key"

public class Downloader : NSObject {
    
    let TIME_OUT_INTERVAL: NSTimeInterval = 60 //seconds
    let downloadQueue =  dispatch_queue_create("download flip queue", nil)
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

            if (error != nil) {
                println("Could not download data from URL: \(url.absoluteString!) ERROR: \(error)")
                completion(success: false);
            } else {
                completion(success: true);
            }
        }
        
        downloadTask.resume()
    }
    
    // MARK: - New Download Method, used by StorageCache
    
    func downloadTask(url: NSURL, localURL:NSURL, completion:((success: Bool) -> Void)) {
        let absoluteString = url.absoluteString!
        if self.downloadInProgressURLs.containsObject(absoluteString) {
            return
        }
        
        downloadInProgressURLs.addObject(absoluteString)
        
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = TIME_OUT_INTERVAL
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFURLSessionManager(sessionConfiguration: configuration)
        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil, destination: { (targetPath, response) -> NSURL! in
            return localURL
            }) { (response, filePath, error) -> Void in
                self.downloadInProgressURLs.removeObject(absoluteString)
                
                if (error != nil) {
                    println("Could not download data from URL: \(absoluteString) ERROR: \(error)")
                    completion(success: false);
                } else {
                    completion(success: true);
                }
        }
        
        downloadTask.resume()
    }
    
    
    // MARK: - Validation Methods
    
    private func isValidURL(url: String?) -> Bool {
        return ((url != nil) && (url != ""))
    }
}
