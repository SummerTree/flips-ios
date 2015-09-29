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

import UIKit

class UpdateUserProfileViewController : FlipsViewController, SignUpViewDelegate, UpdateUserProfileViewDelegate, TakePictureViewControllerDelegate, UIAlertViewDelegate {
    
    private var statusBarHidden = false
    private var updateUserProfileView: UpdateUserProfileView!
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
        
        if let loggedUser = User.loggedUser() {
            if let urlString = loggedUser.photoURL {
                if let url = NSURL(string: urlString) {
                    self.updateUserProfileView.setUserPictureURL(url)
                }
            }
            
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            updateUserProfileView.setUser(loggedUser)

        }
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
        let takePictureViewController = TakePictureViewController()
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
    }
    
    
    // MARK: - UpdateUserProfileViewDidTapSaveButton
    
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapSaveButtonWith firstName: String, lastName: String, email: String, password: String, avatar: UIImage!) {
        self.showActivityIndicator()

        UserService.sharedInstance.update(email, password: password, firstName: firstName, lastName: lastName, avatar: avatar,
            success: { (user) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
                self.hideActivityIndicator()
            }) { (flipError) -> Void in
                self.hideActivityIndicator()
                let alertView = UIAlertView(title: NSLocalizedString("Error updating user"), message: flipError?.details, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
        }
    }
    
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapBackButton withEditions: Bool) {
        if (!withEditions) {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            let alertView = UIAlertView(
                title: NSLocalizedString("Discard Changes"),
                message: NSLocalizedString("Going back without tapping 'Save' will discard your changes.\nDo you wish to discard any changes you have made?"),
                delegate: self,
                cancelButtonTitle: nil,
                otherButtonTitles: NSLocalizedString("No"), NSLocalizedString("Discard"))
            
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

