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

class ForgotPasswordViewController: MugChatViewController, ForgotPasswordViewDelegate {
    
    var forgotPasswordView: ForgotPasswordView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgotPasswordView = ForgotPasswordView()
        forgotPasswordView.delegate = self
        self.view = forgotPasswordView
    }
    
    
    // MARK: - ForgotPasswordViewDelegate Methods
    func forgotPasswordViewDidFinishTypingMobileNumber(forgotPassword: ForgotPasswordView!) {
        //TODO: open VerificationCode screen (story 7153)
        //var verificationCodeViewController = VerificationCodeViewController()
        //self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    func forgotPasswordViewDidTapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }

}