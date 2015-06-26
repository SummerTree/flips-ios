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

public typealias UserServicePasswordSuccessResponse = () -> Void
public typealias UserServiceVerifySuccessResponse = (username: String) -> Void
public typealias UserServiceSuccessResponse = (AnyObject?) -> Void
public typealias UserServiceSuccessJSONResponse = (JSON) -> Void
public typealias UserServiceFailureResponse = (FlipError?) -> Void
public typealias UserServiceMyFlipsSuccessResponse = (JSON) -> Void
public typealias UserServiceMyFlipsFailResponse = (FlipError?) -> Void

public class UserService: FlipsService {
    
    private let PLATFORM = "ios"
    
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
    let PHONE_NUMBER_EXISTS_URL: String = "/phoneNumber/{{phone_number}}/exists"
    let CHANGE_NUMBER_RESEND_CODE_URL: String = "/user/{{user_id}}/devices/{{device_id}}/change_resend"
    
    public class var sharedInstance : UserService {
        struct Static {
            static let instance : UserService = UserService()
        }
        return Static.instance
    }
    
    
    // MARK: - Sign-up
    
    func signUp(username: String, password: String, firstName: String, lastName: String, avatar: UIImage, birthday: NSDate, nickname: String?, phoneNumber: String!, facebookId: String?, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let url = HOST + SIGNUP_URL
        let params = [
            RequestParams.USERNAME : username,
            RequestParams.PASSWORD : password,
            RequestParams.FIRSTNAME : firstName,
            RequestParams.LASTNAME : lastName,
            RequestParams.BIRTHDAY : birthday,
            RequestParams.PHONENUMBER: phoneNumber,
            RequestParams.NICKNAME : nickname!,
            RequestParams.FACEBOOK_ID : facebookId != nil ? facebookId! : ""
        ]
        
        // first create user
        self.post(url,
            parameters: params,
            constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                formData.appendPartWithFileData(UIImageJPEGRepresentation(avatar, self.IMAGE_COMPRESSION), name: RequestParams.PHOTO, fileName: "avatar.jpg", mimeType: "image/jpeg")
            },
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var user = self.parseUserResponse(responseObject)
                success(user)
                
                var source = ""
                if (facebookId?.isEmpty == true) {
                    source = "email"
                } else {
                    source = "facebook"
                }
                
                AnalyticsService.logUserSignUp(source)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    let errorMessage: String? = response["error"] as! String?
                    let errorDetail: String? = response["details"] as! String?
                    failure(FlipError(error: errorMessage, details: errorDetail))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    private func parseUserResponse(response: AnyObject) -> User? {
        return PersistentManager.sharedInstance.createOrUpdateUserWithJson(JSON(response))
    }
    
    
    // MARK: - Sign-in
    
    func signIn(username: String, password: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) -> ReturnValue {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return .NO_INTERNET_CONNECTION
        }
        
        let url = HOST + SIGNIN_URL
        let params = [RequestParams.USERNAME : username, RequestParams.PASSWORD : password]
        
        self.post(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSigninResponse(responseObject)
                success(user)

                AnalyticsService.logUserSignIn("email")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    failure(FlipError(error: response["error"] as! String!, details:nil))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil))
                }
            }
        )
        
        return .WAITING_FOR_RESPONSE
    }
    
    func signInWithFacebookToken(accessToken: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let url = HOST + FACEBOOK_SIGNIN_URL
    
        let params = [
            RequestHeaders.FACEBOOK_ACCESS_TOKEN : accessToken,
            RequestHeaders.TOKEN : accessToken
        ]
        
        self.post(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSigninResponse(responseObject)
                success(user)
                
                AnalyticsService.logUserSignIn("facebook")
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.response != nil && operation.response.statusCode == 404) {
                    if let response = operation.responseObject as? NSDictionary {
                        if (response["error"] as? String == "User not found") {
                            failure(nil)
                            return
                        }
                    }
                }
                
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    var errorText: String = ""
                    var detailsText: String = ""
                    
                    if let errorMessage: String = response["error"] as? String {
                        errorText = errorMessage
                    }
                    
                    if let detailsMessage: String = response["details"] as? String {
                        detailsText = detailsMessage
                    }
                    
                    failure(FlipError(error: errorText, details: detailsText))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    func parseSigninResponse(response: AnyObject) -> User? {
        return PersistentManager.sharedInstance.createOrUpdateUserWithJson(JSON(response), isLoggedUser: true)
    }
    
    
    // MARK: Update user profile
    
    func update(username: String, password: String?, firstName: String, lastName: String, avatar: UIImage?, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }

        if let loggedUser = User.loggedUser() {
            let url = HOST + UPDATE_USER_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var params: Dictionary<String, AnyObject> = [
                RequestParams.USERNAME : username,
                RequestParams.FIRSTNAME : firstName,
                RequestParams.LASTNAME : lastName
            ]
            
            if let newPassword = password {
                params[RequestParams.PASSWORD] = newPassword
            }
            
            self.post(url,
                parameters: params,
                constructingBodyWithBlock: { (formData: AFMultipartFormData!) -> Void in
                    if (avatar != nil) {
                        let imageData = UIImageJPEGRepresentation(avatar, self.IMAGE_COMPRESSION)
                        formData.appendPartWithFileData(imageData, name: RequestParams.PHOTO, fileName: "avatar.jpg", mimeType: "image/jpeg")
                    }
                },
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    var user = self.parseUserResponse(responseObject)
                    success(user)
                    
                    AnalyticsService.logProfileChanged()
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        failure(FlipError(error: response["error"] as! String!, details: nil))
                    } else {
                        failure(FlipError(error: error.localizedDescription, details: nil))
                    }
            })
        }
    }


    // MARK: - Forgot password
    
    func forgotPassword(phoneNumber: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let url = HOST + self.FORGOT_URL
        var params = [RequestParams.PHONE_NUMBER : phoneNumber, RequestParams.DEVICE_PLATFORM : self.PLATFORM]
        
        if (DeviceHelper.sharedInstance.retrieveDeviceId() != nil) {
            params[RequestParams.DEVICE_ID] = DeviceHelper.sharedInstance.retrieveDeviceId()
        }
        
        if (DeviceHelper.sharedInstance.retrieveDeviceToken() != nil) {
            params[RequestParams.DEVICE_TOKEN] = DeviceHelper.sharedInstance.retrieveDeviceToken()
        }
        
        self.post(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let deviceID = self.parseDeviceId(JSON(responseObject))
                DeviceHelper.sharedInstance.saveDeviceId(deviceID)
                success(nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                let response = operation.response
                if ((response != nil) && (response.statusCode == 404)) {
                    failure(nil)
                } else if (operation.responseObject != nil) {
                    let responseObject = operation.responseObject as! NSDictionary
                    failure(FlipError(error: responseObject["error"] as! String!, details: responseObject["details"] as? String))
                } else {
                    failure(FlipError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    private func parseDeviceId(json: JSON) -> String {
        return json[RequestParams.ID].stringValue
    }
    
    
    // MARK: - Verify a Device
    
    func verify(phoneNumber: String, verificationCode: String, success: UserServiceVerifySuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let deviceId = DeviceHelper.sharedInstance.retrieveDeviceId() {
            let url = HOST + VERIFY_URL
            let params = [RequestParams.PHONE_NUMBER : phoneNumber,
                RequestParams.VERIFICATION_CODE : verificationCode,
                RequestParams.DEVICE_ID: deviceId]
            
            self.post(url,
                parameters: params,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let json = JSON(responseObject)
                    let username = json["user", "username"].stringValue
                    
                    if !username.isEmpty {
                        success(username: username)
                    } else {
                        failure(FlipError(error: NSLocalizedString("Unable to find username."), details: NSLocalizedString("The server did not return the username associated with this phone number.")))
                    }
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        failure(FlipError(error: response["error"] as! String!, details: response["details"] as! String?))
                    } else {
                        failure(FlipError(error: error.localizedDescription, details:nil))
                    }
                }
            )
        } else {
            failure(FlipError(error: LocalizedString.DEVICE_ERROR, details: LocalizedString.DEVICE_ID_ERROR))
        }
    }
    
    
    // MARK: - UPDATE password
    
    func updatePassword(username: String, phoneNumber: String, verificationCode: String, newPassword: String, success: UserServicePasswordSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let deviceId = DeviceHelper.sharedInstance.retrieveDeviceId() {
            let url = HOST + UPDATE_PASSWORD_URL
            let params = [RequestParams.EMAIL : username,
                RequestParams.PHONE_NUMBER : phoneNumber.intlPhoneNumber,
                RequestParams.VERIFICATION_CODE : verificationCode,
                RequestParams.PASSWORD : newPassword,
                RequestParams.DEVICE_ID : deviceId]
            
            self.post(url,
                parameters: params,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    success()
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

        } else {
            failure(FlipError(error: LocalizedString.DEVICE_ERROR, details: LocalizedString.DEVICE_ID_ERROR))
        }
    }
    
    
    // MARK: - Import Facebook Contacts
    
    
    func importFacebookFriends(success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let permissions: [String] = FBSession.activeSession().permissions as! [String]
            if (!contains(permissions, "user_friends")) {
                failure(FlipError(error: "user_friends permission not allowed.", details:nil))
                return
            }
            
            var usersFacebookIDS = [String]()
            FBRequestConnection.startForMyFriendsWithCompletionHandler { (connection, result, error) -> Void in
                if (error != nil) {
                    failure(FlipError(error: error.localizedDescription, details:nil))
                    return
                }
                
                let resultDictionary: NSDictionary = result as! NSDictionary
                let usersJSON = JSON(resultDictionary.objectForKey("data")!)
                
                if let users = usersJSON.array {
                    for user in users {
                        var userId = user["id"]
                        usersFacebookIDS.append(userId.stringValue)
                    }
                    
                    if (usersFacebookIDS.count == 0) {
                        return
                    }

                    var url = self.HOST + self.FACEBOOK_CONTACTS_VERIFY.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    var params: Dictionary<String, AnyObject> = [
                        RequestParams.FACEBOOK_IDS : usersFacebookIDS
                    ]
                    
                    self.post(url, parameters: params, success: { (operation, responseObject) -> Void in
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
                            if (operation.responseObject != nil) {
                                var response = operation.responseObject as! NSDictionary
                                failure(FlipError(error: response["error"] as! String!, details : nil))
                            } else {
                                failure(FlipError(error: error.localizedDescription, details : nil))
                            }
                    })
                }
            }
        }
    }

    // MARK: - Get Facebook User Info
    
    func getFacebookUserInfo(success: UserServiceSuccessJSONResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let graphPath = "me?fields=id,first_name,last_name,email,picture.width(300)"
        FBRequestConnection.startWithGraphPath(graphPath) { (connection, result, error) -> Void in
            if (error != nil) {
                failure(FlipError(error: error.localizedDescription, details:nil))
                return
            }
            
            if result == nil {
                failure(FlipError(error: "User info json is nil.", details:nil))
                return
            }
            
            success(JSON(result! as! NSDictionary))
        }
    }

    // MARK: - Upload contacts

    func uploadContacts(success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }

        if let loggedUser = User.loggedUser() {
            ContactListHelper.sharedInstance.findAllContactsWithPhoneNumber({ (contacts: Array<ContactListHelperContact>?) -> Void in
                if (count(contacts!) == 0) {
                    success(nil)
                    return
                }

                var numbers = Array<String>()
                for contact in contacts! {
                    numbers.append(contact.phoneNumber)
                }

                var url = self.HOST + self.UPLOAD_CONTACTS_VERIFY.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                var params: Dictionary<String, AnyObject> = [
                    RequestParams.PHONENUMBERS : numbers
                ]

                self.post(url, parameters: params, success: { (operation, responseObject) -> Void in
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
                    
                    AnalyticsService.logContactsImported(response.count)
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        var response = operation.responseObject as! NSDictionary
                        failure(FlipError(error: response["error"] as! String!, details: nil))
                    } else {
                        failure(FlipError(error: error.localizedDescription, details: nil))
                    }
                })
            }, failure: { (error) -> Void in
                failure(FlipError(error: LocalizedString.CONTACTS_ACCESS_TITLE, details:LocalizedString.CONTACTS_ACCESS_MESSAGE))
            })
        }
    }
    
    
    // MARK: - My Flips
    
    func getMyFlips(successCompletion: UserServiceMyFlipsSuccessResponse, failCompletion: UserServiceMyFlipsFailResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let url = self.HOST + self.MY_FLIPS.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            self.get(url, parameters: nil,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    successCompletion(JSON(responseObject))
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        failCompletion(FlipError(error: response["error"] as! String!, details: nil))
                    } else {
                        failCompletion(FlipError(error: error.localizedDescription, details: nil))
                    }
            })
        }
    }
    
    // MARK: - Phone Number
    
    func phoneNumberExists(phoneNumber: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        let url = self.HOST + self.PHONE_NUMBER_EXISTS_URL.stringByReplacingOccurrencesOfString("{{phone_number}}", withString: phoneNumber.intlPhoneNumber, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        self.get(url, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let exists = JSON(responseObject)["exists"].boolValue
                success(exists)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as! NSDictionary
                    failure(FlipError(error: response["error"] as! String!, details: nil))
                } else {
                    failure(FlipError(error: error.localizedDescription, details: nil))
                }
        })
    }
    
    // MARK: - Resend code
    
    func resendCodeWhenChangingNumber(phoneNumber: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        if let loggedUser = User.loggedUser() {
            var path = self.CHANGE_NUMBER_RESEND_CODE_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            path = path.stringByReplacingOccurrencesOfString("{{device_id}}", withString: DeviceHelper.sharedInstance.retrieveDeviceId()!, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let url = self.HOST + path
            
            var params: Dictionary<String, AnyObject> = [
                RequestParams.PHONE_NUMBER : phoneNumber
            ]
            
            self.post(url,
                parameters: params,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let device = PersistentManager.sharedInstance.createDeviceWithJson(JSON(responseObject))
                    success(device)
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
        static let FACEBOOK_ID = "facebookID"
        static let EMAIL = "email"
        static let PHONE_NUMBER = "phone_number"
        static let PHONENUMBER = "phoneNumber"
        static let PHONENUMBERS = "phoneNumbers"
        static let VERIFICATION_CODE = "verification_code"
        static let PHOTO = "photo"
        static let FACEBOOK_IDS = "facebookIDs"
        static let DEVICE_ID = "device_id"
        static let DEVICE_TOKEN = "device_token"
        static let DEVICE_PLATFORM = "platform"
        static let ID = "id"
    }
}