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

class SignUpViewController : MugChatViewController, SignUpViewDelegate {
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        var signUpView = SignUpView()
        signUpView.delegate = self
        self.view = signUpView
    }
    
    
    // MARK: - SignUpViewDelegate

    func signUpViewDidTapBackButton(signUpView: SignUpView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpView(signUpView: SignUpView, didTapNextButtonWith firstName: String, lastName: String, email: String, password: String, birthday: String) {
        println("didTapNextButtonWithUser with \(firstName)")
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "MM-dd-yyyy"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let birthdayDate : NSDate! = dateStringFormatter.dateFromString(birthday)
        
        UserService.sharedInstance.signUp(email, password: password, firstName: firstName, lastName: lastName, birthday: birthdayDate, nickname: firstName, success: { (user) -> Void in
            AuthenticationHelper.sharedInstance.userInSession = user
            var phoneNumberViewController = PhoneNumberViewController()
            self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
        }) { (mugError) -> Void in
            println("Error in the sing up [error=\(mugError!.error), details=\(mugError!.details)]")
            var alertView = UIAlertView(title: "SignUp Error", message: mugError!.error, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
}
