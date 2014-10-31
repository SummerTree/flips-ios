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

public class AuthenticationHelper: NSObject {

    private let LOGIN_USERNAME_KEY = "username"
    
    var userInSession: User! {
        willSet(newUser) {
            if (newUser != nil) {
                self.userInSession = newUser
                println("User pubnubId: '\(newUser.pubnubID)'")
                PubNubService.sharedInstance.connect()
                
                // Used to auto-fill the field in the login screen
                saveAuthenticatedUsername(newUser.username)
            }
        }
    }
    
    private func saveAuthenticatedUsername(username: String) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(username, forKey: LOGIN_USERNAME_KEY)
        userDefaults.synchronize()
    }

    private func removeAuthenticatedUsername() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey(LOGIN_USERNAME_KEY)
        userDefaults.synchronize()
    }
    
    func retrieveAuthenticatedUsernameIfExists() -> String? {
        var loggedUserInfo = User.isUserLoggedIn()
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(LOGIN_USERNAME_KEY) as String?
    }
    
    func logout() {
        self.userInSession = nil
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
        FBSession.setActiveSession(nil)
        
        CoreDataHandler.sharedInstance.resetDatabase()
        
        // Unregister for push notifications
        UIApplication.sharedApplication().unregisterForRemoteNotifications()
    }

    
    // MARK: - Singleton method
    
    public class var sharedInstance : AuthenticationHelper {
    struct Static {
        static let instance : AuthenticationHelper = AuthenticationHelper()
        }
        return Static.instance
    }
}