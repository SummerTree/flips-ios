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

class LoginView : UIView, UITextFieldDelegate {
    
    private let MARGIN_TOP:CGFloat = 25.0
    private let MARGIN_RIGHT:CGFloat = 40.0
    private let MARGIN_BOTTOM:CGFloat = 10.0
    private let MARGIN_LEFT:CGFloat = 40.0

    private let FLIPS_WORD_LOGO_MARGIN_TOP: CGFloat = 15.0
    private var FLIPS_WORD_LOGO_POSITION_WHEN_ERROR: CGFloat! = 20.0
    private var FLIPS_WORD_ANIMATION_OFFSET: CGFloat!

    private let BUBBLECHAT_IMAGE_ANIMATION_OFFSET: CGFloat = 200.0
    private var LOGO_VIEW_ANIMATION_OFFSET: CGFloat = 100.0
    private var CREDENTIALS_ANIMATION_OFFSET: CGFloat = 100.0
    private var FORGOT_PASSWORD_ANIMATION_OFFSET: CGFloat!

    private let ACCEPTANCE_VIEW_HEIGHT: CGFloat = 30.0
    private let ANDWORD_MARGIN_LEFT: CGFloat = 2
    private let ANDWORD_MARGIN_RIGHT: CGFloat = 2
    private let EMAIL_MARGIN_LEFT: CGFloat = 15.0
    private let EMAIL_MARGIN_BOTTOM: CGFloat = 12.5
    private let FORGOT_PASSWORD_MARGIN_TOP: CGFloat = 10
    private let FORGOT_PASSWORD_MARGIN_BOTTOM: CGFloat = 15
    private let KEYBOARD_MARGIN_TOP: CGFloat = 30.0
    private let MINIMAL_SPACER_HEIGHT: CGFloat = 10.0
    private let PASSWORD_MARGIN_TOP: CGFloat = 12.5
    private let PASSWORD_MARGIN_LEFT: CGFloat = 15.0
    private let PRIVACY_POLICY_HEIGHT: CGFloat = 20.0
    private let SEPARATOR_HEIGHT: CGFloat = 0.5
    private let SIGNUP_MARGIN_BOTTOM: CGFloat = 15.0
    private let TERMS_OF_USE_HEIGHT: CGFloat = 20.0
    
    private var logoView: UIView!
    private var bubbleChatImageView: UIImageView!
    private var flipsWordImageView: UIImageView!
    private var credentialsView: UIView!
    private var emailImageView: UIImageView!
    private var emailTextField: UITextField!
    private var emailPasswordSeparator: UIView!
    private var passwordImageView: UIImageView!
    private var passwordTextField: UITextField!
    private var facebookLogoImage: UIImage!
    private var facebookButton: UIButton!
    private var signupButton: UIButton!
    private var forgotPasswordImage: UIImage!
    private var forgotPasswordButton: UIButton!
    
    private var acceptanceView: UIView!
    private var acceptTermsPhrase: UILabel!
    private var termsOfUse: UIButton!
    private var andWord: UILabel!
    private var privacyPolicy: UIButton!
    private var isInitialized = false
    
    private var spaceBetweenTopAndFlips: UIView!
    private var spaceBetweenFlipsAndCredentials: UIView!
    private var spaceBetweenCredentialsAndFacebook: UIView!
    private var spaceBetweenFacebookAndSignUp: UIView!
    private var spaceBetweenSignUpAndAcceptance: UIView!
    private var spaceBetweenEmailFieldAndSeparator: UIView!
    private var spaceBetweenPasswordFieldAndSeparator: UIView!
 
    private var isInformedWrongPassword: Bool = false
    
    private var animator: UIDynamicAnimator!
    
    var delegate: LoginViewDelegate?
    
