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
        self.navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
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
            AuthenticationHelper.sharedInstance.userInSession = user
            AuthenticationHelper.sharedInstance.saveAuthenticatedUsername(authenticatedUser.username!)

            var inboxViewController = InboxViewController()
            self.navigationController?.pushViewController(inboxViewController, animated: true)
            
        }) { (mugError) -> Void in
            println(mugError!.error)
            self.loginView.showValidationErrorInCredentialFields()
        }
    }
    
    func loginViewDidTapFacebookSignInButton(loginView: LoginView!) {

        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession().state == FBSessionState.Open || FBSession.activeSession().state == FBSessionState.OpenTokenExtended) {
            
            println("User is already authenticated with session = \(FBSession.activeSession().accessTokenData.accessToken)")
            
            authenticateWithFacebook(FBSession.activeSession().accessTokenData.accessToken)
        }
        // If the session state is not any of the two "open" states when the button is clicked
        else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
            var scope = ["public_profile", "email", "user_birthday"]
            FBSession.openActiveSessionWithReadPermissions(scope, allowLoginUI: true,
                completionHandler: { (session, state, error) -> Void in
                    self.authenticateWithFacebook(session!.accessTokenData.accessToken)
                    println("Facebook Login with session: \(FBSession.activeSession().accessTokenData.accessToken)")
            })
        }
    }
    

    // MARK: - Private methods
    
    private func authenticateWithFacebook(token: String) {
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.userInSession = user
                var inboxViewController = InboxViewController()
                self.navigationController?.pushViewController(inboxViewController, animated: true)
                
            }, failure: { (mugError) -> Void in
                println(mugError!.error)
        })
    }
}
