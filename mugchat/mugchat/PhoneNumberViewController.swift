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

class PhoneNumberViewController: MugChatViewController, PhoneNumberViewDelegate {
    
    var phoneNumberView: PhoneNumberView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberView = PhoneNumberView()
        self.view = phoneNumberView
    }
    
    // MARK: - ForgotPasswordViewDelegate Methods
    func phoneNumberViewDidFinishTypingMobileNumber(view: PhoneNumberView!) {
        //TODO: open VerificationCode screen (story 7153)
        //var verificationCodeViewController = VerificationCodeViewController()
        //self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    
    func phoneNumberViewDidTapBackButton() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
//    // MARK: - Notifications
//    func keyboardOnScreen(notification: NSNotification) {
//        if let info = notification.userInfo {
//            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
//            phoneNumberView.keyboardHeight = keyboardFrame.height
//            phoneNumberView.updateConstraints()
//        }
//    }
    
    
    // MARK: - Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    
}
