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
let NO_USER_IN_SESSION_ERROR = NSLocalizedString("No user in session", comment: "No user in session.")
let NO_USER_IN_SESSION_MESSAGE = NSLocalizedString("Please try again or contact support.", comment: "Please try again or contact support.")

class LoginViewController: FlipsViewController, LoginViewDelegate {
    
    internal enum LoginMode {
        case ORDINARY_LOGIN
        case LOGIN_AGAIN_WITH_FACEBOOK
    }
    
    var loginView: LoginView!
    var loginMode: LoginMode = .ORDINARY_LOGIN
    var userFirstName: String? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginView.viewWillAppear()
        loginView.setLoginMode(loginMode, firstName: userFirstName)
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
        let returnValue = UserService.sharedInstance.signIn(username, password: password, success: { (user) -> Void in
            if (user == nil) {
                self.hideActivityIndicator()
                self.loginView.showValidationErrorInCredentialFields()
                return
            }
            
            var authenticatedUser: User = user as User!
            AuthenticationHelper.sharedInstance.onLogin(authenticatedUser)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                PersistentManager.sharedInstance.syncUserData({ (success, FlipError) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.hideActivityIndicator()
                        if (success) {
                            self.navigationController?.pushViewController(InboxViewController(), animated: true)
                        }
                    })
                })
            })
        }) { (flipError) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.hideActivityIndicator()
                self.loginView.showValidationErrorInCredentialFields(error: flipError)
            })
        }
        
        if (returnValue == FlipsService.ReturnValue.WAITING_FOR_RESPONSE) {
            showActivityIndicator()
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
        
        FBSession.activeSession().closeAndClearTokenInformation()
        
        // You must ALWAYS ask for public_profile permissions when opening a session
        var scope = ["public_profile", "email", "user_birthday", "user_friends"]
        FBSession.openActiveSessionWithReadPermissions(scope, allowLoginUI: true,
            completionHandler: { (session, state, error) -> Void in
                if (error == nil && (state == FBSessionState.Closed || state == FBSessionState.ClosedLoginFailed)) {
                    return
                }
                
                if (error != nil) {
                    if state == FBSessionState.ClosedLoginFailed {
                        println("Error opening facebook session: \(error)")
                    } else {
                        println("Error opening facebook session, state: \(state), error: \(error)")
                    }
                    return
                }
                
                self.showActivityIndicator()
                self.authenticateWithFacebook() { (flipError) -> Void in
                    let errorHandler: (FlipError?) -> Void = { (flipError) -> Void in
                        self.hideActivityIndicator()
                        println("Error on authenticating with Facebook [error=\(flipError!.error), details=\(flipError!.details)]")
                        var alertView = UIAlertView(title: LOGIN_ERROR, message: flipError!.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    }
                    
                    if (flipError != nil) {
                        errorHandler(flipError)
                    } else {
                        //no error message, assuming User Not Found
                        UserService.sharedInstance.getFacebookUserInfo({ (userObject) -> Void in
                            self.hideActivityIndicator()
                            println("User not found, going to Sign Up View")
                            let signUpController = SignUpViewController(facebookInput: userObject)
                            self.navigationController?.pushViewController(signUpController, animated: true)
                        }, failure: { (flipError) -> Void in
                            errorHandler(flipError)
                        })
                    }
                }
        })
    }
    
    func setLoginViewMode(loginMode: LoginMode, userFirstName: String?) {
        self.loginMode = loginMode
        self.userFirstName = userFirstName
    }
    
    // MARK: - Private methods
    
    private func authenticateWithFacebook(failureHandler: (FlipError?) -> Void) {
        UserService.sharedInstance.signInWithFacebookToken(FBSession.activeSession().accessTokenData.accessToken,
            success: { (user) -> Void in
                AuthenticationHelper.sharedInstance.onLogin(user as User)
                PersistentManager.sharedInstance.syncUserData({ (success, flipError) -> Void in
                    self.hideActivityIndicator()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let authenticatedUser = User.loggedUser() {
                            if (authenticatedUser.device == nil) {
                                var phoneNumberViewController = PhoneNumberViewController(userId: authenticatedUser.userID)
                                self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
                            } else {
                                self.navigationController?.pushViewController(InboxViewController(), animated: true)
                            }
                        } else {
                            self.hideActivityIndicator()
                            var alertView = UIAlertView(title: NO_USER_IN_SESSION_ERROR, message: NO_USER_IN_SESSION_MESSAGE, delegate: self, cancelButtonTitle: LocalizedString.OK)
                            alertView.show()
                        }
                    })
                })
            },
        failure: failureHandler)
    }
    
}
