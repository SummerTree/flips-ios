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

let DOWNLOAD_FINISHED_NOTIFICATION_NAME: String = "download_finished_notification"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: String = "download_finished_notification_param_flip_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY: String = "download_finished_notification_param_message_key"
let DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY: String = "download_finished_notification_param_fail_key"

public class Downloader : NSObject {
    
    let TIME_OUT_INTERVAL: NSTimeInterval = 60 //seconds
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : Downloader {
    struct Static {
        static let instance : Downloader = Downloader()
        }
        return Static.instance
    }
    
    // MARK: - Download Public Methods

    func downloadTask(url: NSURL, localURL: NSURL, completion: ((success: Bool) -> Void), progress: ((Float) -> Void)? = nil) {
        let request = NSMutableURLRequest(URL: url)
        request.timeoutInterval = TIME_OUT_INTERVAL

        let tempFileName = "\(NSDate().timeIntervalSince1970)_\(localURL.path!.lastPathComponent)"
        let tempPath = NSTemporaryDirectory().stringByAppendingPathComponent(tempFileName)
        let tempURL = NSURL(fileURLWithPath: tempPath)!
        
        let operation = AFHTTPRequestOperation(request: request)
        operation.outputStream = NSOutputStream(URL: tempURL, append: false)

        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            var error: NSError? = nil
            let fileManager = NSFileManager.defaultManager()
            fileManager.moveItemAtURL(tempURL, toURL: localURL, error: &error)
            if let err = error {
                println("Error moving item to path \(localURL.path!), error \(err)")
            }
            completion(success: true)
        }, failure: { (operation, error) -> Void in
            println("Could not download data from URL: \(url.absoluteString!) ERROR: \(error)")
            let fileManager = NSFileManager.defaultManager()
            var err: NSError? = nil
            fileManager.removeItemAtURL(tempURL, error: &err)
            if let e = err {
                println("Error removing invalid file \(tempURL), error \(e)")
            }
            completion(success: false)
        })

        if (progress != nil) {
            operation.setDownloadProgressBlock { (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
                progress?(Float(totalBytesRead) / Float(totalBytesExpectedToRead))
                return
            }
        }

        operation.start()
    }
    
}
