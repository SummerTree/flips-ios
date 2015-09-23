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

private let ONBORDING_HAS_BEEN_SHOWN_KEY = "onboardingHasBeenShown"

import MediaPlayer

class OnboardingHelper: NSObject {
    
    class func onboardingHasBeenShown() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let showOnboarding = userDefaults.valueForKey(ONBORDING_HAS_BEEN_SHOWN_KEY) as? Bool {
            return showOnboarding
        }
        return false
    }
    
    class func setOnboardingHasShown() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(true, forKey: ONBORDING_HAS_BEEN_SHOWN_KEY)
        userDefaults.synchronize()
    }

    class func presentOnboardingAtViewController(viewController: UIViewController) -> MPMoviePlayerController {
        let videoURL = NSBundle.mainBundle().URLForResource("flips-tutorial", withExtension: "mp4")
        let tutorialViewController = MPMoviePlayerViewController(contentURL: videoURL);
        tutorialViewController.moviePlayer.shouldAutoplay = true

        viewController.presentViewController(tutorialViewController, animated: true, completion: nil)
        return tutorialViewController.moviePlayer
    }
}
