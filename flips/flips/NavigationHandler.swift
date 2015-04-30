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

public let POP_TO_ROOT_NOTIFICATION_NAME = "POP_TO_ROOT_NOTIFICATION_NAME"
public let POP_TO_CHAT_NOTIFICATION_NAME = "POP_TO_CHAT_NOTIFICATION_NAME"

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
                if rootViewController is UINavigationController {
                    var rootNavigationViewController: UINavigationController = rootViewController as UINavigationController
                    
                    if (AuthenticationHelper.sharedInstance.isAuthenticated()) {
                        AuthenticationHelper.sharedInstance.logout()
                    }
                    if (rootNavigationViewController.visibleViewController.navigationController != rootNavigationViewController) {
                        rootNavigationViewController.popToRootViewControllerAnimated(false)
                        rootNavigationViewController.visibleViewController.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        rootNavigationViewController.popToRootViewControllerAnimated(true)
                        if ((rootNavigationViewController.viewControllers.count == 1) && (rootNavigationViewController.viewControllers[0] is SplashScreenViewController)) {
                            let splashViewController = rootNavigationViewController.viewControllers[0] as SplashScreenViewController
                            splashViewController.openLoginViewController()
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        
                        let responseCode : Int = notification.userInfo![FlipsServiceResponseCode.RESPONSE_CODE_KEY] as Int
                        self.showAlertView(responseCode)
                        
                    }
                }
            }
        }
    }
    
    private func showAlertView(responseCode : Int) {
        var title, message : String
        
        switch responseCode {
        case FlipsServiceResponseCode.BACKEND_FORBIDDEN_REQUEST:
            title = NSLocalizedString("Session Expired")
            message = NSLocalizedString("Please try to log in again. If the issue persists, please contact support.")
        case FlipsServiceResponseCode.BACKEND_BLOCKED_USER:
            title = NSLocalizedString("Account Disabled")
            message = NSLocalizedString("Please contact Flips Support via www.flipsapp.com.")
        default:
            title = NSLocalizedString("Server Error")
            message = NSLocalizedString("Please try to log in again. If the issue persists, please contact support.")
        }
        
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
        alertView.show()
    }
    
    func showThreadScreenForRoomId(roomId: String, andFlipMessageID flipMessageID: String?) {
        if let keyWindow = UIApplication.sharedApplication().keyWindow {
            if let rootViewController: UIViewController = keyWindow.rootViewController {
                if (rootViewController is UINavigationController) {
                    let rootNavigationViewController: UINavigationController = rootViewController as UINavigationController
                    let roomDataSource = RoomDataSource()
                    let room = roomDataSource.getRoomById(roomId)
                    
                    let completionBlock: () -> Void = { () -> Void in
                        var inboxViewController: InboxViewController? = nil
                        
                        if (room != nil) {
                            for viewController in rootNavigationViewController.childViewControllers {
                                if (viewController is InboxViewController) {
                                    inboxViewController = viewController as? InboxViewController
                                    rootNavigationViewController.popToViewController(inboxViewController!, animated: false)
                                    break
                                }
                            }
                            
                            if (inboxViewController != nil) {
                                let chatViewController: UIViewController = ChatViewController(room: room!, andFlipMessageIdFromPushNotification: flipMessageID)
                                rootNavigationViewController.pushViewController(chatViewController, animated: true)
                            }
                        } else {
                            for viewController in rootNavigationViewController.childViewControllers {
                                if (viewController is InboxViewController) {
                                    inboxViewController = viewController as? InboxViewController
                                    inboxViewController?.prepareToLoadPushNotificationForRoomId(roomId, andFlipMessageId: nil)
                                    rootNavigationViewController.popToViewController(inboxViewController!, animated: false)
                                    break
                                }
                            }
                        }
                    }
                    
                    // Checking if the app is showing a modal
                    if (rootNavigationViewController.visibleViewController.navigationController != rootNavigationViewController) {
                        self.dismissVisibleModalFromRootViewController(rootNavigationViewController, withCompletion: completionBlock)
                    } else {
                        completionBlock()
                    }
                }
            }
        }
        
    }
    
    private func dismissVisibleModalFromRootViewController(rootNavigationViewController: UINavigationController, withCompletion completion: () -> Void) {
        if (rootNavigationViewController.visibleViewController.presentingViewController != nil) {
            rootNavigationViewController.visibleViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                self.dismissVisibleModalFromRootViewController(rootNavigationViewController, withCompletion: completion)
            })
        } else {
            completion()
        }
    }
}