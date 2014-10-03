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

class UserFormView : UIView, UITextFieldDelegate {
    
    private let CELL_BACKGROUND_COLOR = UIColor(RRGGBB: UInt(0x546775))
    private let SEPARATOR_SIZE : CGFloat = 1
    private let CELL_HEIGHT : CGFloat = 44
    private let CELL_WITH_ICON_TOTAL_MARGIN : CGFloat = 25
    private let CELL_WITHOUT_ICON_TOTAL_MARGIN : CGFloat = 12.5
    
    private let BIRTHDAY_DATE_SEPARATOR = "/"
    private let BIRTHDAY_MAX_NUMBER_OF_DIGITS = 8
    private let BIRTHDAY_FIELD_NUMBER_OF_CHARACTERS = 10
    private let BIRTHDAY_FIRST_SEPARATOR_POSITION = 2
    private let BIRTHDAY_SECOND_SEPARATOR_POSITION = 5
    private let BIRTHDAY_MONTH_CHARACTER = NSLocalizedString("M", comment: "Month Abreviation")
    private let BIRTHDAY_DAY_CHARACTER = NSLocalizedString("D", comment: "Month Abreviation")
    private let BIRTHDAY_YEAR_CHARACTER = NSLocalizedString("Y", comment: "Month Abreviation")
    
    private var firstNameTextField, lastNameTextField, emailTextField, passwordTextField, birthdayTextField : UITextField!
    
    
    //MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.deepSea()
        
        self.initSubviews()
        
