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

public class PubNubService: MugchatService, PNDelegate {
    
    private let PUBNUB_ORIGIN = "pubsub.pubnub.com"
    private let PUBNUB_PUBLISH_KEY = "pub-c-0f705157-1c76-450a-99e9-59342f271f12"
    private let PUBNUB_SUBSCRIBE_KEY = "sub-c-8047a8dc-3853-11e4-8736-02ee2ddab7fe"
    private let PUBNUB_SECRET_KEY = "sec-c-M2Y5YTNmMjEtOTUwMi00Yzg3LWEyNzgtMmM1YmJmYThkOTk2"
    
    var delegate: PubNubServiceDelegate?
    
    override init() {
        super.init()
        var pubnubConfiguration = PNConfiguration(forOrigin: PUBNUB_ORIGIN,
            publishKey: PUBNUB_PUBLISH_KEY,
            subscribeKey: PUBNUB_SUBSCRIBE_KEY,
            secretKey: PUBNUB_SECRET_KEY)
        
        PubNub.setConfiguration(pubnubConfiguration)
        PubNub.setDelegate(self)
    }
    
    public class var sharedInstance : PubNubService {
        struct Static {
            static let instance : PubNubService = PubNubService()
        }

        return Static.instance
    }
    
    func connect() {
        
        if (!PubNub.sharedInstance().isConnected()) {
            PubNub.connect()
            self.subscribeOnOwnChannel()
        }
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }
    
    func subscribeOnOwnChannel() {
        var ownChannel: PNChannel = PNChannel.channelWithName(AuthenticationHelper.sharedInstance.userInSession.pubnubId) as PNChannel
        PubNub.subscribeOnChannel(ownChannel)
    }
    
    public func pubnubClient(client: PubNub!, error: PNError!) {
        println("Error connecting \(client) with error \(error)")
    }
    
    public func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        println("Did receive message")
        println("Client = \(client) and message = \(message)")
        self.delegate?.pubnubClient(client, didReceiveMessage:message)
    }
}

protocol PubNubServiceDelegate {
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!)
}