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
    }
}

