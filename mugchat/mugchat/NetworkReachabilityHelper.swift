//
//  NewFlipViewController.swift
//  mugchat
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

public class NetworkReachabilityHelper {
    
    private var hasConnection: Bool! = true
    
    
    // MARK: - Singleton
    
    public class var sharedInstance : NetworkReachabilityHelper {
        struct Static {
            static let instance : NetworkReachabilityHelper = NetworkReachabilityHelper()
        }
        return Static.instance
    }
    
    func startMonitoring() {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        println("Starting with connect \(self.hasConnection)")
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (status) -> Void in
            
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            switch(status) {
            case AFNetworkReachabilityStatus.ReachableViaWiFi,
                AFNetworkReachabilityStatus.ReachableViaWWAN:
                
                println("Reachable")
                self.hasConnection = true
                
            case AFNetworkReachabilityStatus.NotReachable:
                println("Not Reachable")
                self.hasConnection = false
            default:
                println("Default [status=\(status.rawValue)]")
                
            }
        }
    }
}