    override init() {
        super.init()
        
        self.animator = UIDynamicAnimator(referenceView: self)
        self.backgroundColor = UIColor.flipOrange()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func viewDidAppear() {
        if (!isInitialized) {
            self.layoutIfNeeded()
            UIView.animateWithDuration(1.0, animations: {
                self.updateBubbleChatConstraints()
                self.layoutIfNeeded()
            }, completion: { (finish: Bool) in
                UIView.animateWithDuration(0.5, animations: {
                    self.setFieldsHidden(false)
                })
            })
            
            self.isInitialized = true
        } else {
            self.updateBubbleChatConstraints()
            self.layoutIfNeeded()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func viewDidLoad() {
        self.logoView.center = self.center
        setFieldsHidden(true)
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.addGestureRecognizer(tapGestureRecognizer)
        
        self.emailTextField.text = AuthenticationHelper.sharedInstance.retrieveAuthenticatedUsernameIfExists()
    }
    
    func viewWillAppear() {
        self.isInformedWrongPassword = false
        self.forgotPasswordButton.alpha = 0.0
        self.emailTextField.rightView?.alpha = 0.0
        self.passwordTextField.rightView?.alpha = 0.0
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        self.passwordTextField.text = nil
    }
    
    func showValidationErrorInCredentialFields() {
        
        if (!self.isInformedWrongPassword) {
            self.isInformedWrongPassword = true
        
            self.emailTextField.rightView = UIImageView(image: UIImage(named: "Error"))
            self.emailTextField.rightView?.alpha = 0.0
            
            self.passwordTextField.rightView = UIImageView(image: UIImage(named: "Error"))
            self.passwordTextField.rightView?.alpha = 0.0
            
            UIView.animateWithDuration(1.0, animations: {
                self.emailTextField.rightView?.alpha = 1.0
                self.passwordTextField.rightView?.alpha = 1.0
                self.forgotPasswordButton.alpha = 1.0
            })
        }
        
        UIView.animateWithDuration(1.0, animations: {
            var shakeAnimation = CABasicAnimation(keyPath: "position")
            shakeAnimation.duration = 0.075
            shakeAnimation.repeatCount = 3
            shakeAnimation.autoreverses = true
            shakeAnimation.fromValue = NSValue(CGPoint: CGPointMake(self.credentialsView.center.x - 30.0, self.credentialsView.center.y))
            shakeAnimation.toValue = NSValue(CGPoint: CGPointMake(self.credentialsView.center.x + 30.0, self.credentialsView.center.y))
            
            self.credentialsView.layer.addAnimation(shakeAnimation, forKey: "position")
        })
    }
    
    func setFieldsHidden(hidden: Bool) {
        var transparency: CGFloat = 1.0
        if (hidden) {
            transparency = 0.0
        }
        
        credentialsView.alpha = transparency
        facebookButton.alpha = transparency
        signupButton.alpha = transparency
        acceptanceView.alpha = transparency
    }
    
    func addSubviews() {
        
        spaceBetweenTopAndFlips = UIView()
        self.addSubview(spaceBetweenTopAndFlips)
        
        logoView = UIView()
        self.addSubview(logoView)
        
        bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        bubbleChatImageView.sizeToFit()
        bubbleChatImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(bubbleChatImageView)
        
        flipsWordImageView = UIImageView(image: UIImage(named: "MugChatWord"))
        flipsWordImageView.sizeToFit()
        flipsWordImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(flipsWordImageView)
        
        spaceBetweenFlipsAndCredentials = UIView()
        self.addSubview(spaceBetweenFlipsAndCredentials)
        
        credentialsView = UIView()
        self.addSubview(credentialsView)
        
        spaceBetweenCredentialsAndFacebook = UIView()
        self.addSubview(spaceBetweenCredentialsAndFacebook)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail"));
        emailImageView.contentMode = .Center
        credentialsView.addSubview(emailImageView);
        
        emailTextField = UITextField()
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
        emailTextField.delegate = self
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        emailTextField.adjustsFontSizeToFitWidth = true
        emailTextField.rightViewMode = UITextFieldViewMode.Always
        emailTextField.textColor = UIColor.whiteColor()
        emailTextField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "Email"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(emailTextField)
        
        emailPasswordSeparator = UIView()
        var separatorRecognizer = UITapGestureRecognizer(target: self, action: "separatorTapped")
        emailPasswordSeparator.addGestureRecognizer(separatorRecognizer)
        emailPasswordSeparator.backgroundColor = UIColor.whiteColor()
        credentialsView.addSubview(emailPasswordSeparator)
        
        spaceBetweenEmailFieldAndSeparator = UIView()
        var emailSpaceViewRecognizer = UITapGestureRecognizer(target: self, action: "spaceBetweenEmailAndSeparatorTapped")
        spaceBetweenEmailFieldAndSeparator.addGestureRecognizer(emailSpaceViewRecognizer)
        credentialsView.addSubview(spaceBetweenEmailFieldAndSeparator)
        
        spaceBetweenPasswordFieldAndSeparator = UIView()
        var passwordSpaceViewRecognizer = UITapGestureRecognizer(target: self, action: "spaceBetweenPasswordAndSeparatorTapped")
        spaceBetweenPasswordFieldAndSeparator.addGestureRecognizer(passwordSpaceViewRecognizer)
        credentialsView.addSubview(spaceBetweenPasswordFieldAndSeparator)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password"));
        passwordImageView.contentMode = .Center
        credentialsView.addSubview(passwordImageView);
        
        passwordTextField = UITextField()
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = UIReturnKeyType.Done
        passwordTextField.rightViewMode = UITextFieldViewMode.Always
        passwordTextField.textColor = UIColor.whiteColor()
        passwordTextField.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        passwordTextField.secureTextEntry = true
        passwordTextField.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Password", comment: "Password"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(passwordTextField)
        
        facebookLogoImage = UIImage(named: "FacebookLogo")
        facebookButton = UIButton()
        facebookButton.addTarget(self, action: "facebookSignInTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        facebookButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 60.0)
        facebookButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        facebookButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Login with Facebook", comment: "Login with Facebook"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        facebookButton.setBackgroundImage(UIImage(named: "FacebookButtonBackground"), forState: UIControlState.Normal)
        facebookButton.setBackgroundImage(UIImage(named: "FacebookButtonBackgroundTap"), forState: UIControlState.Highlighted)
        facebookButton.setImage(facebookLogoImage, forState: UIControlState.Normal)
        facebookButton.setImage(facebookLogoImage, forState: UIControlState.Highlighted)
        facebookButton.setTitle(NSLocalizedString("Login with Facebook", comment: "Login with Facebook"), forState: UIControlState.Normal)
        self.addSubview(facebookButton)
        
        spaceBetweenFacebookAndSignUp = UIView()
        self.addSubview(spaceBetweenFacebookAndSignUp)
        
        signupButton = UIButton()
        signupButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        signupButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Sign Up", comment: "Sign Up"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)])
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackground"), forState: UIControlState.Normal)
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackgroundTap"), forState: UIControlState.Highlighted)
        signupButton.setTitle(NSLocalizedString("Sign Up", comment: "Sign Up"), forState: UIControlState.Normal)
        signupButton.addTarget(self, action: "signUpButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(signupButton)
        
        spaceBetweenSignUpAndAcceptance = UIView()
        self.addSubview(spaceBetweenSignUpAndAcceptance)
        
        acceptanceView = UIView()
        self.addSubview(acceptanceView)
        
        acceptTermsPhrase = UILabel()
        acceptTermsPhrase.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h7)
        acceptTermsPhrase.text = "By signing up you agree to our"
        acceptTermsPhrase.textColor = UIColor.whiteColor()
        acceptanceView.addSubview(self.acceptTermsPhrase)
        
        termsOfUse = UIButton()
        termsOfUse.addTarget(self, action: "termsOfUseButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        termsOfUse.titleLabel?.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h7)
        termsOfUse.setTitle(NSLocalizedString("Terms of Use", comment: "Terms of Use"), forState: UIControlState.Normal)
        acceptanceView.addSubview(termsOfUse)
        
        andWord = UILabel()
        andWord.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h7)
        andWord.text = "&"
        andWord.textColor = UIColor.whiteColor()
        acceptanceView.addSubview(andWord)
        
        privacyPolicy = UIButton()
        privacyPolicy.addTarget(self, action: "privacyPolicyButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        privacyPolicy.titleLabel?.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h7)
        privacyPolicy.setTitle(NSLocalizedString("Privacy Policy", comment: "Privacy Policy"), forState: UIControlState.Normal)
        acceptanceView.addSubview(privacyPolicy)
        
        forgotPasswordImage = UIImage(named: "ForgotPassword")
        forgotPasswordButton = UIButton()
        forgotPasswordButton.addTarget(self, action: "forgotPasswordButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        forgotPasswordButton.alpha = 0.0
        forgotPasswordButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 60.0)
        forgotPasswordButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        forgotPasswordButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Forgot Password", comment: "Forgot Password"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextMedium(UIFont.HeadingSize.h4)])
        forgotPasswordButton.setBackgroundImage(UIImage(named: "ForgotButton"), forState: UIControlState.Normal)
        forgotPasswordButton.setBackgroundImage(UIImage(named: "ForgotButtonTap"), forState: UIControlState.Highlighted)
        forgotPasswordButton.setImage(forgotPasswordImage, forState: UIControlState.Normal)
        forgotPasswordButton.setImage(forgotPasswordImage, forState: UIControlState.Highlighted)
        forgotPasswordButton.setTitle(NSLocalizedString("Forgot Password", comment: "Forgot Password"), forState: UIControlState.Normal)
        self.addSubview(forgotPasswordButton)
    }
    
    func updateBubbleChatConstraints() {
        logoView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenTopAndFlips.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
        }
    }
    
    func makeConstraints() {
        
        spaceBetweenTopAndFlips.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self)
            make.left.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
            make.height.greaterThanOrEqualTo()(self.MARGIN_TOP)
        }
        
        logoView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.left.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
            make.top.equalTo()(self.bubbleChatImageView)
            make.bottom.equalTo()(self.flipsWordImageView)
        }

        bubbleChatImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.logoView)
            make.height.equalTo()(self.bubbleChatImageView.frame.size.height)
            make.left.equalTo()(self.logoView)
            make.right.equalTo()(self.logoView)
        }
        
        flipsWordImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(self.FLIPS_WORD_LOGO_MARGIN_TOP)
            make.left.equalTo()(self.logoView)
            make.right.equalTo()(self.logoView)
            make.bottom.equalTo()(self.logoView)
            make.height.equalTo()(self.flipsWordImageView.frame.height)
        }
        
        spaceBetweenFlipsAndCredentials.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.logoView.mas_bottom)
            make.bottom.equalTo()(self.credentialsView.mas_top)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.greaterThanOrEqualTo()(self.MINIMAL_SPACER_HEIGHT)
        }
        
        forgotPasswordButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self.credentialsView.mas_top).with().offset()(-self.FORGOT_PASSWORD_MARGIN_BOTTOM)
        }
        
        credentialsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.bubbleChatImageView)
            make.right.equalTo()(self.bubbleChatImageView)
            make.top.equalTo()(self.spaceBetweenFlipsAndCredentials.mas_bottom)
            make.bottom.equalTo()(self.passwordTextField)
        }
        
        emailImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.emailTextField)
            make.left.equalTo()(self.credentialsView)
            make.width.equalTo()(self.emailImageView.frame.size.width)
            make.height.equalTo()(self.emailImageView.frame.size.height)
        }
        
        emailTextField.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView)
            make.left.equalTo()(self.emailImageView.mas_right).with().offset()(self.EMAIL_MARGIN_LEFT)
            make.right.equalTo()(self.bubbleChatImageView.mas_right)
            make.bottom.equalTo()(self.spaceBetweenEmailFieldAndSeparator.mas_top)
        }
        
        spaceBetweenEmailFieldAndSeparator.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailTextField.mas_bottom)
            make.height.equalTo()(self.EMAIL_MARGIN_BOTTOM)
            make.left.equalTo()(self.emailTextField)
            make.right.equalTo()(self.emailTextField)
        }
        
        emailPasswordSeparator.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.spaceBetweenEmailFieldAndSeparator.mas_bottom)
            make.left.equalTo()(self.passwordTextField)
            make.right.equalTo()(self.passwordTextField)
            make.height.equalTo()(self.SEPARATOR_HEIGHT)
        }
        
        spaceBetweenPasswordFieldAndSeparator.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailPasswordSeparator.mas_bottom)
            make.height.equalTo()(self.spaceBetweenEmailFieldAndSeparator)
            make.left.equalTo()(self.passwordTextField)
            make.right.equalTo()(self.passwordTextField)
        }
        
        passwordImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.passwordTextField)
            make.left.equalTo()(self.credentialsView)
            make.width.equalTo()(self.passwordImageView.frame.size.width)
            make.height.equalTo()(self.passwordImageView.frame.size.height)
        }
        
        passwordTextField.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.spaceBetweenPasswordFieldAndSeparator.mas_bottom)
            make.left.equalTo()(self.passwordImageView.mas_right).with().offset()(self.PASSWORD_MARGIN_LEFT)
            make.right.equalTo()(self.credentialsView)
            make.bottom.equalTo()(self.credentialsView)
        }
        
        spaceBetweenCredentialsAndFacebook.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView.mas_bottom)
            make.left.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.right.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.height.equalTo()(self.spaceBetweenFlipsAndCredentials)
        }

        facebookButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenCredentialsAndFacebook.mas_bottom)
        }

        spaceBetweenFacebookAndSignUp.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.facebookButton.mas_bottom)
            make.left.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.right.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.height.equalTo()(self.spaceBetweenSignUpAndAcceptance)
        }

        signupButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenFacebookAndSignUp.mas_bottom)
        }

        spaceBetweenSignUpAndAcceptance.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.signupButton.mas_bottom)
            make.bottom.equalTo()(self.acceptanceView.mas_top)
            make.left.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.right.equalTo()(self.spaceBetweenFlipsAndCredentials)
            make.height.equalTo()(self.SIGNUP_MARGIN_BOTTOM)
        }
        
        acceptanceView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self).with().offset()(-self.MARGIN_BOTTOM)
            make.top.equalTo()(self.spaceBetweenSignUpAndAcceptance.mas_bottom)
            make.right.equalTo()(self.signupButton)
            make.left.equalTo()(self.signupButton)
            make.height.equalTo()(self.ACCEPTANCE_VIEW_HEIGHT)
        }
        
        termsOfUse.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.acceptanceView)
            make.height.equalTo()(self.TERMS_OF_USE_HEIGHT)
            make.bottom.equalTo()(self.acceptanceView)
        }
        
        andWord.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.termsOfUse.mas_right).with().offset()(self.ANDWORD_MARGIN_LEFT)
            make.centerY.equalTo()(self.termsOfUse)
            make.trailing.equalTo()(self.privacyPolicy.mas_left).with().offset()(-self.ANDWORD_MARGIN_RIGHT)
            make.bottom.equalTo()(self.acceptanceView)
        }
        
        privacyPolicy.mas_makeConstraints { (make) -> Void in
            make.trailing.equalTo()(self.acceptanceView)
            make.height.equalTo()(self.PRIVACY_POLICY_HEIGHT)
            make.bottom.equalTo()(self.acceptanceView)
        }
        
        acceptTermsPhrase.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.acceptanceView)
            make.centerX.equalTo()(self.signupButton)
        }
        
        super.updateConstraints()
    }
    
    
    // MARK: - Buttons delegate
    
    func facebookSignInTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapFacebookSignInButton(self)
    }
    
    func signInButtonTapped(sender: AnyObject?) {
        
        if (self.emailTextField.text.isEmpty || self.passwordTextField.text.isEmpty) {
            var alertMessage = UIAlertView(title: NSLocalizedString("Login Error", comment: "Login Error"), message: NSLocalizedString("Please complete both fields.", comment: "Please complete both fields."), delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
            return
        }
        
        self.delegate?.loginViewDidTapSignInButton(self, username: self.emailTextField.text, password: self.passwordTextField.text)
    }
    
    func termsOfUseButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapTermsOfUse(self)
    }
    
    func privacyPolicyButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapPrivacyPolicy(self)
    }
    
    func forgotPasswordButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapForgotPassword(self, username: emailTextField.text)
    }
    
    func signUpButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapSignUpButton(self)
    }
    
    
    // MARK: - Keyboard control
    
    func dismissKeyboard() {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            // next button was pressed
            self.passwordTextField.becomeFirstResponder()
            
        } else if (textField == self.passwordTextField) {
            // Done button was pressed
            self.signInButtonTapped(self)
        }
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardMinY = getKeyboardMinY(notification)
        self.slideViews(true, keyboardTop: keyboardMinY)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardMinY = getKeyboardMinY(notification)
        self.slideViews(false, keyboardTop: keyboardMinY)
    }
    
    func slideViews(movedUp: Bool, keyboardTop: CGFloat) {
        UIView.animateWithDuration(0.75, animations: { () -> Void in
            if (movedUp) {
                self.forgotPasswordButton.alpha = 1.0
                
                // positioning credentials above keyboard
                var credentialsFinalPosition = keyboardTop - self.credentialsView.frame.height - self.KEYBOARD_MARGIN_TOP
                self.CREDENTIALS_ANIMATION_OFFSET = self.credentialsView.frame.origin.y - credentialsFinalPosition
                self.credentialsView.frame.origin.y -= self.CREDENTIALS_ANIMATION_OFFSET
                
                if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone5S()) {
                    // positioning Flips word below the top of the screen with a defined offset
                    var flipsWordFinalPosition = self.FLIPS_WORD_LOGO_POSITION_WHEN_ERROR
                    self.FLIPS_WORD_ANIMATION_OFFSET = self.flipsWordImageView.frame.origin.y - flipsWordFinalPosition
                    self.flipsWordImageView.frame.origin.y -= self.FLIPS_WORD_ANIMATION_OFFSET
                    self.bubbleChatImageView.frame.origin.y -= self.BUBBLECHAT_IMAGE_ANIMATION_OFFSET
                }
                
                // positioning forgot password button between credentials and Flips word
                var forgotPasswordFinalPosition = (self.credentialsView.center.y + self.flipsWordImageView.frame.origin.y) / 2
                self.FORGOT_PASSWORD_ANIMATION_OFFSET = self.forgotPasswordButton.frame.origin.y - forgotPasswordFinalPosition
                self.forgotPasswordButton.center.y -= self.FORGOT_PASSWORD_ANIMATION_OFFSET
                
            } else {
                self.forgotPasswordButton.alpha = 0.0
                self.credentialsView.frame.origin.y += self.CREDENTIALS_ANIMATION_OFFSET
                self.forgotPasswordButton.center.y += self.FORGOT_PASSWORD_ANIMATION_OFFSET
                if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone5S()) {
                    self.bubbleChatImageView.frame.origin.y += self.BUBBLECHAT_IMAGE_ANIMATION_OFFSET
                    self.flipsWordImageView.frame.origin.y += self.FLIPS_WORD_ANIMATION_OFFSET
                }
            }
        })
    }

    
    // MARK: - Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    // MARK: - Private methods
    
    private func getKeyboardMinY(notification: NSNotification) -> CGFloat {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardRect: CGRect = userInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue()
        return CGRectGetMaxY(self.frame) - CGRectGetHeight(keyboardRect)
    }
    
    func spaceBetweenEmailAndSeparatorTapped() {
        self.emailTextField.becomeFirstResponder()
    }
    
    func spaceBetweenPasswordAndSeparatorTapped() {
        self.passwordTextField.becomeFirstResponder()
    }
    
    func separatorTapped() {
        // do nothing - its just to avoid the keyboard dismissing
    }
}


// MARK: View Delegate

protocol LoginViewDelegate {
    
    func loginViewDidTapTermsOfUse(loginView: LoginView!)
    func loginViewDidTapPrivacyPolicy(loginView: LoginView!)
    func loginViewDidTapSignInButton(loginView: LoginView!, username: String, password: String)
    func loginViewDidTapFacebookSignInButton(loginView: LoginView!)
    func loginViewDidTapSignUpButton(loginView: LoginView!)
    func loginViewDidTapForgotPassword(loginView: LoginView!, username: String)
}