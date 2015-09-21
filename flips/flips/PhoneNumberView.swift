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

class PhoneNumberView : UIView, UITextFieldDelegate, CustomNavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var delegate: PhoneNumberViewDelegate?
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_LEFT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_VIEW_HEIGHT: CGFloat = 60.0
    private let MOBILE_TEXT_FIELD_LEADING: CGFloat = 130.0
    private let MOBILE_COUNTRY_CODE_LEADING: CGFloat = 50.0
    private let MOBILE_COUNTRY_CODE_WIDTH: CGFloat = 60.0
    
    private let HINT_TEXT = "Enter your number\nto verify you are a human."
    private let SPAM_TEXT = "That whole spam thing...\nYeah, we don't do that."
    
    private var navigationBar: CustomNavigationBar!
    
    private var hintView: UIView!
    private var hintText: UILabel!
    private var mobileNumberView: UIView!
    private var phoneImageView: UIImageView!
    private var mobileNumberField: UITextField!
    private var spamView: UIView!
    private var spamText: UILabel!
    private var keyboardFillerView: UIView!
    private var mobileCountryRoller : UIPickerView!
    
    var keyboardHeight: CGFloat = 0.0
    
    init() {
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.flipOrange()
        self.addSubviews()
        self.makeConstraints()
        
        CountryCodes.sharedInstance.setSelectedPicksDialCode(self.mobileCountryRoller)
    }
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func addSubviews() {
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar(NSLocalizedString("Phone Number", comment: "Phone Number"), showBackButton: true)
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
        
        mobileCountryRoller = UIPickerView()
        mobileCountryRoller.backgroundColor = UIColor.clearColor()
        mobileCountryRoller.tintColor = UIColor.whiteColor()
        mobileCountryRoller.delegate = self
        mobileNumberView.addSubview(mobileCountryRoller)
        
        mobileNumberField = UITextField()
        mobileNumberField.delegate = self
        mobileNumberField.textColor = UIColor.whiteColor()
        mobileNumberField.tintColor = UIColor.whiteColor()
        mobileNumberField.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        mobileNumberField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Mobile Number", comment: "Mobile Number"), attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        mobileNumberField.keyboardType = UIKeyboardType.PhonePad
        mobileNumberField.addTarget(self, action: "mobileNumberFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        mobileNumberField.inputAccessoryView = self.setupAccessoryView()
        mobileNumberView.addSubview(mobileNumberField)
        
        spamView = UIView()
        spamView.contentMode = .Center
        self.addSubview(spamView)
        
        spamText = UILabel()
        spamText.numberOfLines = 0
        spamText.textAlignment = NSTextAlignment.Center
        spamText.text = NSLocalizedString(SPAM_TEXT, comment: SPAM_TEXT)
        spamText.textColor = UIColor.whiteColor()
        spamText.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        spamView.addSubview(spamText)
        
        keyboardFillerView = UIView()
        self.addSubview(keyboardFillerView)
        
        mobileNumberView.bringSubviewToFront(mobileCountryRoller)
    }
    
    
    // MARK: - Overridden Methods
    
    func makeConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
       }
                
        hintView.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        hintText.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        mobileNumberView.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.MOBILE_NUMBER_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        phoneImageView.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.left.equalTo()(self.mobileNumberView).with().offset()(self.MOBILE_NUMBER_MARGIN_LEFT)
            make.centerY.equalTo()(self.mobileNumberView)
            make.width.equalTo()(self.phoneImageView.image?.size.width)
        }
        
        mobileCountryRoller.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.left.equalTo()(self).with().offset()(self.MOBILE_COUNTRY_CODE_LEADING)
            make.width.equalTo()(self.MOBILE_COUNTRY_CODE_WIDTH)
            make.height.equalTo()(self.mobileNumberView)
            make.centerY.equalTo()(self.mobileNumberView)
        }
        
        mobileNumberField.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.left.equalTo()(self).with().offset()(self.MOBILE_TEXT_FIELD_LEADING)
            make.right.equalTo()(self)
            make.height.equalTo()(self.mobileNumberView)
            make.centerY.equalTo()(self.mobileNumberView)
        }
        
        spamView.mas_makeConstraints({ (make) in
            make.removeExisting = true
            make.top.equalTo()(self.mobileNumberView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
            make.height.equalTo()(self.hintView)
        })
        
        spamText.mas_makeConstraints { (make) in
            make.removeExisting = true
            make.centerY.equalTo()(self.spamView)
            make.centerX.equalTo()(self.spamView)
        }
        
        keyboardFillerView.mas_makeConstraints( { (make) in
            make.removeExisting = true
            make.top.equalTo()(self.spamView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.keyboardHeight)
            make.bottom.equalTo()(self)
        })
        
        super.updateConstraints()
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if self.getSelectedDialCode() == "+1" {
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
        else {
            return true
        }
    }
    
    func mobileNumberFieldDidChange(textField: UITextField) {
        if self.getSelectedDialCode() == "+1" {
            if (count(textField.text) == 12) {
                textField.resignFirstResponder()
                self.finishTypingMobileNumber(textField)
            }
        }
    }
    
    func focusKeyboardOnMobileNumberField() {
        mobileNumberField.becomeFirstResponder()
    }
    
    
    // MARK: - Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        keyboardHeight = keyboardFrame.height
        self.makeConstraints()
    }
    
    // MARK: - Picker view data & delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryCodes.sharedInstance.countryCodes.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var currCountry = CountryCodes.sharedInstance.countryCodes[row]
        
        var countryCode = UILabel();
        countryCode.text = currCountry["dial_code"] as? String
        countryCode.textColor = UIColor.whiteColor()
        countryCode.tintColor = UIColor.whiteColor()
        countryCode.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        countryCode.textAlignment = NSTextAlignment.Center
        return countryCode
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (self.mobileNumberField!.text != "") {
            if (self.getSelectedDialCode() != "+1") {
                self.mobileNumberField!.text = self.mobileNumberField!.text.removeDashes()
            }
            else {
                self.mobileNumberField!.text = self.mobileNumberField!.text.formatWithDashes()
            }
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.inputAccessoryView = setupAccessoryView()
        return true
    }
    
    func setupAccessoryView() -> UIToolbar {
        var screenSize = UIScreen.mainScreen().bounds
        var showFrame = CGRectMake(0,0,screenSize.size.width, 50)
        
        var numberToolbar = UIToolbar(frame: showFrame)
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                               UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneTypingNumber:")]
        numberToolbar.tintColor = UIColor.flipOrange()
        numberToolbar.sizeToFit()
        
        return numberToolbar
    }
    
    func doneTypingNumber(sender: AnyObject?) {
        var textField = self.mobileNumberField!
        var title = NSLocalizedString("Not Enough")
        var message = NSLocalizedString("Your phone number is not long enough.")
        
        if self.getSelectedDialCode() == "+1" {
            if (count(textField.text) == 12) {
                textField.resignFirstResponder()
                self.finishTypingMobileNumber(textField)
            }
            else {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                }
            }
        }
        else if (count(textField.text) >= 5) {
            textField.resignFirstResponder()
            self.finishTypingMobileNumber(textField)
        }
        else {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
        }

    }
    
    func getSelectedDialCode() -> String {
        return CountryCodes.sharedInstance.countryCodes[self.mobileCountryRoller.selectedRowInComponent(0)].objectForKey("dial_code") as! String
    }
    
    // MARK: - Buttons delegate
    
    func finishTypingMobileNumber(sender: AnyObject?) {
        var countryCode = self.getSelectedDialCode()
        
        self.delegate?.phoneNumberView(self, didFinishTypingMobileNumber: mobileNumberField.text, withCountryCode: countryCode)
    }
    
    
    // MARK: - CustomNavigationBarDelegate Methods
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.delegate?.phoneNumberViewDidTapBackButton(self)
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
}