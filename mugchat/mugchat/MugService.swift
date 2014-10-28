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

public typealias CreateMugSuccessResponse = (Mug) -> Void
public typealias CreateMugFailureResponse = (MugError?) -> Void
private typealias UploadSuccessResponse = (String?) -> Void
private typealias UploadFailureResponse = (MugError?) -> Void


public class MugService: MugchatService {
    
    private let UPLOAD_BACKGROUND_RESPONSE_URL = "background_url"
    private let UPLOAD_SOUND_RESPONSE_URL = "sound_url"

    let CREATE_MUG: String = "/user/{{user_id}}/mugs"
    let UPLOAD_BACKGROUND: String = "/background"
    let UPLOAD_SOUND: String = "/sound"
    
    let IMAGE_COMPRESSION: CGFloat = 0.3
    
    private struct RequestParams {
        static let WORD = "word"
        static let BACKGROUND_URL = "background_url"
        static let SOUND_URL = "sound_url"
        static let CATEGORY = "category"
        static let IS_PRIVATE = "is_private"
    }
    
    func createMug(word: String, backgroundImage: UIImage?, soundPath: NSURL?, category: String = "", isPrivate: Bool = true, createMugSuccessCallback: CreateMugSuccessResponse, createMugFailCallBack: CreateMugFailureResponse) {
        
        var uploadMugBlock: ((String, String) -> Void) = { (backgroundImageUrl, soundUrl) -> () in
            self.uploadNewMug(word, backgroundUrl: backgroundImageUrl, soundUrl: soundUrl, category: category, isPrivate: isPrivate, createMugSuccessCallback: createMugSuccessCallback, createMugFailCallBack: createMugFailCallBack)
        }
    
        var uploadSoundBlock: ((String) -> Void)? = nil
        if (soundPath != nil) {
            uploadSoundBlock = { (backgroundImageUrl) -> () in
                self.uploadSound(soundPath!, successCallback: { (soundUrl) -> Void in
                    uploadMugBlock(backgroundImageUrl, soundUrl!)
                }, failCallback: { (mugError) -> Void in
                    createMugFailCallBack(mugError)
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
                    uploadMugBlock(backgroundImageUrl!, "")
                }
            }) { (mugError) -> Void in
                createMugFailCallBack(mugError)
            }
        } else if (uploadSoundBlock != nil) {
            uploadSoundBlock!("")
        } else {
            uploadMugBlock("", "")
        }
    }
    
    func createMug(word: String, video: AnyObject, category: String = "", isPrivate: Bool = true, createMugSuccessCallback: CreateMugSuccessResponse, createMugFailCallBack: CreateMugFailureResponse) {
        // TODO:
    }
    
    private func uploadBackgroundImage(image: UIImage, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let url = HOST + UPLOAD_BACKGROUND

        request.POST(url,
            parameters: nil,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                var fileName = "background_\(NSDate().timeIntervalSince1970).jpg"
                formData.appendPartWithFileData(UIImageJPEGRepresentation(image, self.IMAGE_COMPRESSION), name: "background", fileName: fileName, mimeType: "image/jpeg")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var url = self.parseUploadResponse(responseObject)
                successCallback(url)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failCallback(MugError(error: response["error"] as String!, details: nil))
                } else {
                    failCallback(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    private func uploadSound(soundPathUrl: NSURL, successCallback: UploadSuccessResponse, failCallback: UploadFailureResponse) {
        var error: NSError?

        let soundData: NSData? = NSData(contentsOfURL: soundPathUrl, options: NSDataReadingOptions.allZeros, error: &error)
        if (soundData != nil) {
            let request = AFHTTPRequestOperationManager()
            request.responseSerializer = AFJSONResponseSerializer()
            let url = HOST + UPLOAD_SOUND
            
            request.POST(url,
                parameters: nil,
                constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                    var fileName = "sound_\(NSDate().timeIntervalSince1970).m4a"
                    formData.appendPartWithFileData(soundData, name: "sound", fileName: fileName, mimeType: "audio/mp4a-latm")
                },
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    var url = self.parseUploadResponse(responseObject)
                    successCallback(url)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as NSDictionary
                        failCallback(MugError(error: response["error"] as String!, details: nil))
                    } else {
                        failCallback(MugError(error: error.localizedDescription, details:nil))
                    }
                }
            )
        }
        else {
            failCallback(MugError(error: NSLocalizedString("Audio file not found. Please try again.", comment: "Audio file not found. Please try again."), details:nil))
        }
    }
    
    private func uploadNewMug(word: String, backgroundUrl: String, soundUrl: String, category: String, isPrivate: Bool, createMugSuccessCallback: CreateMugSuccessResponse, createMugFailCallBack: CreateMugFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let createURL = CREATE_MUG.stringByReplacingOccurrencesOfString("{{user_id}}", withString: AuthenticationHelper.sharedInstance.userInSession.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let createMugUrl = HOST + createURL
        let createMugParams = [
            RequestParams.WORD : word,
            RequestParams.BACKGROUND_URL : backgroundUrl,
            RequestParams.SOUND_URL : soundUrl,
            RequestParams.CATEGORY : category,
            RequestParams.IS_PRIVATE : isPrivate]
        
        request.POST(createMugUrl,
            parameters: createMugParams,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                createMugSuccessCallback(self.parseCreateMugResponse(responseObject)!)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    createMugFailCallBack(MugError(error: response["error"] as String!, details: nil))
                } else {
                    createMugFailCallBack(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    
    // MARK: - Response Parser
    
    private func parseUploadResponse(response: AnyObject) -> String? {
        let json = JSON(response)
        
        if (json.dictionary?.indexForKey(UPLOAD_BACKGROUND_RESPONSE_URL) != nil) {
            return json[UPLOAD_BACKGROUND_RESPONSE_URL].stringValue
        } else if (json.dictionary?.indexForKey(UPLOAD_SOUND_RESPONSE_URL) != nil) {
            return json[UPLOAD_SOUND_RESPONSE_URL].stringValue
        }
        
        println("MugService Upload Parser error - response didn't return a valid value.")
        
        return nil
    }
    
    private func parseCreateMugResponse(response: AnyObject) -> Mug? {
        let json = JSON(response)
        let mugDataSource = MugDataSource()
        return mugDataSource.createOrUpdateMugsWithJson(json)
    }
    
}