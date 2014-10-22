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
    
    
    // MARK: - PubnubServiceDelegate
    
//    func pubnubClient(client: PubNub!, didReceiveMessage message: MugMessage!) {
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, channelName: String) {
        
        //        "from": {
        //            "userID": 138,
        //            "name": "Bruno Brüggemann"
        //        },
        let userFromJson = messageJson[ChatMessageJsonParams.FROM]
        let fromUserId = userFromJson[ChatMessageJsonParams.USER_ID]
        let fromUserName = userFromJson[ChatMessageJsonParams.NAME]
        
//        "participants": [{
//        "userID": 8,
//        "name": "Diego Santiviago"
//        }, {
//        "userID": 138,
//        "name": "Bruno Brüggemann"
//        }],
//        "roomID": 1,
//        "content": [{
//        "id": 1,
//        "word": "I",
//        "backgroundURL": "http://unbridledsuccess.co.uk/wp-content/uploads/2012/11/rainbow_letter_i_photosculpture-p153807374388565225bfr64_400.jpg",
//        "soundURL": "http://"
//        }, {
//        "id": 2,
//        "word": "love",
//        "backgroundURL": "https://pbs.twimg.com/profile_images/2201498558/400x400-heart.jpg",
//        "soundURL": "http://"
//        }, {
//        "id": 3,
//        "word": "San Francisco",
//        "backgroundURL": "https://pbs.twimg.com/profile_images/1386398483/sanfrancisco3_400x400.jpg",
//        "soundURL": "http://"
//        }]
    
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