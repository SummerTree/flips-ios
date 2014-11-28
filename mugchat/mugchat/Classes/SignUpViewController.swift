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

class SignUpViewController : MugChatViewController, SignUpViewDelegate, TakePictureViewControllerDelegate, NotificationMessageViewDelegate {
    
    private var statusBarHidden = false
    private var signUpView: SignUpView!
    private var avatar: UIImage!
    private var notificationMessageView: NotificationMessageView!
    
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        signUpView = SignUpView()
        signUpView.delegate = self
        self.view = signUpView
        
        signUpView.loadView()
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
            self.showNoPictureMessage()
        } else {
            var phoneNumberViewController = PhoneNumberViewController(username: email, password: password, firstName: firstName, lastName: lastName, avatar: self.avatar, birthday: birthday, nickname: firstName)
            
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
    
    
    // MARK: - NotificationMessageView Methods
    
    func setupNotificationMessage() {
        notificationMessageView = NotificationMessageView(message: NSLocalizedString("Hey, faceless wonder!  Looks like your Flip is missing!", comment: "Hey, faceless wonder!  Looks like your Flip is missing!"))
        notificationMessageView.backgroundColor = UIColor.clearColor()
        notificationMessageView.delegate = self
        self.view.addSubview(notificationMessageView)
        
        notificationMessageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.view).with().offset()(-self.notificationMessageView.getMessageAreaHeight())
            make.leading.equalTo()(self.view)
            make.trailing.equalTo()(self.view)
            make.height.equalTo()(self.view)
        }
    }
    
    func showNoPictureMessage() {
        if (notificationMessageView == nil) {
            self.setupNotificationMessage()
        }
        self.notificationMessageView.hidden = false
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.notificationMessageView.mas_updateConstraints { (update) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self.view)
                update.leading.equalTo()(self.view)
                update.trailing.equalTo()(self.view)
                update.height.equalTo()(self.view)
            }
            self.statusBarHidden = true
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.layoutIfNeeded()
        })
    }
    
    func hideNoPictureMessage() {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.notificationMessageView.mas_updateConstraints { (update) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self.view).with().offset()(-self.notificationMessageView.getMessageAreaHeight())
                update.leading.equalTo()(self.view)
                update.trailing.equalTo()(self.view)
                update.height.equalTo()(self.view)
            }
            self.statusBarHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            self.notificationMessageView.hidden = true
        }
    }
    
    
    // MARK: - NotificationMessageViewDelegate
    
    func notificationMessageViewShouldBeDismissed(view: NotificationMessageView) {
        self.hideNoPictureMessage()
    }
}
