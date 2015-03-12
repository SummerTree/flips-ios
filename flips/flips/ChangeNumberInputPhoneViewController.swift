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

class ChangeNumberInputPhoneViewController : FlipsViewController, ChangeNumberInputPhoneViewDelegate {
    
    private var changeNumberInputPhoneView: ChangeNumberInputPhoneView!
    
    override func loadView() {
        changeNumberInputPhoneView = ChangeNumberInputPhoneView()
        changeNumberInputPhoneView.delegate = self
        
        self.view = changeNumberInputPhoneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteNavBarWithBackButton("Change Number")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.changeNumberInputPhoneView.viewWillAppear()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.changeNumberInputPhoneView.viewDidAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.changeNumberInputPhoneView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    // MARK: - ChangeNumberInputPhoneViewDelegate
    
    func makeConstraintToNavigationBarBottom(view: UIView!) {
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
        
        view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            return ()
        }
    }
    
    func changeNumberInputPhoneView(view: ChangeNumberInputPhoneView, didFinishTypingMobileNumber phone: String) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            self.hideActivityIndicator()
            let alertView = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        } else {
            checkIfPhoneNumberExists(phone)
        }
    }
    
    // MARK: - Private functions
    
    private func checkIfPhoneNumberExists(phoneNumber: String) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        UserService.sharedInstance.phoneNumberExists(phoneNumber,
            success: { (response) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                // if phone number belongs to an active user then display
                // an alert an request user to type another phone number
                let alertView = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.PHONE_NUMBER_ALREADY_EXISTS, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                self.changeNumberInputPhoneView.clearPhoneNumberField()
            },
            failure: { (error) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                // if phone number does not belong to another active user
                // then proceed to verification code screen
                let changeNumberVerificationCodeViewController = ChangeNumberVerificationCodeViewController(phoneNumber: phoneNumber, userId: User.loggedUser()?.userID)
                self.navigationController?.pushViewController(changeNumberVerificationCodeViewController, animated: true)
        })
    }
}