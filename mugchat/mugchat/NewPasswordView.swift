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

class NewPasswordView : UIView, CustomNavigationBarDelegate, UITextFieldDelegate {
    
    var delegate: NewPasswordViewDelegate?
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_LEFT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_VIEW_HEIGHT: CGFloat = 60.0
    private let MOBILE_TEXT_FIELD_LEADING: CGFloat = 58.0
    
    private let HINT_TEXT: String = "Enter a new password below"
    
    var navigationBar: CustomNavigationBar!
    
    var hintView: UIView!
    var hintText: UILabel!
    var mobileNumberView: UIView!
    var phoneImageView: UIImageView!
    var passwordField: UITextField!
    var bottomView: UIView!
    //var spamText: UILabel!
    var doneButton: UIButton!
    var keyboardFillerView: UIView!
    var keyboardHeight: CGFloat = 0.0
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.makeConstraints()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func addSubviews() {
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar("New Password", showBackButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        hintView = UIView()
        hintView.contentMode = .Center
        self.addSubview(hintView)
        
        hintText = UILabel()
        hintText.numberOfLines = 0
        hintText.textAlignment = NSTextAlignment.Center
        hintText.text = NSLocalizedString(HINT_TEXT, comment: HINT_TEXT)
        hintText.textColor = UIColor.whiteColor()
        hintText.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        hintView.addSubview(hintText)
        
        mobileNumberView = UIView()
        mobileNumberView.contentMode = .Center
        mobileNumberView.backgroundColor = UIColor.lightSemitransparentBackground()
        self.addSubview(mobileNumberView)
        
        phoneImageView = UIImageView(image: UIImage(named: "Password"))
        phoneImageView.contentMode = .Center
        mobileNumberView.addSubview(phoneImageView)
        
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.secureTextEntry = true;
        passwordField.becomeFirstResponder()
        passwordField.textColor = UIColor.whiteColor()
        passwordField.tintColor = UIColor.whiteColor()
        passwordField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("New Password", comment: "New Password"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        passwordField.keyboardType = UIKeyboardType.Default
        mobileNumberView.addSubview(passwordField)
        
        bottomView = UIView()
        bottomView.contentMode = .Center
        self.addSubview(bottomView)
        
        doneButton = UIButton()
        doneButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        doneButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Done", comment: "Done"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)])
        doneButton.setBackgroundImage(UIImage(named: "SignupButtonBackground"), forState: UIControlState.Normal)
        doneButton.setBackgroundImage(UIImage(named: "SignupButtonBackgroundTap"), forState: UIControlState.Highlighted)
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "didTapDoneButton", forControlEvents: .TouchUpInside)
        bottomView.addSubview(doneButton)
        
        keyboardFillerView = UIView()
        keyboardFillerView.backgroundColor = UIColor.greenColor()
        self.addSubview(keyboardFillerView)
    }
    
    func makeConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        hintView.mas_updateConstraints { (make) in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        hintText.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        mobileNumberView.mas_updateConstraints { (make) in
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.MOBILE_NUMBER_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        phoneImageView.mas_updateConstraints { (make) in
            make.left.equalTo()(self.mobileNumberView).with().offset()(self.MOBILE_NUMBER_MARGIN_LEFT)
            make.centerY.equalTo()(self.mobileNumberView)
            make.width.equalTo()(self.phoneImageView.image?.size.width)
        }
        
        passwordField.mas_updateConstraints { (make) in
            make.left.equalTo()(self).with().offset()(self.MOBILE_TEXT_FIELD_LEADING)
            make.centerY.equalTo()(self.mobileNumberView)
        }
        
        bottomView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.mobileNumberView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
            make.height.equalTo()(self.hintView)
        })
        
        doneButton.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.bottomView)
            make.centerX.equalTo()(self.bottomView)
        }
        
        keyboardFillerView.mas_updateConstraints( { (make) in
            make.top.equalTo()(self.bottomView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    
    // MARK: - Notifications
    func keyboardOnScreen(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
            keyboardHeight = keyboardFrame.height
            updateConstraints()
        }
    }
    
    
    // MARK: - Buttons delegate
    func didTapDoneButton() {
        let passwordStatus = verifyPassword(passwordField.text)
            
        if (passwordStatus.isValid){
            self.delegate?.newPasswordViewDidTapDoneButton(self)
        } else {
            //TODO: show message passwordStatus.message
        }
    }
    
    //8+ characters, Mixed case, at least 1 number
    //TODO: handle grouped states (verify the 3 conditions before generate the error message)
    func verifyPassword(password: String) -> (isValid: Bool, message: String) {
        if countElements(password) < 8 {
            return (false, "Password must have at least 8 characters.");
        }
        
        if password.lowercaseString == password || password.uppercaseString == password {
            return (false, "Password must have upper and lower case letters.");
        }
        
        let match = password.rangeOfString("[0-9]", options: .RegularExpressionSearch)
        if match == nil {
            return (false, "Password must have at least one number.");
        }
    
        return (true, "");
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.newPasswordViewDidTapBackButton(self)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        // Do nothing
        println("customNavigationBarDidTapRightButton")
    }
    
    
    // MARK: - Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}