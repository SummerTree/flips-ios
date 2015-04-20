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

public class DeviceHelper: NSObject {
    
    private let DEVICE_TOKEN = "device_token"
    private let DEVICE_TOKEN_NSDATA = "device_token_nsdata"
    private let DEVICE_ID = "device_id"
    
    private let BUILDER_ONBOARDING_SEEN_KEY = "builder.onboarding.seen"
    
    private let LAST_DATE_USER_SYNCHRONIZED_PRIVATE_CHANNEL = "last_sync_user_date"
    
    private let SYNC_VIEW_SHOWN: String = "sync_view_shown"
    
    
    // MARK: - Singleton
    
    public class var sharedInstance : DeviceHelper {
    struct Static {
        static let instance : DeviceHelper = DeviceHelper()
        }
        return Static.instance
    }
    
    
    // MARK: - Device Screen
    
    func isDeviceModelLessOrEqualThaniPhone5S() -> Bool {
        return DeviceScreenSize.screenRect.size.height <= 568
    }
    
    func isDeviceModelLessOrEqualThaniPhone4S() -> Bool {
        return DeviceScreenSize.screenRect.size.height <= 480
    }
    
    struct DeviceScreenSize {
        static let screenRect: CGRect = UIScreen.mainScreen().bounds
    }
    
    
    // MARK: - Device System Version
    
    func systemVersion() -> Float {
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue
    }
    
    
    // MARK: - Save Device Data on User Defaults
    
    func saveDeviceToken(token: String?) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if (token == nil) {
            userDefaults.removeObjectForKey(DEVICE_TOKEN)
        } else {
            userDefaults.setValue(token, forKey: DEVICE_TOKEN)
        }
        userDefaults.synchronize()
    }
    
    func saveDeviceTokenAsNsData(token: NSData?) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if (token == nil) {
            userDefaults.removeObjectForKey(DEVICE_TOKEN_NSDATA)
        } else {
            userDefaults.setValue(token, forKey: DEVICE_TOKEN_NSDATA)
        }
        userDefaults.synchronize()
    }
    
    func saveDeviceId(deviceId: String?) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if (deviceId == nil) {
            userDefaults.removeObjectForKey(DEVICE_ID)
        } else {
            userDefaults.setValue(deviceId, forKey: DEVICE_ID)
        }
        userDefaults.synchronize()
    }
    
    func removeDeviceToken() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(DEVICE_TOKEN)
        userDefaults.synchronize()
    }
    
    func removeDeviceTokenAsNsData() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(DEVICE_TOKEN_NSDATA)
        userDefaults.synchronize()
    }
    
    func removeDeviceId() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(DEVICE_ID)
        userDefaults.synchronize()
    }
    
    func retrieveDeviceToken() -> String? {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(DEVICE_TOKEN) as String?
    }
    
    func retrieveDeviceTokenAsNSData() -> NSData? {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(DEVICE_TOKEN_NSDATA) as NSData?
    }
    
    func retrieveDeviceId() -> String? {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(DEVICE_ID) as String?
    }
    
    func setBuilderIntroductionShown() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let userId = User.loggedUser()?.userID

        var onboardingSeenArray = userDefaults.objectForKey(BUILDER_ONBOARDING_SEEN_KEY) as Array<String>?

        if (onboardingSeenArray == nil) {
            onboardingSeenArray = Array<String>()
        }

        if (find(onboardingSeenArray!, userId!) == nil) {
            onboardingSeenArray!.append(userId!)
        }

        userDefaults.setObject(onboardingSeenArray, forKey: BUILDER_ONBOARDING_SEEN_KEY)
        userDefaults.synchronize()
    }

    func didUserAlreadySeenBuildIntroduction() -> Bool {
        let userId = User.loggedUser()?.userID

        let userDefaults = NSUserDefaults.standardUserDefaults()
        let onboardingSeenArray = userDefaults.objectForKey(BUILDER_ONBOARDING_SEEN_KEY) as Array<String>?

        if (onboardingSeenArray == nil) {
            return false
        }

        if (find(onboardingSeenArray!, userId!) != nil) {
            return true
        }
        
        return false
    }
    
    func lastTimeUserSynchronizedPrivateChannel() -> NSDate? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.objectForKey(LAST_DATE_USER_SYNCHRONIZED_PRIVATE_CHANNEL) as NSDate?
    }
    
    func setLastTimeUserSynchronizePrivateChannel(date: NSDate?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (date != nil) {
            userDefaults.setObject(date, forKey: LAST_DATE_USER_SYNCHRONIZED_PRIVATE_CHANNEL)
        } else {
            userDefaults.removeObjectForKey(LAST_DATE_USER_SYNCHRONIZED_PRIVATE_CHANNEL)
        }
        userDefaults.synchronize()
    }
    
    func didShowSyncView() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.boolForKey(SYNC_VIEW_SHOWN)
    }
    
    func setSyncViewShown(value: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(value, forKey: SYNC_VIEW_SHOWN)
    }
}
