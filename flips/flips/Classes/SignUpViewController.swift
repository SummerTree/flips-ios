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

class SignUpViewController : FlipsViewController, SignUpViewDelegate, TakePictureViewControllerDelegate {
    
    private var statusBarHidden = false
    private var signUpView: SignUpView!
    private var avatar: UIImage!
    
    var facebookInput: JSON? = nil
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        
        signUpView = SignUpView()
        signUpView.delegate = self
        self.view = signUpView
        
        signUpView.loadView()
        
        if facebookInput != nil {
            signUpView.setUserData(facebookInput!)
            let profilePicture = facebookInput!["picture"]["data"]["url"].stringValue
            signUpView.setUserPictureURL(NSURL(string: profilePicture)!) {
                (image) -> Void in
                self.avatar = image
            }
            signUpView.setPasswordFieldVisible(false)
        }else{
            signUpView.setPasswordFieldVisible(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        signUpView.viewDidAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        signUpView.viewWillDisappear()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    
    // MARK: - SignUpViewDelegate
    
    func signUpViewDidTapBackButton(signUpView: SignUpView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpView(signUpView: SignUpView, didTapNextButtonWith firstName: String, lastName: String, email: String, password: String, birthday: String) {
        
        if (self.avatar == nil) {
            self.signUpView.showMissingPictureMessage()
        } else {
            var actualEmail = email
            var actualPassword = password
            var facebookId: String? = nil
            if self.facebookInput != nil {
                facebookId = self.facebookInput!["id"].stringValue
                if actualEmail.isEmpty {
                    actualEmail = "\(facebookId!)@facebook.com"
                }
                actualPassword = "f\(NSUUID().UUIDString)"
            }
            
            self.signUpView.hideMissingPictureMessage()
            
            var phoneNumberViewController = PhoneNumberViewController(username: actualEmail, password: actualPassword, firstName: firstName, lastName: lastName, avatar: self.avatar, birthday: birthday, nickname: firstName, facebookId: facebookId)
            
            self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
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
    }

}
