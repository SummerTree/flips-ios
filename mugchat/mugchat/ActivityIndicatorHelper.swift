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

private let ACTIVITY_INDICATOR_TAG = 99
private let ACTIVITY_INDICATOR_SIZE: CGFloat = 100
private let ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION = 0.25

class ActivityIndicatorHelper {
    
    class func showActivityIndicatorAtView(view: UIView) {
        var activityIndicator: UIActivityIndicatorView?
        for subview in view.subviews {
            if (subview.tag == ACTIVITY_INDICATOR_TAG) {
                activityIndicator = subview as? UIActivityIndicatorView
            }
        }
        
        if (activityIndicator == nil) {
            activityIndicator = ActivityIndicatorHelper.setupActivityIndicator()
            
            view.addSubview(activityIndicator!)
            
            activityIndicator!.mas_makeConstraints { (make) -> Void in
                make.center.equalTo()(view)
                make.width.equalTo()(ACTIVITY_INDICATOR_SIZE)
                make.height.equalTo()(ACTIVITY_INDICATOR_SIZE)
            }
        }
        
        view.userInteractionEnabled = false
        activityIndicator!.startAnimating()
        UIView.animateWithDuration(ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
            activityIndicator!.alpha = 0.8
        })
    }
    
    class func hideActivityIndicatorAtView(view: UIView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            view.userInteractionEnabled = true
            
            var activityIndicator: UIActivityIndicatorView?
            for subview in view.subviews {
                if (subview.tag == ACTIVITY_INDICATOR_TAG) {
                    activityIndicator = subview as? UIActivityIndicatorView
                }
            }
            
            if (activityIndicator != nil) {
                activityIndicator!.startAnimating()
                UIView.animateWithDuration(ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
                    activityIndicator!.alpha = 0
                    }, completion: { (finished) -> Void in
                        activityIndicator!.stopAnimating()
                })
            }
        })
    }
    
    private class func setupActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.backgroundColor = UIColor.blackColor()
        activityIndicator.alpha = 0
        activityIndicator.layer.cornerRadius = 8
        activityIndicator.layer.masksToBounds = true
        activityIndicator.tag = ACTIVITY_INDICATOR_TAG

        return activityIndicator
    }
}
