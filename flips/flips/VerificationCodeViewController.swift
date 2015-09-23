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

class VerificationCodeViewController: FlipsViewController, VerificationCodeViewDelegate {
    
    private let PLATFORM = "ios"
    let VERIFICATION_CODE_DID_NOT_MATCH = "Wrong validation code."
    let RESENT_SMS_MESSAGE = "3 incorrect entries. Check your messages for a new code."
    
    var verificationCodeView: VerificationCodeView!
    var countryCode : String!
    var phoneNumber: String!
    var userId: String!
    var verificationCode: String = "XXXX"
    
    init(phoneNumber: String!, countryCode: String!, userId: String!) {
        super.init(nibName: nil, bundle: nil)
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
        self.userId = userId
        
        let token = DeviceHelper.sharedInstance.retrieveDeviceToken()
        
        createDeviceForUser(userId, phoneNumber: phoneNumber.intlPhoneNumberWithCountryCode(self.countryCode), platform: PLATFORM, token: token)
    }
    
    override func loadView() {
        super.loadView()
        verificationCodeView = VerificationCodeView(phoneNumber: phoneNumber)
        verificationCodeView.delegate = self
        self.view = verificationCodeView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        verificationCodeView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        verificationCodeView.viewWillDisappear()
    }
    
    
    // MARK: - VerificationCodeViewDelegate Methods
    
    func verificationCodeView(verificatioCodeView: VerificationCodeView!, didFinishTypingVerificationCode verificationCode: String!) {
        self.verifyDevice(userId, deviceId: DeviceHelper.sharedInstance.retrieveDeviceId()!, verificationCode: verificationCode)
    }
    
    func verificationCodeViewDidTapBackButton(verificatioCodeView: VerificationCodeView!) {
        self.navigationController?.popViewControllerAnimated(true)
        verificatioCodeView.resetVerificationCodeField()
    }
    
    func verificationCodeViewDidTapResendButton(view: VerificationCodeView!) {
        view.resetVerificationCodeField()
        view.focusKeyboardOnCodeField()
        
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        UserService.sharedInstance.forgotPassword(phoneNumber.intlPhoneNumberWithCountryCode(self.countryCode), success: { (user) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            }) { (flipError) -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                
                let alertView = UIAlertView(title: NSLocalizedString("Verification Error"), message: flipError?.details, delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
        }
    }
    
    
    // MARK: - Backend Services Integration
    
    private func createDeviceForUser(userId: String, phoneNumber: String, platform: String, token: String?) {
        DeviceService.sharedInstance.createDevice(userId,
            phoneNumber: phoneNumber,
            platform: platform,
            uuid: token,
            success: { (device) in
                if (device == nil) {
                    print("Error: Device was not created")
                    return ()
                }
                DeviceHelper.sharedInstance.saveDeviceId(device!.deviceID)
            },
            failure: { (flipError) in
                print("Error trying to register device: " + flipError!.error!)
        })
    }
    
    private func verifyDevice(userId: String, deviceId: String, verificationCode: String) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        DeviceService.sharedInstance.verifyDevice(userId,
            deviceId: deviceId,
            verificationCode: verificationCode,
            phoneNumber: self.phoneNumber,
            success: { (device) in
                if (device == nil) {
                    print("Error verifying device")
                    return ()
                }
                let deviceEntity = device as! Device

                PersistentManager.sharedInstance.defineAsLoggedUserSync(deviceEntity.user)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let verificationCodeView = self.view as! VerificationCodeView
                    verificationCodeView.resetVerificationCodeField()
                    
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                    
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(RESYNC_INBOX_NOTIFICATION_NAME, object: nil, userInfo: nil)
                })
            },
            failure: { (flipError) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                    if (flipError!.error == self.VERIFICATION_CODE_DID_NOT_MATCH || flipError!.error == self.RESENT_SMS_MESSAGE) {
                        let verificationCodeView = self.view as! VerificationCodeView
                        verificationCodeView.didEnterWrongVerificationCode()
                    } else if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
                        self.hideActivityIndicator()
                        let alertView = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    } else {
                        print("Device code verification error: " + flipError!.error!)
                        let verificationCodeView = self.view as! VerificationCodeView
                        verificationCodeView.resetVerificationCodeField()
                        verificationCodeView.focusKeyboardOnCodeField()
                    }
                })
            })
    }
    
    
    // MARK: - Required methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
