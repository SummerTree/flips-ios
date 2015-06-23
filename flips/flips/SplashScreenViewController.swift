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

import Foundation

private let LOGIN_ERROR = NSLocalizedString("Login Error", comment: "Login Error")
private let RETRY = NSLocalizedString("Retry", comment: "Retry")

let LOGOUT_NOTIFICATION_NAME: String = "logout_notification"
let LOGOUT_NOTIFICATION_PARAM_FACEBOOK_USER_KEY: String = "logout_notification_facebook_user"
let LOGOUT_NOTIFICATION_PARAM_FIRST_NAME_KEY: String = "logout_notification_first_name"

class SplashScreenViewController: FlipsViewController, UIAlertViewDelegate {
    
    var loginMode: LoginViewController.LoginMode = LoginViewController.LoginMode.ORDINARY_LOGIN
    var userFirstName: String? = nil
    
    private var roomIdToShow: String?
    private var flipMessageIdToShow: String?
    
    // MARK: - Initialization Method
    
    init(roomID: String?, flipMessageID: String?) {
        super.init(nibName: nil, bundle: nil)
        self.roomIdToShow = roomID
        self.flipMessageIdToShow = flipMessageID
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        let splashScreenView = SplashScreenView()
        self.view = splashScreenView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Dispatching cause we need to wait until the SplashScreen is done being pushed before pushing another controller.
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded) {
                self.splashScreenViewAttemptLoginWithFacebook()
            } else {
                self.splashScreenViewAttemptLogin()
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logoutNotificationReceived:", name: LOGOUT_NOTIFICATION_NAME, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LOGOUT_NOTIFICATION_NAME, object: nil)
    }
    
    func splashScreenViewAttemptLoginWithFacebook() {
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.onLogin(user as! User)
                PersistentManager.sharedInstance.syncUserData({ (success, flipError) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let authenticatedUser = User.loggedUser() {
                            if (!self.userHasDevice(authenticatedUser)) {
                                self.openPhoneNumberController(authenticatedUser.userID)
                            } else {
                                self.openInboxViewController()
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
                AuthenticationHelper.sharedInstance.logout() // Make sure that app state is clean
                self.openLoginViewController()
        })
    }
    
    func splashScreenViewAttemptLogin() {
        if let loggedUser = User.loggedUser() {
            AuthenticationHelper.sharedInstance.onLogin(loggedUser)
            PersistentManager.sharedInstance.syncUserData({ (success, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.openInboxViewController()
                })
            })
        } else {
            AuthenticationHelper.sharedInstance.logout() // Make sure that app state is clean
            openLoginViewController()
        }
    }
    
    func logoutNotificationReceived(notification: NSNotification) {
        let userInfo: Dictionary = notification.userInfo!
        let facebookUserLoggedOut = userInfo[LOGOUT_NOTIFICATION_PARAM_FACEBOOK_USER_KEY] as! Bool
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
    
    private func openInboxViewController() {
        var inboxViewController = InboxViewController(roomID: self.roomIdToShow, flipMessageID: self.flipMessageIdToShow)
        self.navigationController?.pushViewController(inboxViewController, animated: true)
    }
    
    private func openPhoneNumberController(userID: String) {
        var phoneNumberViewController = PhoneNumberViewController(userId: userID)
        self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
    }
    
    private func userHasDevice(user: User) -> Bool {
        var userHasPhone = user.phoneNumber != nil
        var phoneNumberLength = count(user.phoneNumber)
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
