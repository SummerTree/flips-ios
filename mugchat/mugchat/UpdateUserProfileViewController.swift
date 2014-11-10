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

class UpdateUserProfileViewController : MugChatViewController, SignUpViewDelegate, UpdateUserProfileViewDelegate, TakePictureViewControllerDelegate, UIAlertViewDelegate {
    
    private var statusBarHidden = false
    private var updateUserProfileView: UpdateUserProfileView!
    private var avatar: UIImage!
    private var notificationMessageView: NotificationMessageView!
    
    
    // MARK: - Overriden Methods
    
    override func loadView() {
        super.loadView()
        updateUserProfileView = UpdateUserProfileView()
        updateUserProfileView.delegate = self
        updateUserProfileView.updateUserProfileViewDelegate = self
        self.view = updateUserProfileView
        
        updateUserProfileView.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let userPictureData = NSData(contentsOfURL: NSURL(string: User.loggedUser()!.photoURL)!)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateUserProfileView.setUserPicture(UIImage(data: userPictureData!)!)
            })
        })
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.BlackOpaque, animated: false)
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        updateUserProfileView.setUser(User.loggedUser()!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUserProfileView.viewDidAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        updateUserProfileView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarHidden
    }
    
    
    // MARK: - SignUpViewDelegate
    
    func signUpViewDidTapTakePictureButton(signUpView: SignUpView) {
        var takePictureViewController = TakePictureViewController()
        takePictureViewController.delegate = self
        self.navigationController?.pushViewController(takePictureViewController, animated: true)
    }
    
    func signUpView(signUpView: SignUpView, setStatusBarHidden hidden: Bool) {
        statusBarHidden = hidden
        self.setNeedsStatusBarAppearanceUpdate()
    }

    
    // MARK: - TakePictureViewControllerDelegate
    
    func takePictureViewController(viewController: TakePictureViewController, didFinishWithPicture picture: UIImage) {
        updateUserProfileView.setUserPicture(picture)
        self.avatar = picture
    }
    
    
    // MARK: - UpdateUserProfileViewDidTapSaveButton
    
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapSaveButtonWith firstName: String, lastName: String, email: String, password: String, birthday: String) {
        self.showActivityIndicator()
        UserService.sharedInstance.update(email, password: password, firstName: firstName, lastName: lastName, avatar: nil, birthday: birthday.dateValue(),
            success: { (user) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
                self.hideActivityIndicator()
            }) { (mugError) -> Void in
                self.hideActivityIndicator()
                let alertView = UIAlertView(title: "Error updating user", message: mugError?.error!, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
        }
    }
    
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapBackButton withEditions: Bool) {
        
        if (!withEditions) {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let alertView = UIAlertView(
                title: "Discard Changes",
                message: "Going back without tapping 'Save' will discard your changes.\nDo you wish to discard any changes you have made?",
                delegate: self,
                cancelButtonTitle: nil,
                otherButtonTitles: "No", "Discard")
            
            alertView.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let buttonTitle: String! = alertView.buttonTitleAtIndex(buttonIndex)
        
        if (buttonTitle == "Discard") {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}

