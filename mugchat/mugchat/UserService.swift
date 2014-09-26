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

public typealias UserServiceResponse = (MugError?, User?) -> Void

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
    
    //    usage:
    //
    //    var service = UserService.sharedInstance
    //    var date = NSDate(dateString: "1968-12-02")
    //    service.signup("devtest@arctouch.com", password: "YetAnotherPwd123", firstName: "Dev", lastName: "Test", birthday: date, nickname: "Neo", { (error: MugError?, user: User?) -> Void in
    //        println(user?.username)
    //        println(error?.error)
    //    })
    func signup(username: String, password: String, firstName: String, lastName: String, birthday: NSDate, nickname: String?, responseCallback: UserServiceResponse) {
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
                if (operation.responseObject != nil) {
                    var response = operation.responseObject as NSDictionary
                    responseCallback(MugError(error: response["error"] as String!, details:nil), nil)
                } else {
                    responseCallback(MugError(error: "Unexpected Error", details:nil), nil)
                }
            }
        )
    }
    
    func parseSignupResponse(response: AnyObject) -> User? {
        var user = User(json: response as NSDictionary)
        return user
    }
    
}