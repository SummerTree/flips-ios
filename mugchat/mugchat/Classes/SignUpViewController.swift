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

class SignUpViewController : MugChatViewController, SignUpViewDelegate, TakePictureViewControllerDelegate {
    
    private var statusBarHidden = false
    private var signUpView: SignUpView!
    private var avatar: UIImage!
    
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        signUpView = SignUpView()
        signUpView.delegate = self
        self.view = signUpView
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    
    // MARK: - SignUpViewDelegate
    
    func signUpViewDidTapBackButton(signUpView: SignUpView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpView(signUpView: SignUpView, didTapNextButtonWith firstName: String, lastName: String, email: String, password: String, birthday: String) {
        
        self.showActivityIndicator()
        
        UserService.sharedInstance.signUp(email, password: password, firstName: firstName, lastName: lastName, avatar: self.avatar, birthday: birthday.dateValue(), nickname: firstName, success: { (user) -> Void in
            self.hideActivityIndicator()
            AuthenticationHelper.sharedInstance.userInSession = user
            var phoneNumberViewController = PhoneNumberViewController()
            self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
        }) { (mugError) -> Void in
            self.hideActivityIndicator()
            println("Error in the sign up [error=\(mugError!.error), details=\(mugError!.details)]")
            var alertView = UIAlertView(title: "SignUp Error", message: mugError!.error, delegate: self, cancelButtonTitle: "OK")
            alertView.show()
        }
    }
    
    func signUpView(signUpView: SignUpView, setStatusBarHidden hidden: Bool) {
        statusBarHidden = hidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func signUpViewDidTapTakePictureButton(signUpView: SignUpView) {
        var takePictureViewController = TakePictureViewController()
        takePictureViewController.delegate = self
        self.navigationController?.pushViewController(takePictureViewController, animated: true)
    }
    
    
    // MARK: - TakePictureViewControllerDelegate
    
    func takePictureViewController(viewController: TakePictureViewController, didFinishWithPicture picture: UIImage) {
        signUpView.setUserPicture(picture)
        self.avatar = picture
        self.navigationController?.popViewControllerAnimated(true)
    }
}
