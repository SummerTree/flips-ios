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

public typealias UserServiceSuccessResponse = (User?) -> Void
public typealias UserServiceFaiureResponse = (MugError?) -> Void

public class UserService: MugchatService {
    
    let SIGNUP_URL: String = "/signup"
    let SIGNIN_URL: String = "/signin"
    let FACEBOOK_SIGNIN_URL: String = "/signin/facebook"
    let FORGOT_URL: String = "/user/forgot"
    let VERIFY_URL: String = "/user/verify"
    let UPLOAD_PHOTO_URL: String = "/user/{{user_id}}/photo"
    
    public class var sharedInstance : UserService {
    struct Static {
        static let instance : UserService = UserService()
        }
        return Static.instance
    }
    
    
    // MARK: - Sign-up
    
    func signUp(username: String, password: String, firstName: String, lastName: String, birthday: NSDate, nickname: String?, success: UserServiceSuccessResponse, failure: UserServiceFaiureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let url = HOST + SIGNUP_URL
        let params = [
                RequestParams.USERNAME : username,
                RequestParams.PASSWORD : password,
                RequestParams.FIRSTNAME : firstName,
                RequestParams.LASTNAME : lastName,
                RequestParams.BIRTHDAY : birthday,
                RequestParams.NICKNAME : nickname!]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSignupResponse(responseObject)
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
    
    func parseSignupResponse(response: AnyObject) -> User? {
        var user = User(object: response)
        return user
    }
    
    // MARK: - Sign-in
    
    func signIn(username: String, password: String, success: UserServiceSuccessResponse, failure: UserServiceFaiureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
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
    
    func signInWithFacebookToken(accessToken: String, success: UserServiceSuccessResponse, failure: UserServiceFaiureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let url = HOST + FACEBOOK_SIGNIN_URL

        request.requestSerializer.setValue(accessToken, forHTTPHeaderField: RequestHeaders.FACEBOOK_ACCESS_TOKEN)
        request.requestSerializer.setValue(accessToken, forHTTPHeaderField: "token")
        
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
        var user = User(object: response)
        return user
    }
    
    struct RequestHeaders {
        static let FACEBOOK_ACCESS_TOKEN = "facebook_access_token"
    }
    
    struct RequestParams {
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let FIRSTNAME = "firstName"
        static let LASTNAME = "lastName"
        static let BIRTHDAY = "birthday"
        static let NICKNAME = "nickname"
    }
    
}