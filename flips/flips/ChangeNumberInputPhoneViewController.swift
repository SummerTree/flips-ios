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

class ChangeNumberInputPhoneViewController : FlipsViewController, ChangeNumberInputPhoneViewDelegate, UIAlertViewDelegate {
    
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
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as! UIView
        
        view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            return ()
        }
    }
    
    func changeNumberInputPhoneView(view: ChangeNumberInputPhoneView, didFinishTypingMobileNumber phone: String, countryCode: String!) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            self.hideActivityIndicator()
            let alertView = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        } else {
            if (phone == User.loggedUser()!.formattedPhoneNumber()) {
                let alertView = UIAlertView(title: NSLocalizedString("Change Number Error"), message: NSLocalizedString("You have entered the same number you currently have in use. No changes saved."), delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            } else {
                checkIfPhoneNumberExists(phone, countryCode: countryCode)
            }
        }
    }
    
    // MARK: - UIAlertViewDelegate functions
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.changeNumberInputPhoneView.clearPhoneNumberField()
    }
    
    // MARK: - Private functions
    
    private func checkIfPhoneNumberExists(phoneNumber: String, countryCode: String) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        UserService.sharedInstance.phoneNumberExists(phoneNumber, countryCode: countryCode,
            success: { (response) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                let exists = response as! Bool
                if (exists as Bool) {
                    let alertView = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.PHONE_NUMBER_ALREADY_EXISTS, delegate: self, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                } else {
                    let changeNumberVerificationCodeViewController = ChangeNumberVerificationCodeViewController(phoneNumber: phoneNumber, countryCode: countryCode, userId: User.loggedUser()?.userID)
                    self.navigationController?.pushViewController(changeNumberVerificationCodeViewController, animated: true)
                }
            },
            failure: { (flipError) in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                let alertView = UIAlertView(title: NSLocalizedString("Change Number Error"), message: flipError?.error, delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
        })
    }
}