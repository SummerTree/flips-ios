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

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Registering for receive messages
        MessageReceiver.sharedInstance.startListeningMessages()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        CoreDataHandler.sharedInstance.resetDatabase()
        CoreDataHandler.sharedInstance.setupDatabase()

        let splashScreenViewController = SplashScreenViewController()
        let navigationViewControler = UINavigationController(rootViewController: splashScreenViewController)
        
        self.window?.rootViewController = navigationViewControler
        self.window?.makeKeyAndVisible()
        
        // register for push notifications
        
        if (DeviceHelper.sharedInstance.systemVersion() >= 8.0) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: (UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge), categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Badge)
        }
        
        return true;
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActive()
    }

    func applicationWillTerminate(application: UIApplication) {
        MagicalRecord.cleanUp()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        println("token: \(token)")
        DeviceHelper.sharedInstance.saveDeviceToken(token)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if (identifier == "declineAction") {
            println("User did not allow to receive push notifications")
            // TODO
        } else if (identifier == "answerAction") {
            println("User allowed to receive push notifications")
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.description)
    }

}

