// Copyright 2015 ArcTouch, Inc.
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

    let FORGOT_CODE_DID_NOT_MATCH = "Wrong validation code"
    
    init(phoneNumber: String, countryCode: String) {
        super.init(nibName: nil, bundle: nil)
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
    }
    
    
    // MARK: - VerificationCodeViewDelegate Methods
    
    override func verificationCodeView(verificatioCodeView: VerificationCodeView!, didFinishTypingVerificationCode verificationCode: String!) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        UserService.sharedInstance.verify(phoneNumber.intlPhoneNumberWithCountryCode(self.countryCode),
            verificationCode: verificationCode,
            success: { (username) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                
                self.verificationCodeView.resetVerificationCodeField()
                
                let newPasswordViewController = NewPasswordViewController(username: username, phoneNumber: self.phoneNumber, countryCode: self.countryCode, verificationCode: verificationCode)
                self.navigationController?.pushViewController(newPasswordViewController, animated: true)
            },
        failure: { (flipError) in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            
            if (flipError!.error == self.FORGOT_CODE_DID_NOT_MATCH || flipError!.error == self.RESENT_SMS_MESSAGE) {
                self.verificationCodeView.didEnterWrongVerificationCode()
            } else {
                let alertView: UIAlertView = UIAlertView(title: flipError!.error, message: flipError!.details, delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                
                self.verificationCodeView.resetVerificationCodeField()
                self.verificationCodeView.focusKeyboardOnCodeField()
            }
        })
    }
    
    
    // MARK: - Required methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}