//
// Copyright 2015 ArcTouch, Inc.
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
    
    weak var delegate: NewPasswordViewDelegate?
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let HINT_VIEW_HEIGHT: CGFloat = 100.0
    private let MOBILE_NUMBER_MARGIN_LEFT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_VIEW_HEIGHT: CGFloat = 60.0
    private let MOBILE_TEXT_FIELD_LEADING: CGFloat = 58.0
    private let DONE_BUTTON_MARGIN_TOP: CGFloat = 25.0
    
    private let HINT_TEXT: String = "Enter a new password below"
    private let INVALID_PASSWORD_TEXT: String = "Your password should have\n8+ characters, Mixed Case, 1 Number"
    
    var navigationBar: CustomNavigationBar!
    
    var hintView: UIView!
    var hintText: UILabel!
    var passwordView: UIView!
    var phoneImageView: UIImageView!
    var passwordField: UITextField!
    var bottomView: UIView!
    var doneButton: UIButton!
    var keyboardFillerView: UIView!
    var keyboardHeight: CGFloat = 0.0
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = UIColor.flipOrange()
        self.addSubviews()
        self.updateConstraints()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func viewDidAppear() {
        passwordField.becomeFirstResponder()
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
        
        passwordView = UIView()
        passwordView.contentMode = .Center
        passwordView.backgroundColor = UIColor.lightSemitransparentBackground()
        self.addSubview(passwordView)
        
        phoneImageView = UIImageView(image: UIImage(named: "Password"))
        phoneImageView.contentMode = .Center
        passwordView.addSubview(phoneImageView)
        
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.secureTextEntry = true;
        passwordField.sizeToFit()
        passwordField.textColor = UIColor.whiteColor()
        passwordField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("New Password", comment: "New Password"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        passwordField.keyboardType = UIKeyboardType.Default
        passwordView.addSubview(passwordField)
        
        bottomView = UIView()
        bottomView.contentMode = .Center
        self.addSubview(bottomView)
        
        doneButton = UIButton()
        doneButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        doneButton.titleLabel?.attributedText = NSAttributedString(string:NSLocalizedString("Done", comment: "Done"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextMedium(UIFont.HeadingSize.h4)])
        doneButton.setBackgroundImage(UIImage(named: "ForgotButton"), forState: UIControlState.Normal)
        doneButton.setBackgroundImage(UIImage(named: "ForgotButtonTap"), forState: UIControlState.Highlighted)
        doneButton.setTitle(NSLocalizedString("Done", comment: "Done"), forState: UIControlState.Normal)
        doneButton.addTarget(self, action: "didTapDoneButton", forControlEvents: .TouchUpInside)
        bottomView.addSubview(doneButton)
        
        keyboardFillerView = UIView()
        self.addSubview(keyboardFillerView)
    }
    
    override func updateConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
			make.removeExisting = true
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        hintView.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        hintText.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.centerX.equalTo()(self.hintView)
            make.centerY.equalTo()(self.hintView)
        }
        
        passwordView.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.MOBILE_NUMBER_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        phoneImageView.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.left.equalTo()(self.passwordView).with().offset()(self.MOBILE_NUMBER_MARGIN_LEFT)
            make.centerY.equalTo()(self.passwordView)
            make.width.equalTo()(self.phoneImageView.image?.size.width)
        }
        
        passwordField.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.left.equalTo()(self).with().offset()(self.MOBILE_TEXT_FIELD_LEADING)
            make.right.equalTo()(self).with().offset()(-self.MOBILE_TEXT_FIELD_LEADING)
            make.centerY.equalTo()(self.passwordView)
        }
        
        bottomView.mas_updateConstraints({ (make) in
			make.removeExisting = true
            make.top.equalTo()(self.passwordView.mas_bottom)
            make.left.equalTo()(self)
			make.right.equalTo()(self)
			make.height.equalTo()(self.hintView)
        })
        
        doneButton.mas_updateConstraints { (make) in
			make.removeExisting = true
            make.centerX.equalTo()(self.bottomView)
            make.centerY.equalTo()(self.bottomView)
        }
        
        keyboardFillerView.mas_updateConstraints( { (make) in
			make.removeExisting = true
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
            let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            self.keyboardHeight = keyboardFrame.height
            self.updateConstraints()
        }
    }
    
    
    // MARK: - Buttons delegate
    func didTapDoneButton() {
        let passwordStatus = verifyPassword(passwordField.text)
            
        if (passwordStatus.isValid) {
            self.delegate?.newPasswordViewDidTapDoneButton(self)
        } else {
            hintText.text = NSLocalizedString(INVALID_PASSWORD_TEXT, comment: INVALID_PASSWORD_TEXT)
        }
    }
    
    // Requirement: 8+ characters, Mixed case, at least 1 number
    // Specific messages not being used for now
    func verifyPassword(password: String) -> (isValid: Bool, message: String) {
        if password.characters.count < 8 {
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
        print("customNavigationBarDidTapRightButton")
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        didTapDoneButton()
        return true
    }
    
    
    // MARK: - Required methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}