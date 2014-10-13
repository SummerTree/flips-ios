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

public class MugChatHandler : NSObject, PubNubServiceDelegate {
    
    
    // MARK: - Singleton method
    
    public class var sharedInstance : MugChatHandler {
    struct Static {
        static let instance : MugChatHandler = MugChatHandler()
        }
        return Static.instance
    }
    
    
    // MARK: - Initializations
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
    
    
    // Messages Handlers
    
    private func onMessageReceived(message: MugMessage!) {
        println("Message received.")
        println("Sender = \(message.sender)")
        println("Mugs = \(message.mugs)")
        
        // TODO: save the message in the core data
        // TODO: start a queue to download all pending info
        // TODO: 
        // TODO: when finished, broadcast a message to listenners

        
    }
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: MugMessage!) {
    }
}