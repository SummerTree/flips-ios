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

class VerificationCodeViewController: MugChatViewController, VerificationCodeViewDelegate {
    
    var verificationCodeView: VerificationCodeView!
    var phoneNumber: String!
    
    override func loadView() {
        super.loadView()
        verificationCodeView = VerificationCodeView(phoneNumber: phoneNumber)
        verificationCodeView.delegate = self
        self.view = verificationCodeView
    }
    
    // MARK: - ForgotPasswordViewDelegate Methods
    
    func didFinishTypingVerificationCode(view: VerificationCodeView!) {
        //var verificationCodeViewController = VerificationCodeViewController()
        //self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
    }
    
    
    func didTapBackButton(view: VerificationCodeView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func didTapResendButton(view: VerificationCodeView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(phoneNumber: String!) {
        super.init(nibName: nil, bundle: nil)
        self.phoneNumber = phoneNumber
    }
    
}
