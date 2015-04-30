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

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let BUGSENSE_KEY = "2b57f78e"
    private let FLURRY_KEY = "7CCBCSMWJQ395RJKDP5Y"
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        NetworkReachabilityHelper.sharedInstance.startMonitoring()

        // Registering for BugSense
        Mint.sharedInstance().initAndStartSession(BUGSENSE_KEY)
        
        Flurry.startSession(FLURRY_KEY)
        
        // Registering for receive messages
        MessageReceiver.sharedInstance.startListeningMessages()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        CoreDataHandler.sharedInstance.setupDatabase()
    
        if (launchOptions != nil) {
            if let pushNotificationPayload = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                self.onAppLaunchedFromNotification(application, withUserInfo: pushNotificationPayload)
            } else {
                openSplashScreen()
            }
        } else {
            openSplashScreen()
        }
        
        NavigationHandler.sharedInstance.registerForNotifications()
        
        // register for push notifications
        
        if (DeviceHelper.sharedInstance.systemVersion() >= 8.0) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge), categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Badge)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            TempFiles.clearTempFiles()
        })
        
        return true;
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        self.checkSession(
            {() -> Void in
                application.applicationIconBadgeNumber = 0
                FBAppCall.handleDidBecomeActive()
            }, failureBlock: { (error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let flipError: FlipError = error {
                        let alertMessage = UIAlertView(title: flipError.error, message: flipError.details, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                        alertMessage.show()
                    }
                })
            })
    }

    func applicationWillTerminate(application: UIApplication) {
        MagicalRecord.cleanUp()
    }
    
    func application(application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: String) -> Bool {
        return extensionPointIdentifier != "com.apple.keyboard-service"
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        if let loggedUser = User.loggedUser() {
            application.applicationIconBadgeNumber = loggedUser.countUnreadMessages()
        }
    }
    
    // MARK: - Notification Methods
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        println("token: \(token)")
        DeviceHelper.sharedInstance.saveDeviceToken(token)
        DeviceHelper.sharedInstance.saveDeviceTokenAsNsData(deviceToken)
        PubNubService.sharedInstance.enablePushNotificationOnMyChannels()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if (identifier == "declineAction") {
            println("User did not allow to receive push notifications")
        } else if (identifier == "answerAction") {
            println("User allowed to receive push notifications")
        }
    }
    
    /*
     * If the user opens your app from the system-displayed alert, the system may call this method again when your app is about 
     * to enter the foreground so that you can update your user interface and display information pertaining to the notification.
     */
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // When user opens the app from a notification alert the aplication state is active, but not necessarily the app is foreground.
        if (application.applicationState == UIApplicationState.Inactive) {
            self.onAppLaunchedFromNotification(application, withUserInfo: userInfo)
        } else {
            self.incrementBadgeCounter()
        }
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.description)
    }
    
    
    // MARK: - Badge functions
    
    func incrementBadgeCounter() -> Int {
        var newValue = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = newValue
        return newValue
    }
    
    
    // MARK: - private functions
    
    private func openSplashScreen(roomID: String? = nil, andFlipMessageID flipMessageID: String? = nil) {
        let splashScreenViewController = SplashScreenViewController(roomID: roomID, flipMessageID: flipMessageID)
        let navigationViewControler = FlipsUINavigationController(rootViewController: splashScreenViewController)
        self.window?.rootViewController = navigationViewControler
        self.window?.makeKeyAndVisible()
    }
  
    private func onAppLaunchedFromNotification(application: UIApplication, withUserInfo userInfo: [NSObject : AnyObject]) {
        if let loggedUser = User.loggedUser() {
            if let roomId: String = String.stringFromValue(userInfo[NOTIFICATION_ROOM_KEY]) {
                let flipMessageId: String? = String.stringFromValue(userInfo[NOTIFICATION_FLIP_MESSAGE_KEY])
                if (UIApplication.sharedApplication().keyWindow == nil)  {
                    self.openSplashScreen(roomID: roomId, andFlipMessageID: flipMessageId)
                } else if (application.applicationState != UIApplicationState.Active) {
                    NavigationHandler.sharedInstance.showThreadScreenForRoomId(roomId, andFlipMessageID: flipMessageId)
                }
            }
        }
    }
    
    private func checkSession(successBlock: () -> (), failureBlock: (FlipError?) -> ()) {
        if let user = User.loggedUser()? {
            let userId = user.userID
            SessionService.sharedInstance.checkSession(
                userId,
                success: { (success) -> Void in
                    successBlock()
                },
                failure: { (error) -> Void in
                    failureBlock(error?)
                }
            )
        } else {
            successBlock()
        }
    }
}