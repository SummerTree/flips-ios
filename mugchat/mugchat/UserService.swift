//
//  UserService.swift
//  mugchat
//
//  Created by Ecil Teodoro on 9/23/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
//
public typealias ServiceResponse = (MugError?, User?) -> Void

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
    
    func signup(username: String, password: String, firstName: String, lastName: String, birthday: NSDate, nickname: String?, responseCallback: ServiceResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let url = HOST + SIGNUP_URL
        let parms = ["username" : username, "password" : password, "firstName" : firstName, "lastName" : lastName, "birthday" : birthday, "nickname" : nickname!]
        
        request.POST(url,
            parameters: parms,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let user = self.parseSignupResponse(responseObject)
                responseCallback(nil, user)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                var response = operation.responseObject as NSDictionary
                responseCallback(MugError(error: response["error"] as String!, details:nil), nil)
            }
        )
    }
    
    func parseSignupResponse(response: AnyObject) -> User? {
        var user = User()
        user.id = String(response.valueForKeyPath("id") as Int!)
        user.username = response.valueForKeyPath("username") as String!
        user.firstName = response.valueForKeyPath("firstName") as String!
        user.lastName = response.valueForKeyPath("lastName") as String!
        user.pubnubId = response.valueForKeyPath("pubnubId") as String!
        user.nickname = response.valueForKeyPath("nickname") as String!
        user.birthday = NSDate(dateTimeString: (response.valueForKeyPath("birthday") as String!))
        user.createdAt = NSDate(dateTimeString: (response.valueForKeyPath("createdAt") as String!))
        user.updatedAt = NSDate(dateTimeString: (response.valueForKeyPath("updatedAt") as String!))
        return user
    }
    
}