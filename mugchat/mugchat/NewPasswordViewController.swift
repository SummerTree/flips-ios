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

class NewPasswordViewController: MugChatViewController, NewPasswordViewDelegate {
    
    var newPasswordView: NewPasswordView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newPasswordView = NewPasswordView()
        newPasswordView.delegate = self
        self.view = newPasswordView
    }
    
    
    // MARK: - NewPasswordViewDelegate Methods
    func newPasswordViewDidTapDoneButton(newPassword: NewPasswordView!) {
        //TODO: save new password to the back-end, and return user to login window to sign in with email address and new password.
        //var loginViewController = LoginViewController()
        //self.navigationController?.pushViewController(loginViewController, animated: true)
    }
  
    func newPasswordViewDidTapBackButton(newPassword: NewPasswordView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
