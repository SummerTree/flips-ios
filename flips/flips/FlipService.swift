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

public typealias StockFlipsSuccessResponse = (JSON?) -> Void
public typealias StockFlipsFailureResponse = (FlipError?) -> Void
public typealias UploadFlipSuccessResponse = (JSON) -> Void
public typealias UploadFlipFailureResponse = (FlipError?) -> Void
private typealias UploadSuccessResponse = (String?) -> Void
private typealias UploadFailureResponse = (FlipError?) -> Void


public class FlipService: FlipsService {
    
    private let UPLOAD_BACKGROUND_RESPONSE_URL = "background_url"
    private let UPLOAD_SOUND_RESPONSE_URL = "sound_url"
    
    private let CREATE_FLIP: String = "/user/{{user_id}}/flips"
    private let UPLOAD_BACKGROUND: String = "/background"
    private let UPLOAD_SOUND: String = "/sound"
    private let STOCK_FLIPS: String = "/flips/stock"
    
    let IMAGE_COMPRESSION: CGFloat = 0.3
    
    private struct RequestParams {
        static let WORD = "word"
        static let BACKGROUND_URL = "background_url"
        static let SOUND_URL = "sound_url"
        static let CATEGORY = "category"
        static let IS_PRIVATE = "is_private"
    }
    
    func createFlip(word: String, backgroundImage: UIImage?, soundPath: NSURL?, category: String = "", isPrivate: Bool = true, uploadFlipSuccessCallback: UploadFlipSuccessResponse, uploadFlipFailCallBack: UploadFlipFailureResponse) {
        
        var uploadFlipBlock: ((String, String) -> Void) = { (backgroundImageUrl, soundUrl) -> () in
            self.uploadNewFlip(word, backgroundUrl: backgroundImageUrl, soundUrl: soundUrl, category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: uploadFlipSuccessCallback, uploadFlipFailCallBack: uploadFlipFailCallBack)
        }
        
        var uploadSoundBlock: ((String) -> Void)? = nil
        if (soundPath != nil) {
            uploadSoundBlock = { (backgroundImageUrl) -> () in
                self.uploadSound(soundPath!, successCallback: { (soundUrl) -> Void in
                    uploadFlipBlock(backgroundImageUrl, soundUrl!)
                    }, failCallback: { (flipError) -> Void in
                        uploadFlipFailCallBack(flipError)
                })
            }
        }
        
        if (backgroundImage != nil) {
            self.uploadBackgroundImage(backgroundImage!, successCallback: { (imageUrl) -> Void in
                let backgroundImageUrl = imageUrl
                
                // upload audio if we have
                if (uploadSoundBlock != nil) {
                    uploadSoundBlock!(imageUrl!)
                } else {
                    uploadFlipBlock(backgroundImageUrl!, "")
                }
                }) { (flipError) -> Void in
                    uploadFlipFailCallBack(flipError)
            }
        } else if (uploadSoundBlock != nil) {
            uploadSoundBlock!("")
        } else {
            uploadFlipBlock("", "")
        }
    }
    
    func createFlip(word: String, videoPath: NSURL, category: String = "", isPrivate: Bool = true, uploadFlipSuccessCallback: UploadFlipSuccessResponse, uploadFlipFailCallBack: UploadFlipFailureResponse) {
        var uploadFlipBlock: ((String) -> Void) = { (videoURL) -> () in
            self.uploadNewFlip(word, backgroundUrl: videoURL, soundUrl: "", category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: uploadFlipSuccessCallback, uploadFlipFailCallBack: uploadFlipFailCallBack)
        }
        
        self.uploadVideo(videoPath, successCallback: { (videoUrl) -> Void in
            uploadFlipBlock(videoUrl!)
            }) { (flipError) -> Void in
                uploadFlipFailCallBack(flipError)
        }
    }
    
