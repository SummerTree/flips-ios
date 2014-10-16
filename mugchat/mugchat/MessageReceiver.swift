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

public class MessageReceiver: NSObject, PubNubServiceDelegate {
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        return Static.instance
    }
    
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: MugMessage!) {
//        println("Message received.")
//        println("Sender = \(message.sender)")
//        println("Mugs = \(message.mugs)")
    }
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
}