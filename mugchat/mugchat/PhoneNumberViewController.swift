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

class PhoneNumberViewController: MugChatViewController, PhoneNumberViewDelegate {
    
    var phoneNumberView: PhoneNumberView!
    var userId: String!
    
    private var username: String!
    private var password: String!
    private var firstName: String!
    private var lastName: String!
    private var nickname: String?
    private var avatar: UIImage!
    private var birthday: NSDate!
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
    }
    
    convenience init(username: String, password: String, firstName: String, lastName: String, avatar: UIImage, birthday: String!, nickname: String?) {
        
        self.init(nibName: nil, bundle: nil)
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.avatar = avatar
        self.birthday = birthday.dateValue()
        self.nickname = nickname
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
    
    func phoneNumberView(phoneNumberView: PhoneNumberView!, didFinishTypingMobileNumber mobileNumber: String!) {
        
        self.showActivityIndicator()
        if (self.userId == nil) {
            UserService.sharedInstance.signUp(self.username,
                password: self.password,
                firstName: self.firstName,
                lastName: self.lastName,
                avatar: self.avatar,
                birthday: self.birthday,
                nickname: self.nickname,
                phoneNumber: mobileNumber,
                success: { (user) -> Void in
                    self.hideActivityIndicator()
                    var userEntity = user as User
                    var verificationCodeViewController = VerificationCodeViewController(phoneNumber: mobileNumber, userId: userEntity.userID)
                    self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
                    self.hideActivityIndicator()
                    
                }) { (mugError) -> Void in
                    self.hideActivityIndicator()
                    println("Error in the sign up [error=\(mugError!.error), details=\(mugError!.details)]")
                    var alertView = UIAlertView(title: "SignUp Error", message: mugError!.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
            }
        } else {
            self.hideActivityIndicator()
            var verificationCodeViewController = VerificationCodeViewController(phoneNumber: mobileNumber, userId: self.userId)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }
    }
    
    func phoneNumberViewDidTapBackButton(view: PhoneNumberView!) {
        println(self.previousViewController())
        if (self.previousViewController()!.isKindOfClass(SplashScreenViewController.self) ||
            self.previousViewController()!.isKindOfClass(LoginViewController.self)) {
                AuthenticationHelper.sharedInstance.logout()
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
