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

class LoginViewController: MugChatViewController, LoginViewDelegate {
    
    var loginView: LoginView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loginView.viewWillDisappear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loginView.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView = LoginView()
        loginView.delegate = self
        self.view = loginView
        loginView.viewDidLoad()
    }
    
    
    // MARK: - LoginViewDelegate Methods
    
    func loginViewDidTapTermsOfUse(loginView: LoginView!) {
        var termsOfUseViewController = TermsOfUseViewController()
        self.navigationController?.pushViewController(termsOfUseViewController, animated: true)
    }
    
    func loginViewDidTapPrivacyPolicy(loginView: LoginView!) {
        var privacyPolicyViewController = PrivacyPolicyViewController()
        self.navigationController?.pushViewController(privacyPolicyViewController, animated: true)
    }
    
    func loginViewDidTapSignInButton(loginView: LoginView!, username: String, password: String) {
        UserService.sharedInstance.signIn(username, password: password, success: { (user) -> Void in

            if (user == nil) {
                self.loginView.showValidationErrorInCredentialFields()
            }
            
            var authenticatedUser: User = user as User!
            AuthenticationHelper.sharedInstance.userInSession = user as User

            var inboxViewController = InboxViewController()
            self.navigationController?.pushViewController(inboxViewController, animated: true)
            
        }) { (mugError) -> Void in
            println(mugError!.error)
            self.loginView.showValidationErrorInCredentialFields()
        }
    }
    
    func loginViewDidTapSignUpButton(loginView: LoginView!) {
        self.navigationController?.pushViewController(ComposeViewController(), animated: true)
    }
    
    func loginViewDidTapForgotPassword(loginView: LoginView!, username: String) {
        var forgotPasswordViewController = ForgotPasswordViewController(username: username)
        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func loginViewDidTapFacebookSignInButton(loginView: LoginView!) {

        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession().state == FBSessionState.Open
         || FBSession.activeSession().state == FBSessionState.OpenTokenExtended) {
            
            println("User is already authenticated with session = \(FBSession.activeSession().accessTokenData.accessToken)")
            
            authenticateWithFacebook(FBSession.activeSession().accessTokenData.accessToken)
        }
        
        // If the session state is not any of the two "open" states when the button is clicked
        if (FBSession.activeSession().state != FBSessionState.Closed) {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            var scope = ["public_profile", "email", "user_birthday", "user_friends"]
            FBSession.openActiveSessionWithReadPermissions(scope, allowLoginUI: true,
                completionHandler: { (session, state, error) -> Void in
                    if (error != nil || session == nil || session!.accessTokenData == nil) {
                        println("Error authenticating: \(error)")
                    } else {
                        self.authenticateWithFacebook(session!.accessTokenData.accessToken)
                    }
            })
        }
    }
    

    // MARK: - Private methods
    
    private func authenticateWithFacebook(token: String) {
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.userInSession = user as User
                var inboxViewController = InboxViewController()
                self.navigationController?.pushViewController(inboxViewController, animated: true)
                
            }, failure: { (mugError) -> Void in
                println("Error on authenticating with Facebook [error=\(mugError!.error), details=\(mugError!.details)]")
                var alertView = UIAlertView(title: "Login Error", message: mugError!.error, delegate: self, cancelButtonTitle: "OK")
                alertView.show()
        })
    }

}
