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
    
    /*override init() {
        super.init()
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }*/
    
    /*override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forgotPasswordView = ForgotPasswordView()
        forgotPasswordView.delegate = self
        self.view = forgotPasswordView
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
        super.viewWillDisappear(animated)
    }
    
    
    func forgotPasswordViewDidFinishTypingMobileNumber(forgotPassword: ForgotPasswordView!) {
        //TODO: open VerificationCode screen (story 7153)
        //var verificationCodeViewController = VerificationCodeViewController()
        //self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    
    // MARK: - Notifications
    func keyboardOnScreen(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            forgotPasswordView.keyboardHeight = keyboardFrame.height
            forgotPasswordView.updateConstraints()
        }
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}

