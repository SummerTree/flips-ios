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
    private let DEVICE_ID = "device_id"
    
    private let ALREADY_SEEN_INTRODUCTION_KEY = "builder.introduction.watched"
    
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
    
    func removeDeviceId() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(DEVICE_ID)
        userDefaults.synchronize()
    }
    
    func retrieveDeviceToken() -> String? {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(DEVICE_TOKEN) as String?
    }
    
    func retrieveDeviceId() -> String? {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(DEVICE_ID) as String?
    }
    
    func setBuilderIntroductionShown(hasShow: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(hasShow, forKey: ALREADY_SEEN_INTRODUCTION_KEY)
        userDefaults.synchronize()
    }
    
    func didUserAlreadySeeBuildIntroduction() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let alreadySeenIntroduction = userDefaults.objectForKey(ALREADY_SEEN_INTRODUCTION_KEY) as Bool?
        if (alreadySeenIntroduction != nil) {
            return alreadySeenIntroduction!
        }
        
        return false
    }
}
