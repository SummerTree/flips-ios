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

import UIKit

class ChangeNumberInputPhoneView: UIView, UITextFieldDelegate {
    
    weak var delegate: ChangeNumberInputPhoneViewDelegate?
    
    private let ENTER_NUMBER_BELOW_CONTAINER_HEIGHT:    CGFloat = 75.0
    private let NEW_NUMBER_CONTAINER_HEIGHT:            CGFloat = 50.0
    private let NEW_NUMBER_IMAGE_MARGIN:                CGFloat = 20.0
    
    private var keyboardHeight: CGFloat = 0.0
    private var enterNumberBelowContainer: UIView!
    private var enterNumberBelowLabel:  UILabel!
    private var currentNumberContainer: UIView!
    private var currentNumberLabel:     UILabel!
    private var newNumberContainerView: UIView!
    private var newNumberTextField:     UITextField!
    private var newNumberImageView:     UIImageView!
    private var keyboardView:           UIView!
    
    init() {
        super.init(frame: CGRectZero)
        addSubviews()
    }
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        self.newNumberTextField.becomeFirstResponder()
    }
    
    func viewDidAppear() {
        self.newNumberTextField.becomeFirstResponder()
    }
    
    func viewWillDisappear() {
        self.newNumberTextField.resignFirstResponder()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func addSubviews() {
        self.backgroundColor = UIColor.whiteColor()
        
        self.enterNumberBelowContainer = UIView()
        self.addSubview(enterNumberBelowContainer)

        self.enterNumberBelowLabel = UILabel()
        self.enterNumberBelowLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h3)
        self.enterNumberBelowLabel.numberOfLines = 2
        let enterNumberText = "Please enter the new\nnumber below"
        self.enterNumberBelowLabel.text = NSLocalizedString(enterNumberText, comment: enterNumberText)
        self.enterNumberBelowLabel.textAlignment = NSTextAlignment.Center
        self.enterNumberBelowLabel.textColor = UIColor.mediumGray()
        self.enterNumberBelowLabel.sizeToFit()
        self.enterNumberBelowContainer.addSubview(enterNumberBelowLabel)
        
        self.newNumberContainerView = UIView()
        self.newNumberContainerView.backgroundColor = UIColor.deepSea()
        self.addSubview(newNumberContainerView)
        
        self.newNumberTextField = UITextField()
        self.newNumberTextField.addTarget(self, action: "newNumberFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)

        self.newNumberTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("New Number", comment: "New Number"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.newNumberTextField.delegate = self
        self.newNumberTextField.keyboardType = UIKeyboardType.PhonePad
        self.newNumberTextField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        
        self.newNumberTextField.textColor = UIColor.whiteColor()
        self.newNumberContainerView.addSubview(newNumberTextField)
        
        self.newNumberImageView = UIImageView(image: UIImage(named: "AddNumber"))
        self.newNumberImageView.sizeToFit()
        self.newNumberContainerView.addSubview(newNumberImageView)
        
        self.currentNumberContainer = UIView()
        self.addSubview(currentNumberContainer)
        
        self.currentNumberLabel = UILabel()
        self.currentNumberLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        self.currentNumberLabel.numberOfLines = 2
        if let loggedUser = User.loggedUser() {
            let currentNumberText = "Current number for this account is\n\(loggedUser.formattedPhoneNumber())"
            self.currentNumberLabel.text = NSLocalizedString(currentNumberText, comment: currentNumberText)
        }
        self.currentNumberLabel.textAlignment = NSTextAlignment.Center
        self.currentNumberLabel.textColor = UIColor.mediumGray()
        self.currentNumberLabel.sizeToFit()
        self.currentNumberContainer.addSubview(currentNumberLabel)
        
        self.keyboardView = UIView()
        self.addSubview(keyboardView)
    }
    
    func makeConstraints() {
        
        enterNumberBelowContainer.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.greaterThanOrEqualTo()(self.ENTER_NUMBER_BELOW_CONTAINER_HEIGHT)
            make.bottom.equalTo()(self.newNumberContainerView.mas_top)
        }
        
        // ask to delegate create constraint related to navigation bar
        self.delegate?.makeConstraintToNavigationBarBottom(enterNumberBelowContainer)
        
        enterNumberBelowLabel.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self.enterNumberBelowContainer)
            make.height.equalTo()(self.enterNumberBelowLabel.frame.size.height)
            make.width.equalTo()(self.enterNumberBelowLabel.frame.size.width)
        }
        
        newNumberContainerView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.enterNumberBelowContainer.mas_bottom)
            make.bottom.equalTo()(self.currentNumberContainer.mas_top)
            make.left.equalTo()(self.enterNumberBelowContainer)
            make.right.equalTo()(self.enterNumberBelowContainer)
            make.height.greaterThanOrEqualTo()(self.NEW_NUMBER_CONTAINER_HEIGHT)
        }
        
        newNumberImageView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerY.equalTo()(self.newNumberContainerView)
            make.left.equalTo()(self).with().offset()(self.NEW_NUMBER_IMAGE_MARGIN)
            make.width.equalTo()(self.newNumberImageView.frame.size.width)
            make.height.equalTo()(self.newNumberImageView.frame.size.height)
        }
        
        newNumberTextField.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerY.equalTo()(self.newNumberContainerView)
            make.left.equalTo()(self.newNumberImageView.mas_right).with().offset()(self.NEW_NUMBER_IMAGE_MARGIN)
            make.right.equalTo()(self.newNumberContainerView)
            make.height.equalTo()(self.newNumberContainerView)
        }
        
        currentNumberContainer.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.bottom.equalTo()(self.keyboardView.mas_top)
            make.height.equalTo()(self.enterNumberBelowContainer)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        currentNumberLabel.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self.currentNumberContainer)
            make.height.equalTo()(self.currentNumberLabel.frame.size.height)
            make.width.equalTo()(self.currentNumberLabel.frame.size.width)
        }
        
        keyboardView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        }
        
        super.updateConstraints()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        keyboardHeight = keyboardFrame.height
        self.makeConstraints()
    }
    
    
    // UITextFieldDelegate
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
        
        let text = textField.text
        let length = count(text)
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
    
    func newNumberFieldDidChange(textField: UITextField) {
        if (count(textField.text) == 12) {
            self.finishTypingMobileNumber(textField)
        }
    }
    
    func finishTypingMobileNumber(sender: AnyObject?) {
        self.delegate?.changeNumberInputPhoneView(self, didFinishTypingMobileNumber: newNumberTextField.text)
    }
    
    func clearPhoneNumberField() {
        self.newNumberTextField.text = ""
    }
    
    
    // MARK: - Required inits
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

protocol ChangeNumberInputPhoneViewDelegate: class {
    func makeConstraintToNavigationBarBottom(view: UIView!)
    func changeNumberInputPhoneView(view: ChangeNumberInputPhoneView, didFinishTypingMobileNumber: String)
}