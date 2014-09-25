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

import UIKit

class LoginViewController: UIViewController {
    
    override func loadView() {
        let loginView = LoginView();
        self.view = loginView;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let manager = AFHTTPRequestOperationManager()
        
        manager.GET(
            "http://echo.jsontest.com/key/value/one/two",
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!,
                responseObject: AnyObject!) in
                println("JSON: " + responseObject.description)
            },
            failure: { (operation: AFHTTPRequestOperation!,
                error: NSError!) in
                println("Error: " + error.localizedDescription)
        })
        
        var service = UserService.sharedInstance
        var date = NSDate(dateString: "1968-12-02")
        service.signup("devtest@arctouch.com", password: "YetAnotherPwd123", firstName: "Dev", lastName: "Test", birthday: date, nickname: "Neo", { (error: MugError?, user: User?) -> Void in
            println(user?.username)
            println(error?.error)
        })
        
//        
//        
//        let user = ["username" : "devtest@arctouch.com", "password" : "YetAnotherPwd123", "firstName" : "Dev", "lastName" : "Test", "birthday" : "1968-12-02", "nickname" : "Neo"]
//        manager.POST(
//            "http://localhost:1337/signup",
//            parameters: user,
//            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
//                println("JSON: " + responseObject.description)
//            },
//            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
//                println("Error: " + error.localizedDescription)
//        })
    }
    
    
}

