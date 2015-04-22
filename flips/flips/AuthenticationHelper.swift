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
    private let LAST_STOCK_FLIPS_SYNC_AT = "lastStockFlipsUpdatedAt"

    func onLogin(user: User) {
        PubNubService.sharedInstance.connect()
        saveAuthenticatedUsername(user.username)
    }
    
    func isAuthenticated() -> Bool {
        if let user = User.loggedUser() {
            return true
        }
        
        return false
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
    
    private func resetTimestampForStockFlips() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(nil, forKey: LAST_STOCK_FLIPS_SYNC_AT)
        userDefaults.synchronize()
    }
    
    func saveLastTimestampForStockFlip(timestamp: NSDate) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if let lastTimestamp = (userDefaults.valueForKey(self.LAST_STOCK_FLIPS_SYNC_AT) as NSDate?) {
            if (lastTimestamp.compare(timestamp) == NSComparisonResult.OrderedAscending) {
                userDefaults.setValue(timestamp, forKey: LAST_STOCK_FLIPS_SYNC_AT)
            }
        } else {
            userDefaults.setValue(timestamp, forKey: LAST_STOCK_FLIPS_SYNC_AT)
        }
        userDefaults.synchronize()
    }

    
    func retrieveAuthenticatedUsernameIfExists() -> String? {
        var loggedUserInfo = User.isUserLoggedIn()
        var userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.valueForKey(LOGIN_USERNAME_KEY) as String?
    }
    
    func logout() {
        if let userInSession = User.loggedUser() {
            if let facebookID = userInSession.facebookID {
                if !facebookID.isEmpty {
                    self.removeAuthenticatedUsername()
                }
            }
        }

        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
        FBSession.setActiveSession(nil)
        
        DeviceHelper.sharedInstance.setLastTimeUserSynchronizePrivateChannel(nil)
        DeviceHelper.sharedInstance.setSyncViewShown(false)
        
        RemoteRequestManager.sharedInstance.cleanQueue()
        
        CoreDataHandler.sharedInstance.resetDatabase()
        
        FlipsCache.sharedInstance.clear()
        ThumbnailsCache.sharedInstance.clear()
        BlurredThumbnailsCache.sharedInstance.clear()
        AvatarCache.sharedInstance.clear()

        PubNubService.sharedInstance.disconnect()
        
        self.resetTimestampForStockFlips()
        
    }

    
    // MARK: - Singleton method
    
    public class var sharedInstance : AuthenticationHelper {
    struct Static {
        static let instance : AuthenticationHelper = AuthenticationHelper()
        }
        return Static.instance
    }
}
