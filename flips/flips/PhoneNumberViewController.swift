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

class PhoneNumberViewController: FlipsViewController, PhoneNumberViewDelegate {
    
    var phoneNumberView: PhoneNumberView!
    var userId: String!
    
    private var username: String!
    private var password: String!
    private var firstName: String!
    private var lastName: String!
    private var nickname: String?
    private var avatar: UIImage!
    private var birthday: NSDate!
    private var facebookId: String?
    
    init(userId: String!) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
    }
    
    convenience init(username: String, password: String, firstName: String, lastName: String, avatar: UIImage, birthday: String!, nickname: String?, facebookId: String?) {
        
        self.init(userId: nil)
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.birthday = birthday.dateValue()
        self.nickname = nickname
        self.facebookId = facebookId
    }
    
    override func loadView() {
        super.loadView()
        phoneNumberView = PhoneNumberView()
        phoneNumberView.delegate = self
        self.view = phoneNumberView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        phoneNumberView.viewWillAppear()
        phoneNumberView.focusKeyboardOnMobileNumberField()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        phoneNumberView.viewWillDisappear()
    }
    
    
    // MARK: - PhoneNumberViewDelegate Methods
    
    func phoneNumberView(phoneNumberView: PhoneNumberView!, didFinishTypingMobileNumber mobileNumber: String!, withCountryCode countryCode: String!) {
        self.showActivityIndicator()
        if (self.userId == nil) {
            UserService.sharedInstance.signUp(self.username,
                password: self.password,
                firstName: self.firstName,
                lastName: self.lastName,
                avatar: self.avatar,
                birthday: self.birthday,
                nickname: self.nickname,
                phoneNumber: mobileNumber.intlPhoneNumberWithCountryCode(countryCode),
                facebookId: self.facebookId,
                success: { (user) -> Void in
                    self.hideActivityIndicator()
                    let userEntity = user as! User
                    let verificationCodeViewController = VerificationCodeViewController(phoneNumber: mobileNumber, countryCode: countryCode, userId: userEntity.userID)
                    self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
                    self.hideActivityIndicator()
                    
                }) { (flipError) -> Void in
                    self.hideActivityIndicator()
                    print("Error in the sign up [error=\(flipError!.error), details=\(flipError!.details)]")
                    var detail = flipError!.error
                    
                    if let hasDetail = flipError!.details {
                        detail = hasDetail
                    }
                    
                    let alertView = UIAlertView(title: flipError!.error, message: detail, delegate: self, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
            }
        } else {
            self.hideActivityIndicator()
            let verificationCodeViewController = VerificationCodeViewController(phoneNumber: mobileNumber, countryCode: countryCode, userId: self.userId)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }
    }
    
    func phoneNumberViewDidTapBackButton(view: PhoneNumberView!) {
        print(self.previousViewController())
        if (self.previousViewController()!.isKindOfClass(SplashScreenViewController.self) ||
            self.previousViewController()!.isKindOfClass(LoginViewController.self)) {
                AuthenticationHelper.sharedInstance.logout()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Required methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
