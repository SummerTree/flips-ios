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

import Foundation

class ChangeNumberVerificationCodeViewController: VerificationCodeViewController, VerificationCodeViewDelegate, ChangeNumberVerificationCodeViewDelegate {
 
    private var changeNumberVerificationCodeView: ChangeNumberVerificationCodeView!
    
    override func loadView() {
        changeNumberVerificationCodeView = ChangeNumberVerificationCodeView(phoneNumber: self.phoneNumber)
        changeNumberVerificationCodeView.delegate = self
        changeNumberVerificationCodeView.verificationCodeDelegate = self
        
        self.view = changeNumberVerificationCodeView
    }
    
    override func viewWillAppear(animated: Bool) {
        changeNumberVerificationCodeView.viewWillAppear()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        changeNumberVerificationCodeView.viewWillDisappear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteNavBarWithBackButton("Verification Code")
    }
    
    // MARK: - ChangeNumberVerificationCodeViewDelegate
    
    func makeConstraintToNavigationBarBottom(view: UIView!) {
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
        
        view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            return ()
        }
    }
    
    func navigateAfterValidateDevice() {
        for viewController in self.navigationController!.viewControllers {
            
            let lastViewController = viewController as UIViewController
            if (lastViewController.isKindOfClass(SettingsViewController.self)) {
                self.navigationController?.popToViewController(lastViewController, animated: true)
                break
            }
        }
    }
    
    override func verificationCodeViewDidTapResendButton(view: VerificationCodeView!) {
        view.resetVerificationCodeField()
        view.focusKeyboardOnCodeField()
        
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        UserService.sharedInstance.resendCodeWhenChangingNumber(phoneNumber.intlPhoneNumber,
            success: { (device) -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            },
            failure: { (flipError) -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                let alertView = UIAlertView(title: NSLocalizedString("Error when trying to resend verification code"), message: flipError?.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
        )
    }

}
