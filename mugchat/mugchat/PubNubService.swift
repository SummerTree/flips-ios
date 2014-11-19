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
    
    // MARK: - Initialization Methods
    
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
    
    
    // MARK - Connection Methods
    
    func connect() {
        if (!PubNub.sharedInstance().isConnected()) {
            PubNub.connect()
            self.subscribeOnMyChannels()
        }
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }
    
    private func subscribeOnMyChannels() {
        var ownChannel: PNChannel = PNChannel.channelWithName(AuthenticationHelper.sharedInstance.userInSession.pubnubID) as PNChannel
        
        var channels = Array<PNChannel>()
        channels.append(ownChannel)
        
        let roomDataSource = RoomDataSource()
        var rooms = roomDataSource.getAllRooms() // We need to subscribe even in rooms without messages
        for room in rooms {
            channels.append(PNChannel.channelWithName(room.pubnubID) as PNChannel)
        }
        
        PubNub.subscribeOnChannels(channels)
    }
    
    func subscribeToChannel(pubnubID: String) {
        var channel: PNChannel = PNChannel.channelWithName(pubnubID) as PNChannel
        if (!PubNub.isSubscribedOnChannel(channel)) {
            PubNub.subscribeOnChannel(channel)
        }
    }
    
    public func pubnubClient(client: PubNub!, error: PNError!) {
        println("Error connecting \(client) with error \(error)")
    }
    
    
    // MARK: - PNDelegate
    
    public func pubnubClient(client: PubNub!, didReceiveMessage pnMessage: PNMessage!) {
        println("Did receive message. Forwading it to delegate.")
        println("pnMessage.channel.name: \(pnMessage.channel.name)")

        let messageJSON: JSON = JSON(pnMessage.message)
        self.delegate?.pubnubClient(client, didReceiveMessage:messageJSON, fromChannelName: pnMessage.channel.name)
    }
    
    
    // MARK: - Send Messages Methods
    
    func sendMessage(message: Dictionary<String, AnyObject>, pubnubID: String, completion: CompletionBlock) {
        let channel = PNChannel.channelWithName(pubnubID) as PNChannel

        PubNub.sendMessage(message, toChannel: channel, storeInHistory: true) { (state, data) -> Void in
            println("message sent: \(data)")
            switch (state) {
            case PNMessageState.Sending:
                // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
                println("Sending")
            case PNMessageState.SendingError:
                // PubNub client failed to send message and reason is in 'data' object.
                println("SendingError")
                completion(false)
            case PNMessageState.Sent:
                // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
                println("Sent")
                completion(true)
            default:
                println("default")
            }
        }
    
        // TODO: For push notification we need to use this method
        // + (PNMessage *)sendMessage:(id)message applePushNotification:(NSDictionary *)apnsPayload googleCloudNotification:(NSDictionary *)gcmPayload
        // toChannel:(PNChannel *)channel storeInHistory:(BOOL)shouldStoreInHistory withCompletionBlock:(PNClientMessageProcessingBlock)success;
    }
}

protocol PubNubServiceDelegate {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, fromChannelName: String)
    
}