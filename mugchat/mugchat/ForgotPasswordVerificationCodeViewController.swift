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

class ForgotPasswordVerificationCodeViewController: VerificationCodeViewController {

    init(phoneNumber: String) {
        super.init(nibName: nil, bundle: nil)
        self.phoneNumber = phoneNumber
    }
    
    
    // MARK: - VerificationCodeViewDelegate Methods
    
    override func verificationCodeView(verificatioCodeView: VerificationCodeView!, didFinishTypingVerificationCode verificationCode: String!) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        UserService.sharedInstance.verify(phoneNumber.intlPhoneNumber,
            verificationCode: verificationCode,
            success: { (username) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                
                self.verificationCodeView.resetVerificationCodeField()
                
                var newPasswordViewController = NewPasswordViewController(username: username, phoneNumber: self.phoneNumber, verificationCode: verificationCode)
                self.navigationController?.pushViewController(newPasswordViewController, animated: true)
            },
            failure: { (flipError) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                
                if (flipError!.error == self.VERIFICATION_CODE_DID_NOT_MATCH) {
                    self.verificationCodeView.didEnterWrongVerificationCode()
                } else {
                    println("Device code verification error: " + flipError!.error!)
                    self.verificationCodeView.resetVerificationCodeField()
                    self.verificationCodeView.focusKeyboardOnCodeField()
                }
            })
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}