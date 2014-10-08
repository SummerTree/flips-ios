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
        
    override func loadView() {
        super.loadView()
        phoneNumberView = PhoneNumberView()
        phoneNumberView.delegate = self
        self.view = phoneNumberView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        phoneNumberView.viewDidAppear()
        phoneNumberView.focusKeyboardOnMobileNumberField()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        phoneNumberView.viewWillDisappear()
    }
    
    
    // MARK: - PhoneNumberViewDelegate Methods
    
    func phoneNumberView(phoneNumberView: PhoneNumberView!, didFinishTypingMobileNumber mobileNumber: String!) {
        var verificationCodeViewController = VerificationCodeViewController(phoneNumber: mobileNumber)
        self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    func phoneNumberViewDidTapBackButton(view: PhoneNumberView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    
}
