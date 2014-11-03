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

class SplashScreenViewController: UIViewController, SplashScreenViewDelegate {
    
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
        var success = FBSession.openActiveSessionWithAllowLoginUI(false)
        println("User is already authenticated with Facebook? \(success)")
        if (success) {
            UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
                success: { (user) -> Void in
                    AuthenticationHelper.sharedInstance.userInSession = user as User
                    
                    var userDataSource = UserDataSource()
                    userDataSource.syncUserData({ (success, error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (success) {
                                let authenticatedUser = AuthenticationHelper.sharedInstance.userInSession
                                if (authenticatedUser.device == nil) {
                                    self.openPhoneNumberController(authenticatedUser.userID)
                                } else {
                                    self.openInboxViewController()
                                }
                            }
                        })
                    })
                }, failure: { (mugError) -> Void in
                    println("Error on authenticating with Facebook [error=\(mugError!.error), details=\(mugError!.details)]")
                    var alertView = UIAlertView(title: "Login Error", message: mugError!.error, delegate: self, cancelButtonTitle: "OK")
                    alertView.show()
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
                    if (success) {
                        self.openInboxViewController()
                    }
                })
            })
        } else {
            openLoginViewController()
        }
    }
    
    private func openInboxViewController() {
        var inboxViewController = InboxViewController()
        self.navigationController?.pushViewController(inboxViewController, animated: true)
    }
    
    private func openLoginViewController() {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var loginViewController = LoginViewController()
            self.navigationController?.pushViewController(loginViewController, animated: false)
//        })
    }
    
    private func openPhoneNumberController(userID: String) {
        var phoneNumberViewController = PhoneNumberViewController(userId: userID)
        self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}