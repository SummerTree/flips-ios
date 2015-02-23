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

public typealias UserServicePasswordSuccessResponse = () -> Void
public typealias UserServiceVerifySuccessResponse = (username: String) -> Void
public typealias UserServiceSuccessResponse = (AnyObject?) -> Void
public typealias UserServiceFailureResponse = (FlipError?) -> Void
public typealias UserServiceMyFlipsSuccessResponse = (JSON) -> Void
public typealias UserServiceMyFlipsFailResponse = (FlipError?) -> Void


public class UserService: FlipsService {
    
    let SIGNUP_URL: String = "/signup"
    let SIGNIN_URL: String = "/signin"
    let FACEBOOK_SIGNIN_URL: String = "/signin/facebook"
    let FORGOT_URL: String = "/user/forgot"
    let VERIFY_URL: String = "/user/verify"
    let UPLOAD_PHOTO_URL: String = "/user/{{user_id}}/photo"
    let UPDATE_USER_URL: String = "/user/{{user_id}}/update"
    let IMAGE_COMPRESSION: CGFloat = 0.3
    let UPDATE_PASSWORD_URL: String = "/user/password"
    let UPLOAD_CONTACTS_VERIFY: String = "/user/{{user_id}}/contacts/verify"
    let FACEBOOK_CONTACTS_VERIFY: String = "/user/{{user_id}}/facebook/verify"
    let MY_FLIPS: String = "/user/{{user_id}}/flips"
    
    public class var sharedInstance : UserService {
        struct Static {
            static let instance : UserService = UserService()
        }
        return Static.instance
    }
    
    
    // MARK: - Sign-up
    
