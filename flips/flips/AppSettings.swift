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

import Foundation

class AppSettings {
    
    class var sharedInstance: AppSettings {
        struct Static {
            static let instance: AppSettings = AppSettings()
        }
        return Static.instance
    }

    class func currentSettings() -> AppSettings {
        return sharedInstance;
    }
    
    private var envSettings: NSDictionary
    
    init(env: String) {
        let appSettings = NSBundle.mainBundle().infoDictionary!["AppSettings"] as! NSDictionary
        envSettings = appSettings[env] as! NSDictionary
    }
    
    convenience init() {
        var currentEnv = "QA"
        
        #if DEV
            currentEnv = "DEV"
        #endif

        #if PROD
            currentEnv = "PROD"
        #endif

        self.init(env: currentEnv)
    }
    
    func serverURL() -> String {
        return envSettings["ServerURL"] as! String
    }

    func pubNubPublishKey() -> String {
        return envSettings["PubNubPublishKey"] as! String
    }
    
    func pubNubSubscribeKey() -> String {
        return envSettings["PubNubSubscribeKey"] as! String
    }
    
    func pubNubSecretKey() -> String {
        return envSettings["PubNubSecretKey"] as! String
    }
    
}