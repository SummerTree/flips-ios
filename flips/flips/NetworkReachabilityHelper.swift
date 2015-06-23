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

let NETWORK_REACHABILITY_CHANGED_NOTIFICATION_KEY: String = "network_reachability_notification"

public class NetworkReachabilityHelper {
    
    // MARK: - Singleton
    
    public class var sharedInstance : NetworkReachabilityHelper {
        struct Static {
            static let instance : NetworkReachabilityHelper = NetworkReachabilityHelper()
        }
        return Static.instance
    }
    
    func startMonitoring() {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status) -> Void in
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            switch(status) {
            case AFNetworkReachabilityStatus.ReachableViaWiFi:
                println("Reachable via WiFi")
            case AFNetworkReachabilityStatus.ReachableViaWWAN:
                println("Reachable via WWAN 3G/4G")
            case AFNetworkReachabilityStatus.NotReachable:
                println("Not Reachable")
            default:
                println("Default [status=\(status.rawValue)]")
            }
            NSNotificationCenter.defaultCenter().postNotificationName(NETWORK_REACHABILITY_CHANGED_NOTIFICATION_KEY, object: nil)
        }
    }
    
    func hasInternetConnection() -> Bool {
        return AFNetworkReachabilityManager.sharedManager().reachable
    }
}