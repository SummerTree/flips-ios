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

public typealias StockFlipsSuccessResponse = (JSON?) -> Void
public typealias StockFlipsFailureResponse = (FlipError?) -> Void
public typealias UploadFlipSuccessResponse = (JSON) -> Void
public typealias UploadFlipFailureResponse = (FlipError?) -> Void
private typealias UploadSuccessResponse = (NSURL!) -> Void
private typealias UploadFailureResponse = (FlipError?) -> Void

public class FlipService: FlipsService {
    
    private let UPLOAD_BACKGROUND_RESPONSE_URL = "background_url"
    private let UPLOAD_THUMBNAIL_RESPONSE_URL = "thumbnail_url"
    
    private let CREATE_FLIP: String = "/user/{{user_id}}/flips"
    private let UPLOAD_BACKGROUND: String = "/background"
    private let UPLOAD_THUMBNAIL: String = "/thumbnail"
    private let STOCK_FLIPS: String = "/flips/stock"
    
    let IMAGE_COMPRESSION: CGFloat = 0.3
    
    private struct RequestParams {
        static let WORD = "word"
        static let BACKGROUND_URL = "background_url"
        static let THUMBNAIL_URL = "thumbnail_url"
        static let SOUND_URL = "sound_url"
        static let CATEGORY = "category"
        static let IS_PRIVATE = "is_private"
        static let TIMESTAMP = "timestamp"
    }
    
    func createFlip(word: String, videoURL: NSURL?, thumbnailURL: NSURL?, category: String = "", isPrivate: Bool = true, uploadFlipSuccessCallback: UploadFlipSuccessResponse, uploadFlipFailCallBack: UploadFlipFailureResponse) {
        
        var uploadFlipBlock: ((NSURL?, NSURL?) -> Void) = { (remoteVideoURL, remoteThumbnailURL) -> () in
            self.uploadNewFlip(word, videoURL: remoteVideoURL, thumbnailURL: remoteThumbnailURL, category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: uploadFlipSuccessCallback, uploadFlipFailCallBack: uploadFlipFailCallBack)
        }
        
        if (videoURL == nil && thumbnailURL == nil) {
            uploadFlipBlock(nil, nil)
            return
        }
        
        self.uploadVideo(videoURL!, successCallback: { (remoteVideoURL) -> Void in
            self.uploadThumbnail(thumbnailURL!, successCallback: { (remoteThumbnailURL) -> Void in
                uploadFlipBlock(remoteVideoURL, remoteThumbnailURL)
            }, failCallback: { (flipError) -> Void in
                uploadFlipFailCallBack(flipError)
            })
        }) { (flipError) -> Void in
            uploadFlipFailCallBack(flipError)
        }
    }
    
    func stockFlips(timestamp: NSDate?, success: StockFlipsSuccessResponse, failure: StockFlipsFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let stockFlipUrl = HOST + STOCK_FLIPS
        var stockFlipParams = [
            RequestParams.TIMESTAMP: (timestamp == nil ? "" : timestamp!)
        ]
        
        self.get(stockFlipUrl,
            parameters: stockFlipParams,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(JSON(responseObject))
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    failure(FlipError(error: response["error"] as! String!, details: nil))
                } else {
                    failure(FlipError(error: error.localizedDescription, details: nil))
                }
            }
        )
    }
    
    private func uploadVideo(videoPathUrl: NSURL, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        var error: NSError?

        let videoData: NSData? = NSData(contentsOfURL: videoPathUrl, options: NSDataReadingOptions.allZeros, error: &error)
        if (videoData != nil) {
            println("Uploading a video with size = \(videoData?.length)")
            
            let url = HOST + UPLOAD_BACKGROUND
            let fileName = "video_\(NSDate().timeIntervalSince1970).mov"
            self.uploadData(videoData!, toUrl: url, withFileName: fileName, partName: "background", mimeType: "video/quicktime", successCallback: successCallback, failCallback: failCallback)
        } else {
            failCallback(FlipError(error: NSLocalizedString("Video file not found. Please try again.", comment: "Video file not found. Please try again."), details:nil))
        }
    }
    
    private func uploadThumbnail(imageURL: NSURL, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        var error: NSError?
        let imageData = NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.allZeros, error: &error)
        
        let url = HOST + UPLOAD_THUMBNAIL
        let fileName = imageURL.lastPathComponent

        self.uploadData(imageData!, toUrl: url, withFileName: fileName!, partName: "thumbnail", mimeType: "image/png", successCallback: successCallback, failCallback: failCallback)
    }
    
    private func uploadData(data: NSData, toUrl url: String, withFileName fileName: String, partName: String, mimeType: String, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failCallback(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        self.post(url,
            parameters: nil,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(data, name: partName, fileName: fileName, mimeType: mimeType)
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var url = self.parseUploadResponse(responseObject)
                if (url == nil) {
                    failCallback(FlipError(error: LocalizedString.ERROR, details: LocalizedString.COULD_NOT_UPLOAD_FLIP))
                } else {
                    successCallback(NSURL(string: url!))
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    failCallback(FlipError(error: response["error"] as! String!, details: nil))
                } else {
                    failCallback(FlipError(error: error.localizedDescription, details: nil))
                }
            }
        )
    }
    
    private func uploadNewFlip(word: String, videoURL: NSURL?, thumbnailURL: NSURL?, category: String, isPrivate: Bool, uploadFlipSuccessCallback: UploadFlipSuccessResponse, uploadFlipFailCallBack: UploadFlipFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            uploadFlipFailCallBack(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let createURL = CREATE_FLIP.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let createFlipUrl = HOST + createURL
            let createFlipParams = [
                RequestParams.WORD: word,
                RequestParams.BACKGROUND_URL: (videoURL == nil ? "" : videoURL!.absoluteString!),
                RequestParams.THUMBNAIL_URL: (thumbnailURL == nil ? "" : thumbnailURL!.absoluteString!),
                RequestParams.CATEGORY: category,
                RequestParams.IS_PRIVATE: isPrivate]
            
            self.post(createFlipUrl,
                parameters: createFlipParams,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    uploadFlipSuccessCallback(JSON(responseObject))
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        uploadFlipFailCallBack(FlipError(error: response["error"]as! String!, details: nil))
                    } else {
                        uploadFlipFailCallBack(FlipError(error: error.localizedDescription, details:nil))
                    }
                }
            )
        }
    }
    
    
    // MARK: - Response Parser
    
    private func parseUploadResponse(response: AnyObject) -> String? {
        let json = JSON(response)
        
        if (json.dictionary?.indexForKey(UPLOAD_BACKGROUND_RESPONSE_URL) != nil) {
            return json[UPLOAD_BACKGROUND_RESPONSE_URL].stringValue
        } else if (json.dictionary?.indexForKey(UPLOAD_THUMBNAIL_RESPONSE_URL) != nil) {
            return json[UPLOAD_THUMBNAIL_RESPONSE_URL].stringValue
        }
        
        println("FlipService Upload Parser error - response didn't return a valid value.")
        
        return nil
    }
}