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

class LoginViewController: UIViewController, LoginViewDelegate {
    
    var loginView: LoginView!
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        super.viewWillDisappear(animated)
        loginView.viewWillDisappear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginView.viewDidAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView = LoginView()
        loginView.delegate = self
        self.view = loginView
        loginView.viewDidLoad()
    }
    
    func loginViewDidTapTermsOfUse(loginView: LoginView!) {
        var termsViewController = TermsOfServiceViewController()
        self.navigationController?.pushViewController(termsViewController, animated: true)
//        self.presentViewController(termsViewController, animated: true, completion: nil)
    }
}