    func stockFlipsForWord(word: String, success: StockFlipsSuccessResponse, failure: StockFlipsFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let stockFlipUrl = HOST + STOCK_FLIPS
        let stockFlipParams = [
            RequestParams.WORD : word,
        ]
        
        request.GET(stockFlipUrl,
            parameters: stockFlipParams,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(JSON(responseObject))
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                let code = self.parseResponseError(error)
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details: nil, code: code))
                } else {
                    failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                }
            }
        )
    }
    
    func stockFlipsForWords(words: [String], success: StockFlipsSuccessResponse, failure: StockFlipsFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let stockFlipUrl = HOST + STOCK_FLIPS
        let stockFlipParams = [
            RequestParams.WORD : words,
        ]
        
        request.GET(stockFlipUrl,
            parameters: stockFlipParams,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(JSON(responseObject))
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                let code = self.parseResponseError(error)
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details: nil, code: code))
                } else {
                    failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                }
            }
        )
    }
    
    private func uploadBackgroundImage(image: UIImage, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        let url = HOST + UPLOAD_BACKGROUND
        let imageData = UIImageJPEGRepresentation(image, self.IMAGE_COMPRESSION)
        let fileName = "background_\(NSDate().timeIntervalSince1970).jpg"
        
        self.uploadData(imageData, toUrl: url, withFileName: fileName, partName: "background", mimeType: "image/jpeg", successCallback, failCallback)
    }
    
    private func uploadSound(soundPathUrl: NSURL, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        var error: NSError?
        let soundData: NSData? = NSData(contentsOfURL: soundPathUrl, options: NSDataReadingOptions.allZeros, error: &error)
        if (soundData != nil) {
            let url = HOST + UPLOAD_SOUND
            let fileName = "sound_\(NSDate().timeIntervalSince1970).m4a"
            self.uploadData(soundData!, toUrl: url, withFileName: fileName, partName: "sound", mimeType: "audio/mp4a-latm", successCallback: successCallback, failCallback: failCallback)
        }
        else {
            failCallback(FlipError(error: NSLocalizedString("Audio file not found. Please try again.", comment: "Audio file not found. Please try again."), details:nil, code: FlipError.NO_CODE))
        }
    }
    
    private func uploadVideo(videoPathUrl: NSURL, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        var error: NSError?
        
        let videoComposer = VideoComposer()
        let croppedVideoURL = videoComposer.videoFromOriginalVideo(videoPathUrl)
        
        let videoData: NSData? = NSData(contentsOfURL: croppedVideoURL, options: NSDataReadingOptions.allZeros, error: &error)
        
        if (videoData != nil) {
            println("Uploading a video with size = \(videoData?.length)")
            
            let url = HOST + UPLOAD_BACKGROUND
            let fileName = "video_\(NSDate().timeIntervalSince1970).mov"
            self.uploadData(videoData!, toUrl: url, withFileName: fileName, partName: "background", mimeType: "video/quicktime", successCallback: successCallback, failCallback: failCallback)
        }
        else {
            failCallback(FlipError(error: NSLocalizedString("Video file not found. Please try again.", comment: "Video file not found. Please try again."), details:nil, code: FlipError.NO_CODE))
        }
    }
    
    private func uploadData(data: NSData, toUrl url: String, withFileName fileName: String, partName: String, mimeType: String, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failCallback(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        request.POST(url,
            parameters: nil,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(data, name: partName, fileName: fileName, mimeType: mimeType)
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var url = self.parseUploadResponse(responseObject)
                successCallback(url)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                let code = self.parseResponseError(error)
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failCallback(FlipError(error: response["error"] as String!, details: nil, code: code))
                } else {
                    failCallback(FlipError(error: error.localizedDescription, details : nil, code: code))
                }
            }
        )
    }
    
    private func uploadNewFlip(word: String, backgroundUrl: String, soundUrl: String, category: String, isPrivate: Bool, uploadFlipSuccessCallback: UploadFlipSuccessResponse, uploadFlipFailCallBack: UploadFlipFailureResponse) {
        if let loggedUser = User.loggedUser() {
            if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
                uploadFlipFailCallBack(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
                return
            }
            
            let request = AFHTTPRequestOperationManager()
            request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            let createURL = CREATE_FLIP.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let createFlipUrl = HOST + createURL
            let createFlipParams = [
                RequestParams.WORD : word,
                RequestParams.BACKGROUND_URL : backgroundUrl,
                RequestParams.SOUND_URL : soundUrl,
                RequestParams.CATEGORY : category,
                RequestParams.IS_PRIVATE : isPrivate]
            
            request.POST(createFlipUrl,
                parameters: createFlipParams,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    uploadFlipSuccessCallback(JSON(responseObject))
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    let code = self.parseResponseError(error)
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as NSDictionary
                        uploadFlipFailCallBack(FlipError(error: response["error"] as String!, details: nil, code: code))
                    } else {
                        uploadFlipFailCallBack(FlipError(error: error.localizedDescription, details: nil, code: code))
                    }
                }
            )
        } else {
            uploadFlipFailCallBack(FlipError(error: NSLocalizedString("No user in session", comment: "Please try again or contact support"), details: nil, code: FlipError.NO_CODE))
        }
        
    }
    
    
    // MARK: - Response Parser
    
    private func parseUploadResponse(response: AnyObject) -> String? {
        let json = JSON(response)
        
        if (json.dictionary?.indexForKey(UPLOAD_BACKGROUND_RESPONSE_URL) != nil) {
            return json[UPLOAD_BACKGROUND_RESPONSE_URL].stringValue
        } else if (json.dictionary?.indexForKey(UPLOAD_SOUND_RESPONSE_URL) != nil) {
            return json[UPLOAD_SOUND_RESPONSE_URL].stringValue
        }
        
        println("FlipService Upload Parser error - response didn't return a valid value.")
        
        return nil
    }
}