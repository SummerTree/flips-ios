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
    
    var loginView: LoginView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginView.viewWillAppear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginView.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView = LoginView()
        self.view = loginView
        
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
//        service.signup("devtest@arctouch.com", password: "YetAnotherPwd123", firstName: "Dev", lastName: "Test", birthday: date, nickname: "Neo", { (error: MugError?, user: User?) -> Void in
//            println(user?.username)
//            println(error?.error)
//        })
        service.signin("devtest@arctouch.com", password: "YetAnotherPwd123", { (error: MugError?, user: User?) -> Void in
            println(user?.username)
            println(error?.error)
        })
        
    }
}
