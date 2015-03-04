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

private let LOGIN_ERROR = NSLocalizedString("Login Error", comment: "Login Error")
private let RETRY = NSLocalizedString("Retry", comment: "Retry")

let LOGOUT_NOTIFICATION_NAME: String = "logout_notification"
let LOGOUT_NOTIFICATION_PARAM_FACEBOOK_USER_KEY: String = "logout_notification_facebook_user"
let LOGOUT_NOTIFICATION_PARAM_FIRST_NAME_KEY: String = "logout_notification_first_name"

class SplashScreenViewController: UIViewController, SplashScreenViewDelegate, UIAlertViewDelegate {
    
    let splashScreenView = SplashScreenView()
    var loginMode: LoginViewController.LoginMode = LoginViewController.LoginMode.ORDINARY_LOGIN
    var userFirstName: String? = nil
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded) {
            splashScreenViewAttemptLoginWithFacebook()
        } else {
            splashScreenViewAttemptLogin()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashScreenView.delegate = self
        
        self.view = splashScreenView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logoutNotificationReceived:", name: LOGOUT_NOTIFICATION_NAME, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LOGOUT_NOTIFICATION_NAME, object: nil)
    }
    
    // MARK: SplashScreenViewDelegate methods
    
    func splashScreenViewAttemptLoginWithFacebook() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = .plum()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.onLogin(user as User)
                
                PersistentManager.sharedInstance.syncUserData({ (success, flipError, userDataSource) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        activityIndicator.stopAnimating()
                        if let authenticatedUser = User.loggedUser() {
                            if (!self.userHasDevice(authenticatedUser)) {
                                self.openPhoneNumberController(authenticatedUser.userID)
                            } else {
                                self.openInboxViewController(userDataSource)
                            }
                        } else {
                            var alertView = UIAlertView(title: NO_USER_IN_SESSION_ERROR, message: NO_USER_IN_SESSION_MESSAGE, delegate: self, cancelButtonTitle: LocalizedString.OK)
                            alertView.show()
                        }
                    })
                })
            },
            failure: { (flipError) -> Void in
                println("Error signing in with Facebook: \(flipError)")
                self.openLoginViewController()
        })
    }
    
    func splashScreenViewAttemptLogin() {
        if let loggedUser = User.loggedUser() {
            println("loggedUser \(loggedUser)")
            println("userID \(loggedUser.userID)");
            AuthenticationHelper.sharedInstance.onLogin(loggedUser)
            PersistentManager.sharedInstance.syncUserData({ (success, error, userDataSource) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.openInboxViewController(userDataSource)
                })
            })
        } else {
            openLoginViewController()
        }
    }
    
    func logoutNotificationReceived(notification: NSNotification) {
        let userInfo: Dictionary = notification.userInfo!
        let facebookUserLoggedOut = userInfo[LOGOUT_NOTIFICATION_PARAM_FACEBOOK_USER_KEY] as Bool
        loginMode = facebookUserLoggedOut ? .LOGIN_AGAIN_WITH_FACEBOOK : .ORDINARY_LOGIN
        userFirstName = facebookUserLoggedOut ? (userInfo[LOGOUT_NOTIFICATION_PARAM_FIRST_NAME_KEY] as String) : nil
    }
    
    func openLoginViewController() {
        let loginViewController = LoginViewController()
        loginViewController.setLoginViewMode(loginMode, userFirstName: userFirstName)
        self.navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        splashScreenViewAttemptLogin()
    }
    
    private func openInboxViewController(userDataSource: UserDataSource) {
        var inboxViewController = InboxViewController()
        inboxViewController.userDataSource = userDataSource
        self.navigationController?.pushViewController(inboxViewController, animated: true)
    }
    
    private func openPhoneNumberController(userID: String) {
        var phoneNumberViewController = PhoneNumberViewController(userId: userID)
        self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
    }
    
    private func userHasDevice(user: User) -> Bool {
        var userHasPhone = user.phoneNumber != nil
        var phoneNumberLength = countElements(user.phoneNumber)
        var isDeviceVerified: Bool = false
        
        if let isVerified = user.device.isVerified {
            isDeviceVerified = user.device.isVerified.boolValue
        }
        
        return userHasPhone && (phoneNumberLength > 0) && isDeviceVerified
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
