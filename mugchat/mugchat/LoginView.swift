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

    private let MUGCHAT_WORD_LOGO_MARGIN_TOP: CGFloat = 15.0

    private let BUBBLECHAT_IMAGE_ANIMATION_OFFSET: CGFloat = 200.0
    private var LOGO_VIEW_ANIMATION_OFFSET: CGFloat = 100.0
    private var MUGCHAT_WORD_LAST_CENTER_Y: CGFloat!
    private var CREDENTIALS_ANIMATION_OFFSET: CGFloat = 100.0

    private let ACCEPTANCE_VIEW_HEIGHT: CGFloat = 30.0
    private let ANDWORD_MARGIN_LEFT: CGFloat = 2
    private let ANDWORD_MARGIN_RIGHT: CGFloat = 2
    private let EMAIL_MARGIN_LEFT: CGFloat = 15.0
    private let EMAIL_MARGIN_BOTTOM: CGFloat = 12.5
    private let KEYBOARD_MARGIN_TOP: CGFloat = 30.0
    private let MINIMAL_SPACER_HEIGHT: CGFloat = 10.0
    private let PASSWORD_MARGIN_TOP: CGFloat = 12.5
    private let PASSWORD_MARGIN_LEFT: CGFloat = 15.0
    private let PRIVACY_POLICY_HEIGHT: CGFloat = 20.0
    private let SEPARATOR_HEIGHT: CGFloat = 0.5
    private let TERMS_OF_USE_HEIGHT: CGFloat = 20.0
    
    private var logoView: UIView!
    private var bubbleChatImageView: UIImageView!
    private var mugchatWordImageView: UIImageView!
    private var credentialsView: UIView!
    private var emailImageView: UIImageView!
    private var emailTextField: UITextField!
    private var emailPasswordSeparator: UIView!
    private var passwordImageView: UIImageView!
    private var passwordTextField: UITextField!
    private var facebookLogoImage: UIImage!
    private var facebookButton: UIButton!
    private var signupButton: UIButton!
    
    private var acceptanceView: UIView!
    private var acceptTermsPhrase: UILabel!
    private var termsOfUse: UIButton!
    private var andWord: UILabel!
    private var privacyPolicy: UIButton!
    private var isInitialized = false
    
    private var spaceBetweenTopAndMugchat: UIView!
    private var spaceBetweenMugchatAndCredentials: UIView!
    private var spaceBetweenCredentialsAndFacebook: UIView!
    private var spaceBetweenFacebookAndSignUp: UIView!
    private var spaceBetweenSignUpAndAcceptance: UIView!
    
    var delegate: LoginViewDelegate?
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func viewDidAppear() {
        if (!isInitialized) {
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
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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
        
        spaceBetweenTopAndMugchat = UIView()
        self.addSubview(spaceBetweenTopAndMugchat)
        
        logoView = UIView()
        self.addSubview(logoView)
        
        bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        bubbleChatImageView.sizeToFit()
        bubbleChatImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(bubbleChatImageView)
        
        mugchatWordImageView = UIImageView(image: UIImage(named: "MugChatWord"))
        mugchatWordImageView.sizeToFit()
        mugchatWordImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(mugchatWordImageView)
        
        spaceBetweenMugchatAndCredentials = UIView()
        self.addSubview(spaceBetweenMugchatAndCredentials)
        
        credentialsView = UIView()
        self.addSubview(credentialsView)
        
        spaceBetweenCredentialsAndFacebook = UIView()
        self.addSubview(spaceBetweenCredentialsAndFacebook)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail"));
        emailImageView.contentMode = .Center
        credentialsView.addSubview(emailImageView);
        
        emailTextField = UITextField()
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
        emailTextField.delegate = self
        emailTextField.textColor = UIColor.whiteColor()
        emailTextField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "Email"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(emailTextField)
        
        emailPasswordSeparator = UIView()
        emailPasswordSeparator.backgroundColor = UIColor.whiteColor()
        credentialsView.addSubview(emailPasswordSeparator)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password"));
        passwordImageView.contentMode = .Center
        credentialsView.addSubview(passwordImageView);
        
        passwordTextField = UITextField()
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = UIReturnKeyType.Done
        passwordTextField.textColor = UIColor.whiteColor()
        passwordTextField.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        passwordTextField.secureTextEntry = true
        passwordTextField.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Password", comment: "Password"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(passwordTextField)
        
        facebookLogoImage = UIImage(named: "FacebookLogo")
        facebookButton = UIButton()
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
    }
    
    func updateBubbleChatConstraints() {
        logoView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenTopAndMugchat.mas_bottom)
            make.leading.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.trailing.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
        }
    }
    
    func makeConstraints() {
        
        spaceBetweenTopAndMugchat.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self)
            make.leading.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.trailing.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
            make.height.greaterThanOrEqualTo()(self.MARGIN_TOP)
        }
        
        logoView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.leading.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.trailing.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
            make.top.equalTo()(self.bubbleChatImageView)
            make.bottom.equalTo()(self.mugchatWordImageView)
        }

        bubbleChatImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.logoView)
            make.height.equalTo()(self.bubbleChatImageView.frame.size.height)
            make.leading.equalTo()(self.logoView)
            make.trailing.equalTo()(self.logoView)
        }
        
        mugchatWordImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(self.MUGCHAT_WORD_LOGO_MARGIN_TOP)
            make.leading.equalTo()(self.logoView)
            make.trailing.equalTo()(self.logoView)
            make.bottom.equalTo()(self.logoView)
            make.height.equalTo()(self.mugchatWordImageView.frame.height)
        }
        
        spaceBetweenMugchatAndCredentials.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.logoView.mas_bottom)
            make.bottom.equalTo()(self.credentialsView.mas_top)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.greaterThanOrEqualTo()(self.MINIMAL_SPACER_HEIGHT)
        }
        
        credentialsView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.bubbleChatImageView)
            make.trailing.equalTo()(self.bubbleChatImageView)
            make.top.equalTo()(self.spaceBetweenMugchatAndCredentials.mas_bottom)
            make.bottom.equalTo()(self.passwordImageView)
        }
        
        emailImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView)
            make.centerY.equalTo()(self.emailTextField)
            make.leading.equalTo()(self.credentialsView)
            make.width.equalTo()(self.emailImageView.image?.size.width)
            make.bottom.equalTo()(self.emailPasswordSeparator.mas_top).with().offset()(-self.EMAIL_MARGIN_BOTTOM)
        }
        
        emailTextField.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView)
            make.leading.equalTo()(self.emailImageView.mas_right).with().offset()(self.EMAIL_MARGIN_LEFT)
            make.trailing.equalTo()(self.bubbleChatImageView.mas_right)
            make.bottom.equalTo()(self.emailPasswordSeparator.mas_top).with().offset()(-self.EMAIL_MARGIN_BOTTOM)
        }
        
        emailPasswordSeparator.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.passwordTextField)
            make.trailing.equalTo()(self.passwordTextField)
            make.height.equalTo()(self.SEPARATOR_HEIGHT)
            make.bottom.equalTo()(self.passwordTextField.mas_top).with().offset()(-self.PASSWORD_MARGIN_TOP)
        }
        
        passwordImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.passwordTextField)
            make.leading.equalTo()(self.credentialsView)
            make.width.equalTo()(self.passwordImageView.image?.size.width)
            make.bottom.equalTo()(self.credentialsView)
        }
        
        passwordTextField.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.passwordImageView.mas_right).with().offset()(self.PASSWORD_MARGIN_LEFT)
            make.trailing.equalTo()(self.credentialsView)
            make.bottom.equalTo()(self.credentialsView)
        }
        
        spaceBetweenCredentialsAndFacebook.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView.mas_bottom)
            make.leading.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.trailing.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.height.equalTo()(self.spaceBetweenMugchatAndCredentials)
        }

        facebookButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenCredentialsAndFacebook.mas_bottom)
        }

        spaceBetweenFacebookAndSignUp.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.facebookButton.mas_bottom)
            make.leading.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.trailing.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.height.equalTo()(self.spaceBetweenSignUpAndAcceptance)
        }

        signupButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.spaceBetweenFacebookAndSignUp.mas_bottom)
        }

        spaceBetweenSignUpAndAcceptance.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.signupButton.mas_bottom)
            make.bottom.equalTo()(self.acceptanceView.mas_top)
            make.leading.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.trailing.equalTo()(self.spaceBetweenMugchatAndCredentials)
            make.height.equalTo()(20)
        }
        
        acceptanceView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self).with().offset()(-self.MARGIN_BOTTOM)
            make.top.equalTo()(self.spaceBetweenSignUpAndAcceptance.mas_bottom)
            make.trailing.equalTo()(self.signupButton)
            make.leading.equalTo()(self.signupButton)
            make.height.equalTo()(self.ACCEPTANCE_VIEW_HEIGHT)
        }
        
        termsOfUse.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.acceptanceView)
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
    
    func signInButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapSignInButton(self)
    }
    
    func termsOfUseButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapTermsOfUse(self)
    }
    
    func privacyPolicyButtonTapped(sender: AnyObject?) {
        self.delegate?.loginViewDidTapPrivacyPolicy(self)
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
            self.passwordTextField.resignFirstResponder()
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
                
                // positioning above keyboard
                var credentialsFinalPosition = keyboardTop - self.credentialsView.frame.height - self.KEYBOARD_MARGIN_TOP
                self.CREDENTIALS_ANIMATION_OFFSET = self.credentialsView.frame.origin.y - credentialsFinalPosition
                self.credentialsView.frame.origin.y -= self.CREDENTIALS_ANIMATION_OFFSET
                
                // positioning the mug word between the credentials view and top the screen
                var logoFinalPosition = (self.credentialsView.frame.origin.y / 2) - (self.logoView.frame.height / 2)
                
                if (logoFinalPosition < 0) {
                    logoFinalPosition = 0
                }
                
                self.LOGO_VIEW_ANIMATION_OFFSET = self.logoView.frame.origin.y - logoFinalPosition
                self.logoView.frame.origin.y -= self.LOGO_VIEW_ANIMATION_OFFSET
                
                if (DeviceHelper.isDeviceModelLessOrEqualThaniPhone5S()) {
                    self.bubbleChatImageView.frame.origin.y -= self.BUBBLECHAT_IMAGE_ANIMATION_OFFSET
                    self.MUGCHAT_WORD_LAST_CENTER_Y = self.mugchatWordImageView.center.y
                    self.mugchatWordImageView.center.y = self.logoView.center.y
                }
                
            } else {
                self.logoView.frame.origin.y += self.LOGO_VIEW_ANIMATION_OFFSET
                self.credentialsView.frame.origin.y += self.CREDENTIALS_ANIMATION_OFFSET
                
                if (DeviceHelper.isDeviceModelLessOrEqualThaniPhone5S()) {
                    self.bubbleChatImageView.frame.origin.y += self.BUBBLECHAT_IMAGE_ANIMATION_OFFSET
                    self.mugchatWordImageView.center.y = self.MUGCHAT_WORD_LAST_CENTER_Y
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
}