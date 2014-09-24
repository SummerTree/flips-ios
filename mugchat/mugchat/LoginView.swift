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

class LoginView : UIView {
    
    private let MARGIN_TOP:CGFloat = 40.0
    private let MARGIN_RIGHT:CGFloat = 40.0
    private let MARGIN_BOTTOM:CGFloat = 20.0
    private let MARGIN_LEFT:CGFloat = 40.0
    
    private let CREDENTIALS_MARGIN_TOP:CGFloat = 49.0
    private let EMAIL_MARGIN_LEFT:CGFloat = 15.0
    private let FACEBOOK_MARGIN_TOP:CGFloat = 30.0
    private let PASSWORD_MARGIN_TOP:CGFloat = 12.5
    private let SEPARATOR_HEIGHT:CGFloat = 0.5
    private let SEPARATOR_MARGIN_TOP:CGFloat = 12.5
    private let SIGNUP_MARGIN_TOP:CGFloat = 18
    
    private let PRIVACY_POLICY_MARGIN_LEFT: CGFloat = 20
    private let TERMS_OF_SERVICE_MARGIN_LEFT:CGFloat = 60

    
    var bubbleChatImageView: UIImageView!
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
        self.makeContraints()
    }
    
    func viewDidAppear() {
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
        bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        bubbleChatImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(bubbleChatImageView)
        
        credentialsView = UIView()
        self.addSubview(credentialsView)
        
        emailImageView = UIImageView(image: UIImage(named: "Mail"));
        credentialsView.addSubview(emailImageView);
        
        emailTextField = UITextField()
        emailTextField.textColor = UIColor.whiteColor()
        emailTextField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email", comment: "Email"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(emailTextField)
        
        emailPasswordSeparator = UIView()
        emailPasswordSeparator.backgroundColor = UIColor.whiteColor()
        credentialsView.addSubview(emailPasswordSeparator)
        
        passwordImageView = UIImageView(image: UIImage(named: "Password"));
        credentialsView.addSubview(passwordImageView);
        
        passwordTextField = UITextField()
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
        bubbleChatImageView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.top.equalTo()(self).with().offset()(self.MARGIN_TOP)
        }
    }
    
    func makeContraints() {
        bubbleChatImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.left.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
        }
        
        credentialsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.bubbleChatImageView.mas_left)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(self.CREDENTIALS_MARGIN_TOP)
            make.trailing.equalTo()(self.bubbleChatImageView.mas_right)
            make.bottom.equalTo()(self.passwordTextField.mas_bottom)
        }
        
        emailImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.credentialsView)
            make.left.equalTo()(self.credentialsView)
            make.width.equalTo()(self.emailImageView.image?.size.width)
        }
        
        emailTextField.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.emailImageView.mas_centerY)
            make.left.equalTo()(self.emailImageView.mas_right).with().offset()(self.EMAIL_MARGIN_LEFT)
            make.trailing.equalTo()(self.bubbleChatImageView.mas_right)
        }
        
        emailPasswordSeparator.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailTextField.mas_bottom).with().offset()(self.SEPARATOR_MARGIN_TOP)
            make.left.equalTo()(self.emailTextField.mas_left)
            make.width.equalTo()(self.emailTextField.mas_width)
            make.height.equalTo()(self.SEPARATOR_HEIGHT)
        }
        
        passwordImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailPasswordSeparator.mas_bottom).with().offset()(self.PASSWORD_MARGIN_TOP)
            make.left.equalTo()(self.emailImageView.mas_left)
            make.right.equalTo()(self.emailImageView.mas_right)
        }
        
        passwordTextField.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.passwordImageView.mas_centerY)
            make.left.equalTo()(self.emailTextField)
            make.trailing.equalTo()(self.emailTextField)
        }
        
        facebookButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.passwordTextField.mas_bottom).with().offset()(self.FACEBOOK_MARGIN_TOP)
        }
        
        signupButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.facebookButton.mas_bottom).with().offset()(self.SIGNUP_MARGIN_TOP)
        }
        
        termsOfService.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self).with().offset()(self.TERMS_OF_SERVICE_MARGIN_LEFT)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-self.MARGIN_BOTTOM)
        }
        
        privacyPolicy.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.termsOfService.mas_right).with().offset()(self.PRIVACY_POLICY_MARGIN_LEFT)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-self.MARGIN_BOTTOM)
        }
    }
    
    // MARK: Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}