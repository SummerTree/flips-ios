//
// Copyright 2015 ArcTouch, Inc.
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
    private var facebookInput: JSON? = nil
    
    init(facebookInput: JSON? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.facebookInput = facebookInput
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        
        signUpView = SignUpView()
        signUpView.delegate = self
        self.view = signUpView
        
        signUpView.loadView()
        
        if (facebookInput != nil) {
            signUpView.setUserData(facebookInput!)
            
            let isSilhouette = facebookInput!["picture"]["data"]["is_silhouette"]
            var userHasPicture = true
            if (isSilhouette != nil) {
                userHasPicture = !isSilhouette.boolValue
            }
            
            if (userHasPicture) {
                let profilePicture = facebookInput!["picture"]["data"]["url"].stringValue
                signUpView.setUserPictureURL(NSURL(string: profilePicture)!) {
                    (image) -> Void in
                    self.avatar = image
                }
            }
            
            signUpView.setPasswordFieldVisible(false)
        } else {
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
        
        if (self.avatar == nil)
        {
            self.avatar = UIImage(named: "ChatBubble")
        }

        var actualPassword = password
        var facebookId: String? = nil
        if (self.facebookInput != nil) {
            facebookId = self.facebookInput!["id"].stringValue
            actualPassword = "f\(NSUUID().UUIDString)"
        }
        
        self.signUpView.hideMissingPictureMessage()
        
        let phoneNumberViewController = PhoneNumberViewController(username: email, password: actualPassword, firstName: firstName, lastName: lastName, avatar: self.avatar, birthday: birthday, nickname: firstName, facebookId: facebookId)
        
        self.navigationController?.pushViewController(phoneNumberViewController, animated: true)

    }
    
    func signUpView(signUpView: SignUpView, setStatusBarHidden hidden: Bool) {
        statusBarHidden = hidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func signUpViewDidTapTakePictureButton(signUpView: SignUpView) {
        let takePictureViewController = TakePictureViewController()
        takePictureViewController.delegate = self
        self.navigationController?.pushViewController(takePictureViewController, animated: true)
    }
    
    
    // MARK: - TakePictureViewControllerDelegate
    
    func takePictureViewController(viewController: TakePictureViewController, didFinishWithPicture picture: UIImage) {
        signUpView.setUserPicture(picture)
        self.avatar = picture
    }

}
