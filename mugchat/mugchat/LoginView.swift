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
        addSubviews()
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
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
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
        passwordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        credentialsView.addSubview(passwordTextField)
        
        facebookLogoImage = UIImage(named: "FacebookLogo")
        facebookButton = UIButton()
        facebookButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 60.0)
        facebookButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        facebookButton.titleLabel?.attributedText = NSAttributedString(string:"Login with Facebook", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        facebookButton.setBackgroundImage(UIImage(named: "FacebookButtonBackground"), forState: UIControlState.Normal)
        facebookButton.setBackgroundImage(UIImage(named: "FacebookButtonBackgroundTap"), forState: UIControlState.Highlighted)
        facebookButton.setImage(facebookLogoImage, forState: UIControlState.Normal)
        facebookButton.setImage(facebookLogoImage, forState: UIControlState.Highlighted)
        facebookButton.setTitle("Login with Facebook", forState: UIControlState.Normal)
        self.addSubview(facebookButton)
        
        signupButton = UIButton()
        signupButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        signupButton.titleLabel?.attributedText = NSAttributedString(string:"Sign Up", attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)])
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackground"), forState: UIControlState.Normal)
        signupButton.setBackgroundImage(UIImage(named: "SignupButtonBackgroundTap"), forState: UIControlState.Highlighted)
        signupButton.setTitle("Sign Up", forState: UIControlState.Normal)
        self.addSubview(signupButton)
        
        termsOfService = UIButton()
        termsOfService.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        termsOfService.setTitle("Terms of Service", forState: UIControlState.Normal)
        self.addSubview(termsOfService)
        
        privacyPolicy = UIButton()
        privacyPolicy.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        privacyPolicy.setTitle("Privacy Policy", forState: UIControlState.Normal)
        self.addSubview(privacyPolicy)
    }
    
    func updateBubbleChatConstraints() {
        bubbleChatImageView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.top.equalTo()(self).with().offset()(40)
            make.left.equalTo()(self).with().offset()(40)
            make.right.equalTo()(self).with().offset()(-40)
        }
    }
    
    func makeContraints() {
        bubbleChatImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.left.equalTo()(self).with().offset()(40)
            make.right.equalTo()(self).with().offset()(-40)
        }
        
        credentialsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.bubbleChatImageView.mas_left)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(49)
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
            make.left.equalTo()(self.emailImageView.mas_right).with().offset()(15)
            make.trailing.equalTo()(self.bubbleChatImageView.mas_right)
        }
        
        emailPasswordSeparator.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailTextField.mas_bottom).with().offset()(12.5)
            make.left.equalTo()(self.emailTextField.mas_left)
            make.width.equalTo()(self.emailTextField.mas_width)
            make.height.equalTo()(0.5)
        }
        
        passwordImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.emailPasswordSeparator.mas_bottom).with().offset()(12.5)
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
            make.top.equalTo()(self.passwordTextField.mas_bottom).with().offset()(30)
        }
        
        signupButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.facebookButton.mas_bottom).with().offset()(18)
        }
        
        termsOfService.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self).with().offset()(60)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-20)
        }
        
        privacyPolicy.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.termsOfService.mas_right).with().offset()(20)
            make.bottom.equalTo()(self.mas_bottom).with().offset()(-20)
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