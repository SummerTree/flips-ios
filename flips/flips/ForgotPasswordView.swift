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

class ForgotPasswordView : UIView, CustomNavigationBarDelegate, UITextFieldDelegate {
    
    weak var delegate: ForgotPasswordViewDelegate?
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_LEFT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_VIEW_HEIGHT: CGFloat = 60.0
    private let MOBILE_TEXT_FIELD_LEADING: CGFloat = 58.0
    
    private let HINT_TEXT: String = NSLocalizedString("Enter your phone number below\n to reset your password", comment: "")
    
    var navigationBar: CustomNavigationBar!
    
    var hintView: UIView!
    var hintText: UILabel!
    var mobileNumberView: UIView!
    var phoneImageView: UIImageView!
    var mobileNumberField: UITextField!
    var spamView: UIView!
    var spamText: UILabel!
    var keyboardFillerView: UIView!
    var keyboardHeight: CGFloat = 0.0
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.flipOrange()
        self.addSubviews()
    }
    
    func addSubviews() {
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar(LocalizedString.FORGOT_PASSWORD, showBackButton: true)
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
        
        phoneImageView = UIImageView(image: UIImage(named: "Phone"))
        phoneImageView.contentMode = .Center
        mobileNumberView.addSubview(phoneImageView)
        
        mobileNumberField = UITextField()
        mobileNumberField.delegate = self
        mobileNumberField.textColor = UIColor.whiteColor()
        mobileNumberField.tintColor = UIColor.whiteColor()
        mobileNumberField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        mobileNumberField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Mobile Number", comment: "Mobile Number"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        mobileNumberField.addTarget(self, action: "mobileNumberFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        mobileNumberField.keyboardType = UIKeyboardType.PhonePad
        mobileNumberView.addSubview(mobileNumberField)
        
        spamView = UIView()
        spamView.contentMode = .Center
        self.addSubview(spamView)
        
        keyboardFillerView = UIView()
        keyboardFillerView.backgroundColor = UIColor.clearColor()
        self.addSubview(keyboardFillerView)
    }
    
    func makeConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        hintView.mas_makeConstraints { (make) in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        hintText.mas_makeConstraints { (make) in
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        mobileNumberView.mas_makeConstraints { (make) in
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.MOBILE_NUMBER_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        phoneImageView.mas_makeConstraints { (make) in
            make.left.equalTo()(self.mobileNumberView).with().offset()(self.MOBILE_NUMBER_MARGIN_LEFT)
            make.centerY.equalTo()(self.mobileNumberView)
            make.width.equalTo()(self.phoneImageView.image?.size.width)
        }
        
        mobileNumberField.mas_makeConstraints { (make) in
            make.left.equalTo()(self).with().offset()(self.MOBILE_TEXT_FIELD_LEADING)
            make.right.equalTo()(self)
            make.height.equalTo()(self.mobileNumberView)
            make.centerY.equalTo()(self.mobileNumberView)
        }
        
        spamView.mas_makeConstraints({ (make) in
            make.top.equalTo()(self.mobileNumberView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
            make.height.equalTo()(self.hintView)
        })
        
        keyboardFillerView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self.spamView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    
    // MARK - Life Cycle
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    
    // MARK: - UITextField delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let text = textField.text
        let length = countElements(text)
        var shouldReplace = true
        
        if (string != "") {
            switch length {
            case 3, 7:
                textField.text = "\(text)-"
            default:
                break;
            }
            if (length > 11) {
                shouldReplace = false
            }
        } else {
            switch length {
            case 5, 9:
                let nsString = text as NSString
                textField.text = nsString.substringWithRange(NSRange(location: 0, length: length-1)) as String
            default:
                break;
            }
        }
        return shouldReplace;
    }
    
    func mobileNumberFieldDidChange(textField: UITextField) {
        if (countElements(textField.text) == 12) {
            textField.resignFirstResponder()
            self.finishTypingMobileNumber(self)
        }
    }
    
    func focusKeyboardOnMobileNumberField() {
        mobileNumberField.becomeFirstResponder()
    }
    
    
    // MARK: - Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        keyboardHeight = keyboardFrame.height
        self.makeConstraints()
    }
    
    
    // MARK: - Buttons delegate
    
    func finishTypingMobileNumber(sender: AnyObject?) {
        self.delegate?.phoneNumberView(mobileNumberField, didFinishTypingMobileNumber: mobileNumberField.text)
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.forgotPasswordViewDidTapBackButton(self)
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
