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

    override init(phoneNumber: String!) {
        super.init(nibName: nil, bundle: nil)
        self.phoneNumber = phoneNumber
        
        
        //let userId = AuthenticationHelper.sharedInstance.userInSession.id!
        //let trimmedPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("-", withString: "", options: //NSStringCompareOptions.LiteralSearch, range: nil)
        //let intlPhoneNumber = "\(US_CODE)\(trimmedPhoneNumber)"
        //let token = DeviceHelper.sharedInstance.retrieveDeviceToken()!
        
        //createDeviceForUser(userId, phoneNumber: intlPhoneNumber, platform: PLATFORM, token: token)
    }
    
    
    override func verificationCodeView(verificatioCodeView: VerificationCodeView!, didFinishTypingVerificationCode verificationCode: String!) {
        
        //TODO: extract method on the superclass:
        /*if (verificationCode != self.verificationCode) {
            self.retryCount++
            verificationCodeView.resetVerificationCodeField()
            verificationCodeView.showKeyboard()
            if (self.retryCount > 2) {
                self.resendVerificationCode(AuthenticationHelper.sharedInstance.userInSession.id!, deviceId: DeviceHelper.sharedInstance.retrieveDeviceId()!)
            }
        } else {*/
            var newPasswordViewController = NewPasswordViewController()
            self.navigationController?.pushViewController(newPasswordViewController, animated: true)
        //}
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
}