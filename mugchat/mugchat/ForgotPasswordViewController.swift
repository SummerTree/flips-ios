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

class ForgotPasswordViewController: UIViewController, ForgotPasswordViewDelegate {
    
    var forgotPasswordView: ForgotPasswordView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgotPasswordView = ForgotPasswordView()
        forgotPasswordView.delegate = self
        self.view = forgotPasswordView
        forgotPasswordView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        forgotPasswordView.viewDidAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        super.viewWillDisappear(animated)
        forgotPasswordView.viewWillDisappear()
    }
    
    
    func forgotPasswordViewDidFinishTypingMobileNumber(forgotPassword: ForgotPasswordView!) {
        //var verificationCodeViewController = VerificationCodeViewController()
        //self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }

}

