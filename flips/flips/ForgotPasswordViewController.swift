//
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

private let INVALID_NUMBER = NSLocalizedString("Invalid Number", comment: "Invalid Number")
private let INVALID_MESSAGE = NSLocalizedString("Phone number entered does not match our records. Please try again.", comment: "No match")


class ForgotPasswordViewController: FlipsViewController, ForgotPasswordViewDelegate, UIAlertViewDelegate {
    
    var forgotPasswordView: ForgotPasswordView!
    
    private var username: String!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username;
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        super.loadView()
        
        forgotPasswordView = ForgotPasswordView()
        forgotPasswordView.delegate = self
        self.view = forgotPasswordView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        forgotPasswordView.viewWillAppear()
        forgotPasswordView.focusKeyboardOnMobileNumberField()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        forgotPasswordView.viewWillDisappear()
    }
    
    
    // MARK: - ForgotPasswordViewDelegate Methods
    
    func phoneNumberView(mobileNumberField : UITextField!, didFinishTypingMobileNumber mobileNumber : String!, countryCode: String!) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        UserService.sharedInstance.forgotPassword(mobileNumber.intlPhoneNumberWithCountryCode(countryCode), success: { (user) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            
            let verificationCodeViewController = ForgotPasswordVerificationCodeViewController(phoneNumber: mobileNumber, countryCode: countryCode)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }) { (flipError) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            
            var alertView: UIAlertView!
            if (flipError != nil) {
                alertView = UIAlertView(title: flipError!.error, message: flipError!.details, delegate: self, cancelButtonTitle: LocalizedString.OK)
            } else {
                alertView = UIAlertView(title: INVALID_NUMBER, message: INVALID_MESSAGE, delegate: self, cancelButtonTitle: LocalizedString.OK)
            }
            alertView.show()
        }
    }
    
    func forgotPasswordViewDidTapBackButton(forgotPassword: ForgotPasswordView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView,
        clickedButtonAtIndex buttonIndex: Int) {
        forgotPasswordView.focusKeyboardOnMobileNumberField()
    }
}