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

class VerificationCodeView : UIView, UITextFieldDelegate, CustomNavigationBarDelegate {
    
    var delegate: VerificationCodeViewDelegate?
    
    private let TOP_MARGIN: CGFloat = 44.0
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let CODE_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let CODE_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let CODE_VIEW_HEIGHT: CGFloat = 60.0
    private let CODE_VIEW_OPACITY: CGFloat = 60.0
    
    private let HINT_TEXT: String = "Enter the code sent to"
    
    private let BULLET: String = "\u{2022}"
    
    private let MAX_NUMBER_OF_DIGITS = 4
    private let CODE_FIELD_KENEL_ADJUST_VALUE : CGFloat = 20.0
    
    private var navigationBar: CustomNavigationBar!
    
    var hintView: UIView!
    var labelsView: UIView!
    var hintText: UILabel!
    var phoneNumberLabel: UILabel!
    var codeView: UIView!
    var codeField: UITextField!
    var resendButtonView: UIView!
    var resendButton: UIButton!
    var keyboardFillerView: UIView!
    
    var keyboardHeight: CGFloat = 0.0
    var phoneNumber: String = ""
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.updateConstraintsIfNeeded()
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func addSubviews() {
        
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar("Verification Code", showBackButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        hintView = UIView()
        hintView.contentMode = .Center
        self.addSubview(hintView)
        
        labelsView = UIView()
        labelsView.contentMode = .Center
        hintView.addSubview(labelsView)
        
        hintText = UILabel()
        hintText.textAlignment = NSTextAlignment.Center
        hintText.text = NSLocalizedString(HINT_TEXT, comment: HINT_TEXT)
        hintText.textColor = UIColor.whiteColor()
        hintText.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        labelsView.addSubview(hintText)
        
        phoneNumberLabel = UILabel()
        phoneNumberLabel.textAlignment = NSTextAlignment.Center
        phoneNumberLabel.text = NSLocalizedString("415 - 555 - 7777", comment: "415 - 555 - 7777")
        phoneNumberLabel.textColor = UIColor.whiteColor()
        phoneNumberLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        labelsView.addSubview(phoneNumberLabel)
        
        codeView = UIView()
        //codeView.contentMode = .Center
        codeView.backgroundColor = UIColor.blurredBackground()
        self.addSubview(codeView)
        
        codeField = UITextField()
        codeField.textAlignment = NSTextAlignment.Center
        codeField.delegate = self
        codeField.becomeFirstResponder()
        codeField.textColor = UIColor.whiteColor()
        codeField.tintColor = UIColor.clearColor()
        codeField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h1)
        codeField.keyboardType = UIKeyboardType.PhonePad
        var attributedString = NSMutableAttributedString(string: "\(BULLET)\(BULLET)\(BULLET)\(BULLET)")
        attributedString.addAttribute(NSKernAttributeName, value: CODE_FIELD_KENEL_ADJUST_VALUE, range: NSMakeRange(0, 3))
        codeField.attributedText = attributedString
        codeView.addSubview(codeField)
        
        keyboardFillerView = UIView()
        keyboardFillerView.backgroundColor = UIColor.greenColor()
        self.addSubview(keyboardFillerView)
        
    }
    
    override func updateConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        hintView.mas_updateConstraints { (make) in
            make.top.equalTo()(self).with().offset()(self.TOP_MARGIN)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        labelsView.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        hintText.mas_updateConstraints { (make) in
            make.centerX.equalTo()(self.labelsView)
            make.top.equalTo()(self.labelsView)
        }
        
        phoneNumberLabel.mas_updateConstraints { (make) in
            make.centerX.equalTo()(self.labelsView)
            make.top.equalTo()(self.hintText.mas_bottom)
            make.bottom.equalTo()(self.labelsView)
        }
        
        codeView.mas_updateConstraints { (make) in
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.CODE_VIEW_HEIGHT)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self)
        }
        
        codeField.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.codeView)
            make.centerX.equalTo()(self.codeView)
            make.width.equalTo()(self.codeView)

        }
        
        keyboardFillerView.mas_updateConstraints( { (make) in
            make.top.equalTo()(self.codeView.mas_bottom) // LOOOOOOOKKKKKKKKK
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var stringWithDigitsOnly = textField.text.stringByReplacingOccurrencesOfString(BULLET, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        var numberOfDigitsProvided = countElements(stringWithDigitsOnly)
        
        var newText = textField.text
        if (string == "" ) {
            if (numberOfDigitsProvided > 0) {
                // Is removing the digit. We need to add the bullet back
                var nsStringText = textField.text as NSString
                nsStringText.sizeWithAttributes([NSFontAttributeName: textField.font])
                newText = nsStringText.stringByReplacingCharactersInRange(NSMakeRange(numberOfDigitsProvided-1, 1), withString: BULLET)
            }
            
        } else {
            if (numberOfDigitsProvided < MAX_NUMBER_OF_DIGITS) {
                // Is adding a new digit. We need to replace the bullet
                var nsStringText = textField.text as NSString
                newText = nsStringText.stringByReplacingCharactersInRange(NSMakeRange(numberOfDigitsProvided, 1), withString: string)
            }
        }

        var newAttributedString = NSMutableAttributedString(string: newText)
        newAttributedString.addAttribute(NSKernAttributeName, value: CODE_FIELD_KENEL_ADJUST_VALUE, range: NSMakeRange(0, 3))
        textField.attributedText = newAttributedString

        return false;
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    func didFinishTypingVerificationCode(sender: AnyObject?) {
        self.delegate?.didFinishTypingVerificationCode(self)
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.verificationCodeViewDidTapBackButton()
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        // Do nothing
        println("customNavigationBarDidTapRightButton")
    }
    
}