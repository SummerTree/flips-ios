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
    private let CODE_VIEW_MARGIN_LEFT: CGFloat = 12.5
    private let CODE_VIEW_MARGIN_RIGHT: CGFloat = 12.5
    private let CODE_VIEW_HEIGHT: CGFloat = 60.0
    private let CODE_FIELD_KERNEL_ADJUSTMENT_VALUE: CGFloat = 20.0
    private let MAX_NUMBER_OF_DIGITS = 4
    
    private let HINT_TEXT: String = "Enter the code sent to"
    
    private let BULLET: String = "\u{2022}"
    
    internal var navigationBar: CustomNavigationBar!
    internal var hintView: UIView!
    internal var phoneNumber: String = ""
    
    private var labelsView: UIView!
    private var hintText: UILabel!
    private var phoneNumberLabel: UILabel!
    private var codeView: UIView!
    private var codeViewLeadingSpace: UIView!
    private var codeField0: UITextField!
    private var codeField1: UITextField!
    private var codeField2: UITextField!
    private var codeField3: UITextField!
    private var codeViewTrailingSpace: UIView!
    private var resendButtonView: UIView!
    private var resendButton: UIButton!
    private var keyboardFillerView: UIView!
    private var errorSignView: UIImageView!
    
    private var keyboardHeight: CGFloat = 0.0
    
    private var wrongVerificationCodeCounter = 0
    
    init(phoneNumber : String!) {
        super.init()
        self.phoneNumber = phoneNumber
        self.backgroundColor = self.defineBackgroundColor()
        self.addSubviews()
    }
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func addNavigationBar() {
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar("Verification Code", showBackButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
    }
    
    func addSubviews() {
        
        addNavigationBar()
        
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
        codeView.contentMode = UIViewContentMode.Center
        codeView.backgroundColor = UIColor.lightSemitransparentBackground()
        self.addSubview(codeView)
        
        codeViewLeadingSpace = UIView()
        codeView.addSubview(codeViewLeadingSpace)
        
        codeField0 = makeCodeField()
        codeField0.becomeFirstResponder()
        codeView.addSubview(codeField0)
        
        codeField1 = makeCodeField()
        codeView.addSubview(codeField1)
        
        codeField2 = makeCodeField()
        codeView.addSubview(codeField2)
        
        codeField3 = makeCodeField()
        codeField3.addTarget(self, action: "codeFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        codeView.addSubview(codeField3)
        
        codeViewTrailingSpace = UIView()
        codeView.addSubview(codeViewTrailingSpace)
        
        resendButtonView = UIView()
        resendButtonView.contentMode = .Center
        self.addSubview(resendButtonView)
        
        resendButton = UIButton()
        resendButton.addTarget(self, action: "resendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        resendButton.setAttributedTitle(NSAttributedString(string:NSLocalizedString("Resend Code", comment: "Resend Code"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextRegular(UIFont.HeadingSize.h4)]), forState: UIControlState.Normal)
        resendButton.setBackgroundImage(UIImage(named: "ResendButtonNormal"), forState: UIControlState.Normal)
        resendButton.setBackgroundImage(UIImage(named: "ResendButtonTapped"), forState: UIControlState.Highlighted)
        resendButtonView.addSubview(resendButton)
        
        keyboardFillerView = UIView()
        self.addSubview(keyboardFillerView)
        
    }
    
    func defineBackgroundColor() -> UIColor {
        return UIColor.flipOrange()
    }
    
    func createHintViewConstraints() {
        hintView.mas_updateConstraints { (make) in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
    }
    
    func createNavigationBarConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
    }
    
    override func updateConstraints() {
        
        createNavigationBarConstraints()
        
        createHintViewConstraints()
        
        labelsView.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        hintText.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerX.equalTo()(self.labelsView)
            make.top.equalTo()(self.labelsView)
        }
        
        phoneNumberLabel.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerX.equalTo()(self.labelsView)
            make.top.equalTo()(self.hintText.mas_bottom)
            make.bottom.equalTo()(self.labelsView)
        }
        
        codeView.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.CODE_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        codeViewLeadingSpace.mas_updateConstraints( { (make) in
            make.removeExisting = true
            make.left.equalTo()(self.codeView)
            make.width.equalTo()(self.codeViewTrailingSpace.mas_width)
        })
        
        codeField0.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.codeView)
            make.left.equalTo()(self.codeViewLeadingSpace.mas_right)
        }
        
        codeField1.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.codeView)
            make.left.equalTo()(self.codeField0.mas_right).with().offset()(self.CODE_FIELD_KERNEL_ADJUSTMENT_VALUE)
        }
        
        codeField2.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.codeView)
            make.left.equalTo()(self.codeField1.mas_right).with().offset()(self.CODE_FIELD_KERNEL_ADJUSTMENT_VALUE)
        }
        
        codeField3.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.codeView)
            make.left.equalTo()(self.codeField2.mas_right).with().offset()(self.CODE_FIELD_KERNEL_ADJUSTMENT_VALUE)
        }
        
        codeViewTrailingSpace.mas_updateConstraints( { (make) in
            make.removeExisting = true
            make.left.equalTo()(self.codeField3.mas_right)
            make.right.equalTo()(self.codeView)
        })
        
        resendButtonView.mas_updateConstraints({ (make) in
            make.removeExisting = true
            make.top.equalTo()(self.codeView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
            make.height.equalTo()(self.hintView)
        })
        
        resendButton.mas_updateConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.resendButtonView)
            make.centerX.equalTo()(self.resendButtonView)
        }
        
        keyboardFillerView.mas_updateConstraints( { (make) in
            make.removeExisting = true
            make.top.equalTo()(self.resendButtonView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textFieldLength = countElements(textField.text)
        let replacementStringLength = countElements(string)
        if (replacementStringLength == 0) { //backspace
            if (textField == codeField3) {
                codeField3.text = ""
                codeField2.becomeFirstResponder()
                return false
            } else if (textField == codeField2) {
                codeField2.text = ""
                codeField1.becomeFirstResponder()
                return false
            } else if (textField == codeField1) {
                codeField1.text = ""
                codeField0.becomeFirstResponder()
                return false
            } else if (textField == codeField0) {
                codeField0.text = ""
                codeField0.becomeFirstResponder()
                return false
            }
        } else {
            if (textFieldLength <= 0) {
                if (textField == codeField0) {
                    codeField0.text = string
                    return false
                } else if (textField == codeField1) {
                    codeField1.text = string
                    return false
                } else if (textField == codeField2) {
                    codeField2.text = string
                    codeField3.becomeFirstResponder()
                    return false
                } else {
                    codeField3.text = string
                    codeField3.resignFirstResponder()
                    return true
                }
            } else if (textFieldLength == 1) {
                if (textField == codeField0) {
                    codeField1.text = string
                    codeField1.becomeFirstResponder()
                    return false
                } else if (textField == codeField1) {
                    codeField2.text = string
                    codeField2.becomeFirstResponder()
                    return false
                } else if (textField == codeField2) {
                    codeField3.becomeFirstResponder()
                    return true
                }
            } else {
                return false
            }
        }
        return false
    }
    
    func makeCodeField() -> UITextField {
        var codeField = UITextField()
        codeField.textAlignment = NSTextAlignment.Center
        codeField.sizeToFit()
        codeField.layoutIfNeeded()
        codeField.delegate = self
        codeField.textColor = UIColor.whiteColor()
        codeField.tintColor = UIColor.clearColor()
        codeField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h1)
        codeField.keyboardType = UIKeyboardType.PhonePad
        codeField.attributedPlaceholder = NSAttributedString(string: "\(BULLET)", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        return codeField
    }
    
    func resetVerificationCodeField() {
        codeField0.text = ""
        codeField1.text = ""
        codeField2.text = ""
        codeField3.text = ""
        codeView.backgroundColor = UIColor.lightSemitransparentBackground()
        if (errorSignView != nil) {
            errorSignView.removeFromSuperview()
        }
    }
    
    func codeFieldDidChange(textField: UITextField) {
        let verificationCode = codeField0.text + codeField1.text + codeField2.text + codeField3.text
        let stringWithDigitsOnly = verificationCode.stringByReplacingOccurrencesOfString(BULLET, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        let numberOfDigitsProvided = countElements(stringWithDigitsOnly)
        if (numberOfDigitsProvided == 4) {
            self.didFinishTypingVerificationCode(verificationCode)
        }
    }
    
    func focusKeyboardOnCodeField() {
        codeField0.becomeFirstResponder()
    }
    
    func didEnterWrongVerificationCode() {
        
        self.wrongVerificationCodeCounter++
        if self.wrongVerificationCodeCounter >= 3 {
            var alertMessage = UIAlertView(title: LocalizedString.WRONG_VERIFICATION_CODE, message: LocalizedString.CONSECUTIVE_INCORRECT_ENTRIES, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
            self.wrongVerificationCodeCounter = 0
        }
        
        resetVerificationCodeField()
        focusKeyboardOnCodeField()
        codeView.backgroundColor = UIColor.deepSea()
        errorSignView = UIImageView(image: UIImage(named: "Error"))
        errorSignView.contentMode = .Center
        codeView.addSubview(errorSignView)
        
        errorSignView.mas_updateConstraints( { (make) in
            make.removeExisting = true
            make.width.equalTo()(self.errorSignView.image?.size.width)
            make.centerY.equalTo()(self.codeView)
            make.right.equalTo()(self.codeView.mas_right).with().offset()(-self.CODE_VIEW_MARGIN_RIGHT)
        })
        
        super.updateConstraints()
    }
    
    func resendButtonTapped(sender: AnyObject) {
        self.delegate?.verificationCodeViewDidTapResendButton(self)
        self.wrongVerificationCodeCounter = 0
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
    
    func didFinishTypingVerificationCode(code: String) {
        self.focusKeyboardOnCodeField()
        self.delegate?.verificationCodeView(self, didFinishTypingVerificationCode: code)
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.verificationCodeViewDidTapBackButton(self)
    }
    
}