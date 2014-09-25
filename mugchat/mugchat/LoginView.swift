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
    
    private let MARGIN_TOP:CGFloat = 40.0
    private let MARGIN_RIGHT:CGFloat = 40.0
    private let MARGIN_BOTTOM:CGFloat = 20.0
    private let MARGIN_LEFT:CGFloat = 40.0

    private let MUGCHAT_WORD_LOGO_MARGIN_TOP: CGFloat = 15.0
    private let MUGCHAT_WORD_ANIMATION_OFFSET: CGFloat = 100.0
    
    private let BUBBLECHAT_IMAGE_ANIMATION_OFFSET: CGFloat = 200.0
    private let CREDENTIALS_MARGIN_TOP: CGFloat = 49.0
    private let CREDENTIALS_ANIMATION_OFFSET: CGFloat = 70.0
    private let EMAIL_MARGIN_LEFT: CGFloat = 15.0
    private let EMAIL_MARGIN_BOTTOM: CGFloat = 12.5
    private let EMAIL_HEIGHT: CGFloat = 44.0
    private let EMAIL_IMAGE_MARGIN_TOP: CGFloat = 10.0
    private let FACEBOOK_MARGIN_TOP: CGFloat = 30.0
    private let PASSWORD_MARGIN_TOP: CGFloat = 12.5
    private let PASSWORD_MARGIN_LEFT: CGFloat = 15.0
    private let PASSWORD_HEIGHT: CGFloat = 44.0
    private let SEPARATOR_HEIGHT: CGFloat = 0.5
    private let SEPARATOR_MARGIN_TOP:CGFloat = 12.5
    private let SIGNUP_MARGIN_TOP: CGFloat = 18.0
    private let SIGNUP_MARGIN_BOTTOM: CGFloat = 14.0
    
    private let PRIVACY_POLICY_MARGIN_LEFT: CGFloat = 20.0
    private let TERMS_OF_SERVICE_MARGIN_LEFT: CGFloat = 60.0

    var logoView: UIView!
    var bubbleChatImageView: UIImageView!
    var mugchatWordImageView: UIImageView!
    var credentialsView: UIView!
    var emailImageView: UIImageView!
    var emailTextField: UITextField!
    var emailPasswordSeparator: UIView!
    var passwordImageView: UIImageView!
    var passwordTextField: UITextField!
    var facebookLogoImage: UIImage!
    var facebookButton: UIButton!
    var signupButton: UIButton!
    var termsOfService: UIButton!
    var privacyPolicy: UIButton!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.updateConstraintsIfNeeded()
    }
    
    func viewDidAppear() {
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.addGestureRecognizer(tapGestureRecognizer)
        
        UIView.animateWithDuration(1.0, animations: {
            self.updateBubbleChatConstraints()
            self.layoutIfNeeded()
        }, completion: { (finish: Bool) in
            UIView.animateWithDuration(0.5, animations: {
                self.setFieldsHidden(false)
            })
        })
    }
    
    func viewWillAppear() {
        self.bubbleChatImageView.center = self.center
        setFieldsHidden(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
        termsOfService.alpha = transparency
        privacyPolicy.alpha = transparency
    }
    
    func addSubviews() {
        
        logoView = UIView()
        self.addSubview(logoView)
        
        bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        bubbleChatImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(bubbleChatImageView)
        
        mugchatWordImageView = UIImageView(image: UIImage(named: "MugChatWord"))
        mugchatWordImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(mugchatWordImageView)
        
        credentialsView = UIView()
        self.addSubview(credentialsView)
        
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
        
        signupButton = UIButton()
        signupButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        signupButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Sign Up", comment: "Sign Up"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)])
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackground"), forState: UIControlState.Normal)
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackgroundTap"), forState: UIControlState.Highlighted)
        signupButton.setTitle(NSLocalizedString("Sign Up", comment: "Sign Up"), forState: UIControlState.Normal)
        self.addSubview(signupButton)
        
        termsOfService = UIButton()
        termsOfService.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        termsOfService.setTitle(NSLocalizedString("Terms of Service", comment: "Terms of Service"), forState: UIControlState.Normal)
        self.addSubview(termsOfService)
        
        privacyPolicy = UIButton()
        privacyPolicy.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        privacyPolicy.setTitle(NSLocalizedString("Privacy Policy", comment: "Privacy Policy"), forState: UIControlState.Normal)
        self.addSubview(privacyPolicy)
    }
    
    func updateBubbleChatConstraints() {
        logoView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.top.equalTo()(self).with().offset()(self.MARGIN_TOP)
            make.leading.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.trailing.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
        }
    }
    
    override func updateConstraints() {
        var height: CGFloat = self.bubbleChatImageView.frame.size.height + self.mugchatWordImageView.frame.size.height
        logoView.mas_updateConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.leading.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.trailing.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
        }

        bubbleChatImageView.mas_updateConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.logoView)
            make.leading.equalTo()(self.logoView)
            make.trailing.equalTo()(self.logoView)
        }
        
        mugchatWordImageView.mas_updateConstraints { (make) -> Void in
            make.centerX.equalTo()(self.bubbleChatImageView.mas_centerX)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(self.MUGCHAT_WORD_LOGO_MARGIN_TOP)
            make.leading.equalTo()(self.logoView)
            make.trailing.equalTo()(self.logoView)
            make.bottom.equalTo()(self.logoView)
        }
        
        termsOfService.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self).with().offset()(self.TERMS_OF_SERVICE_MARGIN_LEFT)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-self.MARGIN_BOTTOM)
        }
        
        privacyPolicy.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self.termsOfService.mas_right).with().offset()(self.PRIVACY_POLICY_MARGIN_LEFT)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-self.MARGIN_BOTTOM)
        }
        
        signupButton.mas_updateConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self.privacyPolicy.mas_top).with().offset()(-self.SIGNUP_MARGIN_BOTTOM)
        }
        
        facebookButton.mas_updateConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self.signupButton.mas_top).with().offset()(-self.SIGNUP_MARGIN_TOP)
        }
        
        credentialsView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.bubbleChatImageView)
            make.bottom.equalTo()(self.facebookButton.mas_top).with().offset()(-self.FACEBOOK_MARGIN_TOP)
            make.trailing.equalTo()(self.bubbleChatImageView)
            make.top.equalTo()(self.emailImageView.mas_top).with().offset()(-self.EMAIL_IMAGE_MARGIN_TOP)
        }
        
        passwordImageView.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self.credentialsView)
            make.width.equalTo()(self.passwordImageView.image?.size.width)
            make.bottom.equalTo()(self.credentialsView)
        }
        
        passwordTextField.mas_updateConstraints { (make) -> Void in
            make.centerY.equalTo()(self.passwordImageView)
            make.left.equalTo()(self.passwordImageView.mas_right).with().offset()(self.PASSWORD_MARGIN_LEFT)
            make.trailing.equalTo()(self.credentialsView)
            make.bottom.equalTo()(self.credentialsView)
        }
        
        emailPasswordSeparator.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self.passwordTextField)
            make.width.equalTo()(self.passwordTextField)
            make.height.equalTo()(self.SEPARATOR_HEIGHT)
            make.bottom.equalTo()(self.passwordTextField.mas_top).with().offset()(-self.PASSWORD_MARGIN_TOP)
        }
        
        emailImageView.mas_updateConstraints { (make) -> Void in
            make.centerY.equalTo()(self.emailTextField)
            make.left.equalTo()(self.credentialsView)
            make.width.equalTo()(self.emailImageView.image?.size.width)
            make.bottom.equalTo()(self.emailPasswordSeparator.mas_top).with().offset()(-self.EMAIL_MARGIN_BOTTOM)
        }
        
        emailTextField.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self.emailImageView.mas_right).with().offset()(self.EMAIL_MARGIN_LEFT)
            make.trailing.equalTo()(self.bubbleChatImageView.mas_right)
            make.bottom.equalTo()(self.emailPasswordSeparator.mas_top).with().offset()(-self.EMAIL_MARGIN_BOTTOM)
        }
        
        super.updateConstraints()
    }
    
    // MARK: Keyboard control
    
    func dismissKeyboard() {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            // next button was pressed
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
            
        } else if (textField == self.passwordTextField) {
            // Done button was pressed
            // TODO: Authenticate?
            self.passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardOffset = getKeyboardOffset(notification)
        
        if (self.bubbleChatImageView.frame.origin.y >= 0) {
            self.slideViews(true, offset: keyboardOffset)
        } else {
            self.slideViews(false, offset: keyboardOffset)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardOffset = getKeyboardOffset(notification)
        if (self.bubbleChatImageView.frame.origin.y >= 0) {
            self.slideViews(true, offset: keyboardOffset)
        } else {
            self.slideViews(false, offset: keyboardOffset)
        }
    }
    
    func slideViews(movedUp: Bool, offset: CGFloat) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        
        if (movedUp) {
            self.bubbleChatImageView.frame.origin.y -= BUBBLECHAT_IMAGE_ANIMATION_OFFSET
            self.mugchatWordImageView.frame.origin.y -= MUGCHAT_WORD_ANIMATION_OFFSET
            self.credentialsView.frame.origin.y -= self.CREDENTIALS_ANIMATION_OFFSET
        } else {
            self.bubbleChatImageView.frame.origin.y += BUBBLECHAT_IMAGE_ANIMATION_OFFSET
            self.mugchatWordImageView.frame.origin.y += MUGCHAT_WORD_ANIMATION_OFFSET
            self.credentialsView.frame.origin.y += CREDENTIALS_ANIMATION_OFFSET
        }
        
        UIView.commitAnimations()
    }

    
    // MARK: Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: Private methods
    private func getKeyboardOffset(notification: NSNotification) -> CGFloat {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardRect: CGRect = userInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue()
        return CGRectGetHeight(keyboardRect)
    }
}