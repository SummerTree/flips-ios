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

private let ONBORDING_HAS_BEEN_SHOWN_KEY = "onboardingHasBeenShown"

class OnboardingHelper: NSObject {
    
    class func onboardingHasBeenShown() -> Bool {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if let showOnboarding = userDefaults.valueForKey(ONBORDING_HAS_BEEN_SHOWN_KEY) as? Bool {
            return showOnboarding
        }
        return false
    }
    
    class func setOnboardingHasShown() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(true, forKey: ONBORDING_HAS_BEEN_SHOWN_KEY)
        userDefaults.synchronize()
    }
    
}
