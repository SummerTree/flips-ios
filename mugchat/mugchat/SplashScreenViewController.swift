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
        splashScreenView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashScreenView.delegate = self
        
        self.view = splashScreenView
    }
    
    
    // MARK: SplashScreenViewDelegate methods
    
    func splashScreenViewAttemptLoginWithFacebook(sender: SplashScreenView) {
        var success = FBSession.openActiveSessionWithAllowLoginUI(false)
        println("User is already authenticated with Facebook? \(success)")
        if (success) {
            UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
                success: { (user) -> Void in
                    AuthenticationHelper.sharedInstance.userInSession = user as User
                    self.openInboxViewController()
                    
                }, failure: { (mugError) -> Void in
                    println("Error on authenticating with Facebook [error=\(mugError!.error), details=\(mugError!.details)]")
                    var alertView = UIAlertView(title: "Login Error", message: mugError!.error, delegate: self, cancelButtonTitle: "OK")
                    alertView.show()
            })
        }
    }
    
    func splashScreenViewAttemptLogin(sender: SplashScreenView) {
        // TODO: we need to validate the cookies to se if the it is expired or not. And in the logout, it will be good to delete it.
        var loggedUser = User.loggedUser()
        if (loggedUser != nil) {
            AuthenticationHelper.sharedInstance.userInSession = loggedUser
            self.openInboxViewController()
        } else {
            openLoginViewController()
        }
    }
    
    private func openInboxViewController() {
        var inboxViewController = InboxViewController()
        self.navigationController?.pushViewController(inboxViewController, animated: true)
    }
    
    private func openLoginViewController() {
        var loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}