    func signUp(username: String, password: String, firstName: String, lastName: String, avatar: UIImage, birthday: NSDate, nickname: String?, phoneNumber: String!, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let url = HOST + SIGNUP_URL
        let params = [
            RequestParams.USERNAME : username,
            RequestParams.PASSWORD : password,
            RequestParams.FIRSTNAME : firstName,
            RequestParams.LASTNAME : lastName,
            RequestParams.BIRTHDAY : birthday,
            RequestParams.PHONENUMBER: phoneNumber,
            RequestParams.NICKNAME : nickname!]
        
        // first create user
        request.POST(url,
            parameters: params,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(UIImageJPEGRepresentation(avatar, self.IMAGE_COMPRESSION), name: RequestParams.PHOTO, fileName: "avatar.jpg", mimeType: "image/jpeg")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var user = self.parseUserResponse(responseObject)
                success(user)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    // TODO: we need to identify what was the problem to show the appropriate message
                    let errorMessage: String? = response["error"] as String?
                    let errorDetail: String? = response["details"] as String?
                    failure(FlipError(error: errorMessage, details: errorDetail, code: FlipError.NO_CODE))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                }
            }
        )
    }
    
    private func parseUserResponse(response: AnyObject) -> User? {
        return PersistentManager.sharedInstance.createOrUpdateUserWithJson(JSON(response))
    }
    
    
    // MARK: - Sign-in
    
    func signIn(username: String, password: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let url = HOST + SIGNIN_URL
        let params = [RequestParams.USERNAME : username, RequestParams.PASSWORD : password]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSigninResponse(responseObject)
                success(user)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details:nil, code: FlipError.NO_CODE))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                }
            }
        )
    }
    
    func signInWithFacebookToken(accessToken: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let url = HOST + FACEBOOK_SIGNIN_URL
        
        request.requestSerializer.setValue(accessToken, forHTTPHeaderField: RequestHeaders.FACEBOOK_ACCESS_TOKEN)
        request.requestSerializer.setValue(accessToken, forHTTPHeaderField: RequestHeaders.TOKEN)
        
        request.POST(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSigninResponse(responseObject)
                success(user)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    var errorText: String = ""
                    var detailsText: String = ""
                    
                    if let errorMessage: String = response["error"] as? String {
                        errorText = errorMessage
                    }
                    
                    if let detailsMessage: String = response["details"] as? String {
                        detailsText = detailsMessage
                    }
                    
                    failure(FlipError(error: errorText, details: detailsText, code: FlipError.NO_CODE))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                }
            }
        )
    }
    
    func parseSigninResponse(response: AnyObject) -> User? {
        return PersistentManager.sharedInstance.createOrUpdateUserWithJson(JSON(response), isLoggedUser: true)
    }
    
    
    // MARK: Update user profile
    
    func update(username: String, password: String?, firstName: String, lastName: String, avatar: UIImage?, birthday: NSDate, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let request = AFHTTPRequestOperationManager()
            request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            let url = HOST + UPDATE_USER_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var params: Dictionary<String, AnyObject> = [
                RequestParams.USERNAME : username,
                RequestParams.FIRSTNAME : firstName,
                RequestParams.LASTNAME : lastName,
                RequestParams.BIRTHDAY : birthday
            ]
            
            if let newPassword = password {
                params[RequestParams.PASSWORD] = newPassword
            }
            
            request.POST(url,
                parameters: params,
                constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                    let imageData = UIImageJPEGRepresentation(avatar, self.IMAGE_COMPRESSION)
                    formData.appendPartWithFileData(imageData, name: RequestParams.PHOTO, fileName: "avatar.jpg", mimeType: "image/jpeg")
                },
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    var user = self.parseUserResponse(responseObject)
                    success(user)
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    let code = self.parseResponseError(error)
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as NSDictionary
                        // TODO: we need to identify what was the problem to show the appropriate message
                        //failure(FlipError(error: response["error"] as String!, details:response["details"] as String!))
                        failure(FlipError(error: response["error"] as String!, details: nil, code: code))
                    } else {
                        failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                    }
                }
            )
        }
    }
    
    
    // MARK: - Forgot password
    
    func forgotPassword(phoneNumber: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let url = HOST + FORGOT_URL
        let params = [RequestParams.PHONE_NUMBER : phoneNumber]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details:nil, code: FlipError.NO_CODE))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                }
            }
        )
    }
    
    
    // MARK: - Verify a Device
    
    func verify(phoneNumber: String, verificationCode: String, success: UserServiceVerifySuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        let url = HOST + VERIFY_URL
        let params = [RequestParams.PHONE_NUMBER : phoneNumber, RequestParams.VERIFICATION_CODE : verificationCode]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let json = JSON(responseObject)
                let username = json["user", "username"].stringValue
                
                if !username.isEmpty {
                    success(username: username)
                } else {
                    failure(FlipError(error: NSLocalizedString("Unable to find username."), details: NSLocalizedString("The server did not return the username associated with this phone number."), code: FlipError.NO_CODE))
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details: response["details"] as String?, code: FlipError.NO_CODE))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                }
            }
        )
    }
    
    
    // MARK: - UPDATE password
    
    func updatePassword(username: String, phoneNumber: String, verificationCode: String, newPassword: String, success: UserServicePasswordSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        let url = HOST + UPDATE_PASSWORD_URL
        let params = [RequestParams.EMAIL : username, RequestParams.PHONE_NUMBER : phoneNumber.intlPhoneNumber, RequestParams.VERIFICATION_CODE : verificationCode, RequestParams.PASSWORD : newPassword]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success()
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                let code =  self.parseResponseError(error)
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details : nil, code: code))
                } else {
                    failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                }
            }
        )
    }
    
    
    // MARK: - Import Facebook Contacts
    
    
    func importFacebookFriends(success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let permissions: [String] = FBSession.activeSession().permissions as [String]
            println("[DEBUG: Facebook Permissions: \(permissions)]")
            
            if (!contains(permissions, "user_friends")) {
                failure(FlipError(error: "user_friends permission not allowed.", details:nil, code: FlipError.NO_CODE))
                return
            }
            
            var usersFacebookIDS = [String]()
            FBRequestConnection.startForMyFriendsWithCompletionHandler { (connection, result, error) -> Void in
                if (error != nil) {
                    failure(FlipError(error: error.localizedDescription, details:nil, code: FlipError.NO_CODE))
                    return
                }
                
                let resultDictionary: NSDictionary = result as NSDictionary
                let usersJSON = JSON(resultDictionary.objectForKey("data")!)
                
                if let users = usersJSON.array {
                    for user in users {
                        var userId = user["id"]
                        usersFacebookIDS.append(userId.stringValue)
                    }
                    
                    var request = AFHTTPRequestOperationManager()
                    request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
                    var url = self.HOST + self.FACEBOOK_CONTACTS_VERIFY.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    var params: Dictionary<String, AnyObject> = [
                        RequestParams.FACEBOOK_IDS : usersFacebookIDS
                    ]
                    
                    request.POST(url, parameters: params, success: { (operation, responseObject) -> Void in
                        var response:JSON = JSON(responseObject)
                        
                        for (index, user) in response {
                            SwiftTryCatch.try({ () -> Void in
                                println("Trying to import: \(user)")
                                var user = PersistentManager.sharedInstance.createOrUpdateUserWithJson(user)
                                }, catch: { (error) -> Void in
                                    println("Error: [\(error))")
                                }, finally: nil)
                        }
                        
                        success(nil)
                        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                            let code =  self.parseResponseError(error)
                            if (operation.responseObject != nil) {
                                var response = operation.responseObject as NSDictionary
                                failure(FlipError(error: response["error"] as String!, details : nil, code: code))
                            } else {
                                failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                            }
                    })
                }
            }
        }
    }
    
    
    // MARK: - Upload contacts
    
    func uploadContacts(success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }

        if let loggedUser = User.loggedUser() {
            ContactListHelper.sharedInstance.findAllContactsWithPhoneNumber({ (contacts: Array<ContactListHelper.Contact>?) -> Void in
                if(countElements(contacts!) == 0) {
                    success(nil)
                    return
                }
                
                var numbers = Array<String>()
                for contact in contacts! {
                    if (countElements(contact.phoneNumber) > 0) {
                        let cleanPhone = PhoneNumberHelper.formatUsingUSInternational(contact.phoneNumber)
                        numbers.append(cleanPhone)
                    }
                }
                
                var request = AFHTTPRequestOperationManager()
                request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
                var url = self.HOST + self.UPLOAD_CONTACTS_VERIFY.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                var params: Dictionary<String, AnyObject> = [
                    RequestParams.PHONENUMBERS : numbers
                ]
                
                request.POST(url, parameters: params, success: { (operation, responseObject) -> Void in
                    var response:JSON = JSON(responseObject)
                    
                    for (index, user) in response {
                        SwiftTryCatch.try({ () -> Void in
                            println("Trying to import: \(user)")
                            PersistentManager.sharedInstance.createOrUpdateUserWithJson(user)
                            }, catch: { (error) -> Void in
                                println("Error: [\(error))")
                            }, finally: nil)
                    }
                    
                    success(nil)
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                        let code = self.parseResponseError(error)
                        if (operation.responseObject != nil) {
                            var response = operation.responseObject as NSDictionary
                            failure(FlipError(error: response["error"] as String!, details : nil, code: code))
                        } else {
                            failure(FlipError(error: error.localizedDescription, details : nil, code: code))
                        }
                })
                }, failure: { (error) -> Void in
                    failure(FlipError(error: "Error retrieving contacts.", details:nil, code: FlipError.NO_CODE))
            })
        }
    }
    
    
    // MARK: - My Flips
    
    func getMyFlips(successCompletion: UserServiceMyFlipsSuccessResponse, failCompletion: UserServiceMyFlipsFailResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let request = AFHTTPRequestOperationManager()
            request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            let url = self.HOST + self.MY_FLIPS.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            request.GET(url, parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    successCompletion(JSON(responseObject))
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    let code = self.parseResponseError(error)
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as NSDictionary
                        failCompletion(FlipError(error: response["error"] as String!, details: nil, code: code))
                    } else {
                        failCompletion(FlipError(error: error.localizedDescription, details : nil, code: code))
                    }
                }
            )
        }
    }
    
    
    // MARK: - Requests constants
    
    private struct RequestHeaders {
        static let FACEBOOK_ACCESS_TOKEN = "facebook_access_token"
        static let TOKEN = "token"
    }
    
    private struct RequestParams {
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let FIRSTNAME = "firstName"
        static let LASTNAME = "lastName"
        static let BIRTHDAY = "birthday"
        static let NICKNAME = "nickname"
        static let EMAIL = "email"
        static let PHONE_NUMBER = "phone_number"
        static let PHONENUMBER = "phoneNumber"
        static let PHONENUMBERS = "phoneNumbers"
        static let VERIFICATION_CODE = "verification_code"
        static let PHOTO = "photo"
        static let FACEBOOK_IDS = "facebookIDs"
    }
}