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
    
    private let US_CODE = "+1"
    
    var forgotPasswordView: ForgotPasswordView!
    
    private var username: String!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username;
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        forgotPasswordView = ForgotPasswordView()
        forgotPasswordView.delegate = self
        self.view = forgotPasswordView
    }
    
    
    // MARK: - ForgotPasswordViewDelegate Methods
    func phoneNumberView(mobileNumberField : UITextField!, didFinishTypingMobileNumber mobileNumber : String!) {
        let trimmedPhoneNumber = mobileNumber.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let intlPhoneNumber = "\(US_CODE)\(trimmedPhoneNumber)"
        
        UserService.sharedInstance.forgot(username, phoneNumber: intlPhoneNumber, success: { (user) -> Void in
            var verificationCodeViewController = ForgotPasswordVerificationCodeViewController(phoneNumber: intlPhoneNumber)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }) { (mugError) -> Void in
            println(mugError!.error)
        }
    }
    
    func forgotPasswordViewDidTapBackButton(forgotPassword: ForgotPasswordView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}