        self.updateConstraintsIfNeeded()
    }
    
    func initSubviews() {
        firstNameTextField = self.setupCell(NSLocalizedString("First Name", comment: "First Name"), leftImage: UIImage(named: "User"))
        self.addSubview(firstNameTextField)
        
        lastNameTextField = self.setupCell(NSLocalizedString("Last Name", comment: "Last Name"))
        self.addSubview(lastNameTextField)
        
        emailTextField = self.setupCell(NSLocalizedString("Email", comment: "Email"), leftImage: UIImage(named: "Mail"))
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
        emailTextField.keyboardType = UIKeyboardType.EmailAddress
        self.addSubview(emailTextField)
        
        passwordTextField = self.setupCell(NSLocalizedString("Password", comment: "Password"), leftImage: UIImage(named: "Password"))
        passwordTextField.secureTextEntry = true
        self.addSubview(passwordTextField)
        
        birthdayTextField = self.setupCell(NSLocalizedString("Birthday", comment: "Birthday"), leftImage: UIImage(named: "Birthday"))
        birthdayTextField.keyboardType = UIKeyboardType.NumberPad
        birthdayTextField.returnKeyType = UIReturnKeyType.Done
        birthdayTextField.tintColor = UIColor.clearColor()
        self.addSubview(birthdayTextField)
    }
    
    private func setupCell(placeHolder: String, leftImage: UIImage? = nil) -> UITextField {
        var textField = UITextField()
        textField.backgroundColor = CELL_BACKGROUND_COLOR
        textField.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        textField.textColor = UIColor.whiteColor()
        textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)])
        textField.leftViewMode = UITextFieldViewMode.Always
        textField.autocorrectionType = UITextAutocorrectionType.No
        textField.returnKeyType = .Next
        textField.delegate = self
        
        if (leftImage != nil) {
            textField.leftView = UIImageView(image: leftImage)
        }
        
        return textField
    }
    
    
    // MARK: - Overriden Methods
    
    override func updateConstraints() {
        super.updateConstraints()
        
        firstNameTextField.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self)
            update.height.equalTo()(self.CELL_HEIGHT)
            update.leading.equalTo()(self)
            update.trailing.equalTo()(self.mas_centerX)
        }
        
        lastNameTextField.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self)
            update.height.equalTo()(self.CELL_HEIGHT)
            update.leading.equalTo()(self.mas_centerX).with().offset()(self.SEPARATOR_SIZE)
            update.trailing.equalTo()(self)
        }
        
        emailTextField.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self.firstNameTextField.mas_bottom).with().offset()(self.SEPARATOR_SIZE)
            update.trailing.equalTo()(self)
            update.leading.equalTo()(self)
            update.height.equalTo()(self.CELL_HEIGHT)
        }
        
        passwordTextField.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self.emailTextField.mas_bottom).with().offset()(self.SEPARATOR_SIZE)
            update.trailing.equalTo()(self)
            update.leading.equalTo()(self)
            update.height.equalTo()(self.CELL_HEIGHT)
        }
        
        birthdayTextField.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self.passwordTextField.mas_bottom).with().offset()(self.SEPARATOR_SIZE)
            update.trailing.equalTo()(self)
            update.leading.equalTo()(self)
            update.height.equalTo()(self.CELL_HEIGHT)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        println("layoutSubviews")
        
        self.adjustInternalPadding(firstNameTextField)
        self.adjustInternalPadding(lastNameTextField)
        self.adjustInternalPadding(emailTextField)
        self.adjustInternalPadding(passwordTextField)
        self.adjustInternalPadding(birthdayTextField)
    }
    
    
    // MARK: - UITextFields helper methods
    
    private func adjustInternalPadding(textField: UITextField) {
        if (textField.leftView != nil) {
            var frame: CGRect! = textField.leftView?.frame
            textField.leftView?.contentMode = UIViewContentMode.Center
            textField.leftView?.frame = CGRectMake(CGRectGetMinX(frame),
                CGRectGetMinY(frame),
                CGRectGetWidth(frame) + CELL_WITH_ICON_TOTAL_MARGIN,
                CGRectGetHeight(frame))
        } else {
            var paddingView = UIView(frame: CGRectMake(0, 0, CELL_WITHOUT_ICON_TOTAL_MARGIN, CELL_HEIGHT))
            textField.leftView = paddingView
        }
    }
    
    private func applyDateFormatToText(text: String) -> String {
        var nonFormatedText = text
        var formatedDate = ""
        for (var i = 0; i < BIRTHDAY_FIELD_NUMBER_OF_CHARACTERS; i++) {
            if ((i == BIRTHDAY_FIRST_SEPARATOR_POSITION) || (i == BIRTHDAY_SECOND_SEPARATOR_POSITION)) {
                formatedDate = "\(formatedDate)\(BIRTHDAY_DATE_SEPARATOR)"
            } else if (!nonFormatedText.isEmpty) {
                var digitToAdd = nonFormatedText.substringToIndex(nonFormatedText.startIndex.successor())
                nonFormatedText = nonFormatedText.substringFromIndex(nonFormatedText.startIndex.successor())
                formatedDate = "\(formatedDate)\(digitToAdd)"
            } else {
                if (i < BIRTHDAY_FIRST_SEPARATOR_POSITION) {
                    formatedDate = "\(formatedDate)\(BIRTHDAY_MONTH_CHARACTER)"
                } else if (i < BIRTHDAY_SECOND_SEPARATOR_POSITION) {
                    formatedDate = "\(formatedDate)\(BIRTHDAY_DAY_CHARACTER)"
                } else {
                    formatedDate = "\(formatedDate)\(BIRTHDAY_YEAR_CHARACTER)"
                }
            }
        }
        return formatedDate
    }
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == firstNameTextField) {
            lastNameTextField.becomeFirstResponder()
        } else if (textField == lastNameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == self.emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == self.passwordTextField) {
            birthdayTextField.becomeFirstResponder()
        } else if (textField == self.birthdayTextField) {
            // TODO:
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var shouldChangeTextFieldText = true
        
        if (textField == birthdayTextField) {
            shouldChangeTextFieldText = false
            
            var stringWithDigitsOnly = birthdayTextField.text.stringByRemovingStringsIn([ BIRTHDAY_DATE_SEPARATOR, BIRTHDAY_MONTH_CHARACTER, BIRTHDAY_DAY_CHARACTER, BIRTHDAY_YEAR_CHARACTER ])
            var numberOfDigitsProvided = countElements(stringWithDigitsOnly)
            
            if (string == "" ) {
                if (numberOfDigitsProvided > 0) {
                    // Is removing the digit. Delete last number.
                    stringWithDigitsOnly.removeAtIndex(stringWithDigitsOnly.endIndex.predecessor())
                }
            } else if (numberOfDigitsProvided < BIRTHDAY_MAX_NUMBER_OF_DIGITS) {
                stringWithDigitsOnly = "\(stringWithDigitsOnly)\(string)"
            }
            textField.text = self.applyDateFormatToText(stringWithDigitsOnly)
        }
        
        // TODO: validate all fields and show next if everything is ok
        
        return shouldChangeTextFieldText
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == birthdayTextField) {
            var stringWithOnlyDigits = textField.text.stringByRemovingStringsIn([ BIRTHDAY_DATE_SEPARATOR, BIRTHDAY_MONTH_CHARACTER, BIRTHDAY_DAY_CHARACTER, BIRTHDAY_YEAR_CHARACTER ])
            if (stringWithOnlyDigits.isEmpty) {
                textField.text = NSLocalizedString("MM/DD/YYYY", comment: "Birthday date format")
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == birthdayTextField) {
            var stringWithOnlyDigits = textField.text.stringByRemovingStringsIn([ BIRTHDAY_DATE_SEPARATOR, BIRTHDAY_MONTH_CHARACTER, BIRTHDAY_DAY_CHARACTER, BIRTHDAY_YEAR_CHARACTER ])
            if (stringWithOnlyDigits.isEmpty) {
                textField.text = ""
            }
        }
    }
    
    
    // MARK: - Validation Methods
    
    private func validateFields() -> (success: Bool, errors: NSArray) {
        var validated = true
        var errorsMessage = NSMutableArray()
        
        if (firstNameTextField.text.isEmpty) {
            validated = false
            errorsMessage.addObject(NSLocalizedString("First Name is required", comment: "First Name is required"))
        }

        if (lastNameTextField.text.isEmpty) {
            validated = false
            errorsMessage.addObject(NSLocalizedString("Last Name is required", comment: "First Name is required"))
        }

        return (validated, errorsMessage)
    }
    
    
    // MARK: - Getters
    
    func getUserData() -> (firstName: String, lastName: String, email: String, password: String, birthday:String) {
        return (firstNameTextField.text, lastNameTextField.text, emailTextField.text, passwordTextField.text, birthdayTextField.text)
    }
}
