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

private struct ChatMessageJsonParams {
    static let FROM = "from"
    static let USER_ID = "userID"
    static let NAME = "name"
    static let PARTICIPANTS = "participants"
    static let ROOM_ID = "roomID"
    static let CONTENT = "content"
    static let CONTENT_ID = "id"
    static let CONTENT_WORD = "word"
    static let CONTENT_BACKGROUND_URL = "backgroundURL"
    static let CONTENT_SOUND_URL = "soundURL"
}

public class MessageReceiver: NSObject, PubNubServiceDelegate {
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        return Static.instance
    }
    
    private func onMessageReceived(mugMessage: MugMessage) {
        // Notify any screen that there is a new message
        println("New Message Received")
        println("   From: \(mugMessage.from.firstName)")
        println("   Sent at: \(mugMessage.createdAt)")
        println("   #mugs: \(mugMessage.mugs.count)")
        
        for var i = 0; i < mugMessage.mugs.count; i++ {
            println("       mug #\(mugMessage.mugs.objectAtIndex(i).mugID)")
        }
    }
    
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, fromChannelName: String, sentAt: NSDate) {
        let mugMessageDataSource = MugMessageDataSource()
        let mugMessage = mugMessageDataSource.createMugMessageWithJson(messageJson, receivedAtChannel: fromChannelName, sentAt: sentAt)
        self.onMessageReceived(mugMessage)
    }
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
}