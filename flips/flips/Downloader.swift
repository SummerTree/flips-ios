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

public typealias DownloadFinishedCallback = ((success: Bool) -> Void)

let DOWNLOAD_FINISHED_NOTIFICATION_NAME: String = "download_finished_notification"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: String = "download_finished_notification_param_flip_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY: String = "download_finished_notification_param_message_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY: String = "download_finished_notification_param_fail_key"

public class Downloader : NSObject {
    
    let TIME_OUT_INTERVAL: NSTimeInterval = 60 //seconds
    private var downloadInProgressURLs: Dictionary<String, [DownloadFinishedCallback]>
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : Downloader {
    struct Static {
        static let instance : Downloader = Downloader()
        }
        return Static.instance
    }
    
    // MARK: - Initalization
    
    override init() {
        self.downloadInProgressURLs = Dictionary<String, [DownloadFinishedCallback]>()
        super.init()
    }
    
    // MARK: - Download Public Methods
    
    func downloadTask(url: NSURL, localURL: NSURL, completion: DownloadFinishedCallback) {
        var absoluteString = url.absoluteString!
    
        if (self.downloadInProgressURLs[absoluteString] == nil) {
            self.downloadInProgressURLs[absoluteString] = [DownloadFinishedCallback]()
        }
        
        self.downloadInProgressURLs[absoluteString]!.append(completion)
        
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = TIME_OUT_INTERVAL
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let manager = AFURLSessionManager(sessionConfiguration: configuration)
        var downloadTask = manager.downloadTaskWithRequest(request, progress: nil, destination: { (targetPath, response) -> NSURL! in
            return localURL
            }) { (response, filePath, error) -> Void in
                var success: Bool
                if (error != nil) {
                    println("Could not download data from URL: \(absoluteString) ERROR: \(error)")
                    success = false
                } else {
                    success = true
                }
                
                for callback in self.downloadInProgressURLs[absoluteString]! {
                    callback(success: success)
                }
                
                self.downloadInProgressURLs[absoluteString] = nil
        }
        
        downloadTask.resume()
    }
    
}
