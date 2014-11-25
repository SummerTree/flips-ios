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

public typealias UserServiceSuccessResponse = (AnyObject?) -> Void
public typealias UserServiceFailureResponse = (MugError?) -> Void

public class UserService: MugchatService {
    
    let SIGNUP_URL: String = "/signup"
    let SIGNIN_URL: String = "/signin"
    let FACEBOOK_SIGNIN_URL: String = "/signin/facebook"
    let FORGOT_URL: String = "/user/forgot"
    let VERIFY_URL: String = "/user/verify"
    let UPLOAD_PHOTO_URL: String = "/user/{{user_id}}/photo"
    let UPDATE_USER_URL: String = "/user/{{user_id}}"
    let IMAGE_COMPRESSION: CGFloat = 0.3
    let UPDATE_PASSWORD_URL: String = "/user/password"
    let UPLOAD_CONTACTS_VERIFY: String = "/user/{{user_id}}/contacts/verify"
    
    public class var sharedInstance : UserService {
        struct Static {
            static let instance : UserService = UserService()
        }
        return Static.instance
    }
    
    
    // MARK: - Sign-up
    
    func signUp(username: String, password: String, firstName: String, lastName: String, avatar: UIImage, birthday: NSDate, nickname: String?, phoneNumber: String!, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
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
                    //failure(MugError(error: response["error"] as String!, details:response["details"] as String!))
                    failure(MugError(error: response["error"] as String!, details: nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    private func parseUserResponse(response: AnyObject) -> User? {
        let userDataSource = UserDataSource()
        let user = userDataSource.createOrUpdateUserWithJson(JSON(response))
        return user
    }
    
    
    // MARK: - Sign-in
    
    func signIn(username: String, password: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
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
                    failure(MugError(error: response["error"] as String!, details:nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    func signInWithFacebookToken(accessToken: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
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
                    failure(MugError(error: response["error"] as String!, details:nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    func parseSigninResponse(response: AnyObject) -> User? {
        let userDataSource = UserDataSource()
        let user = userDataSource.createOrUpdateUserWithJson(JSON(response))
        user.me = true
        userDataSource.save()
        
        return user
    }
    
    
    // MARK: Update user profile
    
    func update(username: String, password: String?, firstName: String, lastName: String, avatar: UIImage?, birthday: NSDate, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let url = HOST + UPDATE_USER_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: User.loggedUser()!.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        var params: Dictionary<String, AnyObject> = [
            RequestParams.USERNAME : username,
            RequestParams.FIRSTNAME : firstName,
            RequestParams.LASTNAME : lastName,
            RequestParams.BIRTHDAY : birthday
        ]
        
        if let newPassword = password {
            params[RequestParams.PASSWORD] = newPassword
        }
        
        request.PUT(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                var user = self.parseUserResponse(responseObject)
                success(user)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    // TODO: we need to identify what was the problem to show the appropriate message
                    //failure(MugError(error: response["error"] as String!, details:response["details"] as String!))
                    failure(MugError(error: response["error"] as String!, details: nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    
    // MARK: - Forgot password
    
    func forgotPassword(phoneNumber: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
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
                    failure(MugError(error: response["error"] as String!, details:nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    
    // MARK: - Verify a Device
    
    func verifyDevice(phoneNumber: String, verificationCode: String, success: DeviceServiceSuccessResponse, failure: DeviceServiceFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        let url = HOST + VERIFY_URL
        let params = [RequestParams.PHONE_NUMBER : phoneNumber, RequestParams.VERIFICATION_CODE : verificationCode]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let device = self.parseDeviceResponse(responseObject)
                success(device)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(MugError(error: response["error"] as String!, details: response["details"] as String?))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    private func parseDeviceResponse(response: AnyObject) -> Device? {
        let deviceDataSource = DeviceDataSource()
        return deviceDataSource.createEntityWithObject(response)
    }
    
    
    // MARK: - UPDATE password
    
    func updatePassword(user: User, phoneNumber: String, verificationCode: String, newPassword: String, success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        
        let url = HOST + UPDATE_PASSWORD_URL
        let params = [RequestParams.EMAIL : user.username, RequestParams.PHONE_NUMBER : phoneNumber, RequestParams.VERIFICATION_CODE : verificationCode, RequestParams.PASSWORD : newPassword]
        
        request.PUT(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(nil)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(MugError(error: response["error"] as String!, details:nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    
    // MARK: - Upload contacts
    
    func uploadContacts(success: UserServiceSuccessResponse, failure: UserServiceFailureResponse) {
        var numbers = Array<String>()
        let contactDatasource = ContactDataSource()
        let userDatasource = UserDataSource()
        
        ContactListHelper.sharedInstance.findAllContactsWithPhoneNumber({ (contacts) -> Void in
            for contact in contacts! {
                if (countElements(contact.phoneNumber) > 0) {
                    let cleanPhone = PhoneNumberHelper.formatUsingUSInternational(contact.phoneNumber)
                    numbers.append(cleanPhone)
                }
            }
            
            var request = AFHTTPRequestOperationManager()
            request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
            var url = self.HOST + self.UPLOAD_CONTACTS_VERIFY.stringByReplacingOccurrencesOfString("{{user_id}}", withString: User.loggedUser()!.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            var params: Dictionary<String, AnyObject> = [
                RequestParams.PHONENUMBERS : numbers
            ]
            
            request.POST(url, parameters: params,
                success: { (operation, responseObject) -> Void in
                    var response = JSON(responseObject)
                    
                    for (index, user) in response {
                        var user = userDatasource.createOrUpdateUserWithJson(user)
                    }
                    
                    success(nil)
                    
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        var response = operation.responseObject as NSDictionary
                        failure(MugError(error: response["error"] as String!, details:nil))
                    } else {
                        failure(MugError(error: error.localizedDescription, details:nil))
                    }
               
            })
        }, failure: { (error) -> Void in
            failure(MugError(error: "Error retrieving contacts.", details:nil))
        })
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
    }
}