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

private let LOGIN_ERROR = NSLocalizedString("Login Error", comment: "Login Error")


class LoginViewController: FlipsViewController, LoginViewDelegate {
    
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
        
        self.loginView = LoginView()
        self.loginView.delegate = self
        self.view = loginView
        
        setupActivityIndicator()
        self.loginView.viewDidLoad()
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
        showActivityIndicator()
        UserService.sharedInstance.signIn(username, password: password, success: { (user) -> Void in

            if (user == nil) {
                self.loginView.showValidationErrorInCredentialFields()
            }
            
            var authenticatedUser: User = user as User!
            AuthenticationHelper.sharedInstance.userInSession = user as User
            
            var userDataSource = UserDataSource()
            userDataSource.syncUserData({ (success, error) -> Void in
                self.hideActivityIndicator()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (success) {
                        var inboxViewController = InboxViewController()
                        inboxViewController.userDataSource = userDataSource
                        self.navigationController?.pushViewController(inboxViewController, animated: true)
                    }
                })
            })
        }) { (flipError) -> Void in
            self.hideActivityIndicator()
            println(flipError!.error)
            self.loginView.showValidationErrorInCredentialFields()
        }
    }
    
    func loginViewDidTapSignUpButton(loginView: LoginView!) {
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    func loginViewDidTapForgotPassword(loginView: LoginView!, username: String) {
        loginView.dismissKeyboard()
        var forgotPasswordViewController = ForgotPasswordViewController(username: username)
        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
    }
    
    func loginViewDidTapFacebookSignInButton(loginView: LoginView!) {

        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession().state == FBSessionState.Open
         || FBSession.activeSession().state == FBSessionState.OpenTokenExtended) {
            
            println("User is already authenticated with session = \(FBSession.activeSession().accessTokenData.accessToken)")
            
            authenticateWithFacebook() {
                (flipError) -> Void in
                println("Error on authenticating with Facebook [error=\(flipError!.error), details=\(flipError!.details)]")
                self.hideActivityIndicator()
                var alertView = UIAlertView(title: LOGIN_ERROR, message: flipError!.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
            return
        }
        
        // If the session state is not any of the two "open" states when the button is clicked
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        var scope = ["public_profile", "email", "user_birthday", "user_friends"]
        FBSession.openActiveSessionWithReadPermissions(scope, allowLoginUI: true,
            completionHandler: { (session, state, error) -> Void in
                if error != nil {
                    if state == FBSessionState.ClosedLoginFailed {
                        println("Error opening facebook session, user denied")
                    } else {
                        println("Error opening facebook session, state: \(state)")
                    }
                    return
                }
                
                self.authenticateWithFacebook() {
                    (flipError) -> Void in
                    self.hideActivityIndicator()
                    if flipError != nil {
                        println("Error on authenticating with Facebook [error=\(flipError!.error), details=\(flipError!.details)]")
                        var alertView = UIAlertView(title: LOGIN_ERROR, message: flipError!.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    } else {
                        //no error message, assuming User Not Found
                        self.showActivityIndicator()
                        UserService.sharedInstance.getFacebookUserInfo({ (userObject) -> Void in
                            self.hideActivityIndicator()
                            println("User not found, going to Sign Up View")
                            let signUpController = SignUpViewController()
                            signUpController.facebookInput = userObject
                            self.navigationController?.pushViewController(signUpController, animated: true)
                        }, failure: { (flipError) -> Void in
                            self.hideActivityIndicator()
                            println("Error on authenticating with Facebook [error=\(flipError!.error), details=\(flipError!.details)]")
                            var alertView = UIAlertView(title: LOGIN_ERROR, message: flipError!.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                            alertView.show()
                        })
                    }
                }
        })
    }
    
    // MARK: - Private methods
    
    private func authenticateWithFacebook(failureHandler: (FlipError?) -> Void) {
        showActivityIndicator()
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.userInSession = user as User
                
                var userDataSource = UserDataSource()
                userDataSource.syncUserData({ (success, error) -> Void in
                    self.hideActivityIndicator()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let authenticatedUser = User.loggedUser()!
                        if (authenticatedUser.device == nil) {
                            var phoneNumberViewController = PhoneNumberViewController(userId: authenticatedUser.userID)
                            self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
                        } else {
                            var inboxViewController = InboxViewController()
                            inboxViewController.userDataSource = userDataSource
                            self.navigationController?.pushViewController(inboxViewController, animated: true)
                        }
                    })
                })
            },
            failure: failureHandler)
    }
    
}
