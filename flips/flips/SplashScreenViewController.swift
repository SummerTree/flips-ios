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


class SplashScreenViewController: UIViewController, SplashScreenViewDelegate, UIAlertViewDelegate {
    
    let splashScreenView = SplashScreenView()
    
    
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
    }
    
    
    // MARK: SplashScreenViewDelegate methods
    
    func splashScreenViewAttemptLoginWithFacebook() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = .plum()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        var success = FBSession.openActiveSessionWithAllowLoginUI(false)
        println("User is already authenticated with Facebook? \(success)")
        if (success) {
            UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
                success: { (user) -> Void in
                    AuthenticationHelper.sharedInstance.userInSession = user as User
                    
                    var userDataSource = UserDataSource()
                    userDataSource.syncUserData({ (success, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            activityIndicator.stopAnimating()
                            
                            let authenticatedUser = User.loggedUser()!
                            if (self.userHasDevice(authenticatedUser)) {
                                self.openInboxViewController(userDataSource)
                            } else {
                                self.openPhoneNumberController(authenticatedUser.userID)
                            }
                        })
                    })
                }, failure: { (flipError) -> Void in
                    
                    FBSession.activeSession().closeAndClearTokenInformation()
                    FBSession.activeSession().close()
                    FBSession.setActiveSession(nil)
                    
                    if (flipError != nil) {
                        println("Error on authenticating with Facebook [error=\(flipError!.error), details=\(flipError!.details)]")
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            var alertView = UIAlertView(title: LOGIN_ERROR, message: "Error: \(flipError!.error)\nDetail: \(flipError!.details)", delegate: self, cancelButtonTitle: "Retry")
                            alertView.show()
                        })
                    }
                    
                    activityIndicator.stopAnimating()
            })
        }
    }
    
    func splashScreenViewAttemptLogin() {
        // TODO: we need to validate the cookies to se if the it is expired or not. And in the logout, it will be good to delete it.
        var loggedUser = User.loggedUser()
        if (loggedUser != nil) {
            AuthenticationHelper.sharedInstance.userInSession = loggedUser
            var userDataSource = UserDataSource()
            userDataSource.syncUserData({ (success, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.openInboxViewController(userDataSource)
                })
            })
        } else {
            openLoginViewController()
        }
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
    
    private func openLoginViewController() {
        var loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: false)
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
