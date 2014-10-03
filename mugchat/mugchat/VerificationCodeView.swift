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
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let CODE_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let CODE_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let CODE_VIEW_HEIGHT: CGFloat = 60.0
    private let CODE_FIELD_KERNEL_ADJUSTMENT_VALUE: CGFloat = 20.0
    private let MAX_NUMBER_OF_DIGITS = 4
    
    private let HINT_TEXT: String = "Enter the code sent to"
    
    private let BULLET: String = "\u{2022}"
    
    private var navigationBar: CustomNavigationBar!
    
    private var hintView: UIView!
    private var labelsView: UIView!
    private var hintText: UILabel!
    private var phoneNumberLabel: UILabel!
    private var codeView: UIView!
    private var codeField: UITextField!
    private var resendButtonView: UIView!
    private var resendButton: UIButton!
    private var keyboardFillerView: UIView!
    
    private var keyboardHeight: CGFloat = 0.0
    private var phoneNumber: String = ""
    
    init(phoneNumber : String!) {
        super.init()
        self.phoneNumber = phoneNumber
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
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
        phoneNumberLabel.text = NSLocalizedString(phoneNumber, comment: phoneNumber)
        phoneNumberLabel.textColor = UIColor.whiteColor()
        phoneNumberLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        labelsView.addSubview(phoneNumberLabel)
        
        codeView = UIView()
        codeView.backgroundColor = UIColor.lightSemitransparentBackground()
        self.addSubview(codeView)
        
        codeField = UITextField()
        codeField.textAlignment = NSTextAlignment.Center
        codeField.sizeToFit()
        codeField.delegate = self
        codeField.becomeFirstResponder()
        codeField.textColor = UIColor.whiteColor()
        codeField.tintColor = UIColor.clearColor()
        codeField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h1)
        codeField.keyboardType = UIKeyboardType.PhonePad
        codeField.attributedText = makeVerificatioCodeAttributedString("\(BULLET)\(BULLET)\(BULLET)\(BULLET)")
        codeField.addTarget(self, action: "codeFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        codeView.addSubview(codeField)
        
        resendButtonView = UIView()
        resendButtonView.contentMode = .Center
        self.addSubview(resendButtonView)
        
        resendButton = UIButton()
        resendButton.setAttributedTitle(NSAttributedString(string:NSLocalizedString("Resend Code", comment: "Resend Code"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextRegular(UIFont.HeadingSize.h4)]), forState: UIControlState.Normal)
        resendButton.setBackgroundImage(UIImage(named: "Resend_button_normal"), forState: UIControlState.Normal)
        resendButton.setBackgroundImage(UIImage(named: "Resend_button_tap"), forState: UIControlState.Highlighted)
        resendButtonView.addSubview(resendButton)
        
        keyboardFillerView = UIView()
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
            make.top.equalTo()(self.navigationBar.mas_bottom)
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
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        codeField.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.codeView)
            make.centerX.equalTo()(self.codeView)
            make.width.equalTo()(UIFont.HeadingSize.h1 * 4 + self.CODE_FIELD_KERNEL_ADJUSTMENT_VALUE * 3)
        }
        
        resendButtonView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.codeView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
            make.height.equalTo()(self.hintView)
        })
        
        resendButton.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.resendButtonView)
            make.centerX.equalTo()(self.resendButtonView)
        }
        
        
        keyboardFillerView.mas_updateConstraints( { (make) in
            make.top.equalTo()(self.resendButtonView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let stringWithDigitsOnly = textField.text.stringByReplacingOccurrencesOfString(BULLET, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        let numberOfDigitsProvided = countElements(stringWithDigitsOnly)
        
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
        
        textField.attributedText = makeVerificatioCodeAttributedString(newText)
        
        return false;
    }
    
    private func makeVerificatioCodeAttributedString(code : String) -> NSMutableAttributedString {
        var verificationCodeAttributedString = NSMutableAttributedString(string: code)
        verificationCodeAttributedString.addAttribute(NSKernAttributeName, value: CODE_FIELD_KERNEL_ADJUSTMENT_VALUE, range: NSMakeRange(0, 3))
        return verificationCodeAttributedString
    }
    
    func resetVerificationCodeField() {
        codeField.attributedText = makeVerificatioCodeAttributedString("\(BULLET)\(BULLET)\(BULLET)\(BULLET)")
    }
    
    private func codeFieldDidChange(textField: UITextField) {
        let stringWithDigitsOnly = textField.text.stringByReplacingOccurrencesOfString(BULLET, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        let numberOfDigitsProvided = countElements(stringWithDigitsOnly)
        if (numberOfDigitsProvided == 4) {
            self.didFinishTypingVerificationCode(textField)
            
        }
    }
    
    func showKeyboard() {
        codeField.becomeFirstResponder()
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
        self.delegate?.verificationCodeView(self, didFinishTypingVerificationCode: (sender as UITextField).text)
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.verificationCodeViewDidTapBackButton(self)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        // Do nothing
        println("customNavigationBarDidTapRightButton")
    }
    
}