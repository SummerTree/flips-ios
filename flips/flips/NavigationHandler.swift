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

public let POP_TO_ROOT_NOTIFICATION_NAME = "POP_TO_ROOT_NOTIFICATION_NAME"

public class NavigationHandler : NSObject {
    
    public class var sharedInstance : NavigationHandler {
        struct Static {
            static let instance : NavigationHandler = NavigationHandler()
        }
        return Static.instance
    }
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPopToRootViewControllerNotificationReceived:", name: POP_TO_ROOT_NOTIFICATION_NAME, object: nil)
    }
    
    func onPopToRootViewControllerNotificationReceived(notification: NSNotification) {
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            if let rootViewController = keyWindow.rootViewController {
                var rootNavigationViewController: UINavigationController = rootViewController as UINavigationController

                AuthenticationHelper.sharedInstance.logout()
                if (rootNavigationViewController.visibleViewController.navigationController != rootNavigationViewController) {
                    rootNavigationViewController.popToRootViewControllerAnimated(false)
                    rootNavigationViewController.visibleViewController.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    rootNavigationViewController.popToRootViewControllerAnimated(true)
                }
            }
        }
    }
}