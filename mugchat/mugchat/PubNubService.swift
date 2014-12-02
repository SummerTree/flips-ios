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

public class PubNubService: FlipsService, PNDelegate {
    
    private let PUBNUB_ORIGIN = "pubsub.pubnub.com"
    private let PUBNUB_PUBLISH_KEY = "pub-c-579fbcaa-1c0a-44fc-bb1c-e02e43e7eb30"
    private let PUBNUB_SUBSCRIBE_KEY = "sub-c-3bcb7c42-59ff-11e4-9632-02ee2ddab7fe"
    private let PUBNUB_SECRET_KEY = "sec-c-MTA5MjJmZWUtOGI4Ni00NTUwLTgzN2ItNWU0ZGIyZmI0MWY4"
    
    private let PRODUCTION_PUBLISH_KEY = "pub-c-18de6448-8924-43b5-9f5b-a333e7d7e6d9"
    private let PRODUCTION_SUBSCRIBE_KEY = "sub-c-bec9fd6e-719f-11e4-94ac-02ee2ddab7fe"
    private let PRODUCTION_SECRET_KEY = "sec-c-MzFhZjgyOWQtNDRiOS00NTBiLTkwZjAtOGUyM2U5MDNhMTdh"
    
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
        if (!self.isConnected()) {
            PubNub.connectWithSuccessBlock({ (origin: String!) -> Void in
                self.subscribeOnMyChannels()
            },
            errorBlock: { (error: PNError!) -> Void in
                println("Could not connect to PubNub");
            })
        }
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }
    
    private func subscribeOnMyChannels() {
        var ownChannel: PNChannel = PNChannel.channelWithName(AuthenticationHelper.sharedInstance.userInSession.pubnubID) as PNChannel
        
        var channels = [AnyObject]()
        channels.append(ownChannel)
        
        let roomDataSource = RoomDataSource()
        var rooms = roomDataSource.getAllRooms() // We need to subscribe even in rooms without messages
        println("\nSubscribeOnMyChannels")
        for room in rooms {
            println("   Will subscribe to room: \(room.roomID)")
            channels.append(PNChannel.channelWithName(room.pubnubID) as PNChannel)
        }
        println("\n")

        let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
        
        PubNub.subscribeOn(channels, withCompletionHandlingBlock: { (state, channels, error) -> Void in
            self.loadMessagesHistory()
        })
        PubNub.enablePushNotificationsOnChannels(channels, withDevicePushToken: token) { (channels, pnError) -> Void in
            println("Result of enablePushNotificationOnChannels: channels=[\(channels), with error: \(pnError)")
        }
    }
    
    func subscribeToChannelID(pubnubID: String) {
        var channel: PNChannel = PNChannel.channelWithName(pubnubID) as PNChannel
        self.subscribeToChannel(channel)
    }

    private func subscribeToChannel(channel: PNChannel) {
        if (!PubNub.isSubscribedOn(channel)) {
            PubNub.subscribeOn([channel], withCompletionHandlingBlock: { (state, channels, error) -> Void in
                if (error != nil) {
                    println("\nsubcribe error: \(error)\n")
                } else {
                    self.loadMessagesHistoryForChannel(channel)
                }
            })
            
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            PubNub.enablePushNotificationsOnChannel(channel, withDevicePushToken: token) { (channels, pnError) -> Void in
                println("Result of enablePushNotificationsOnChannel: channels=[\(channels), with error: \(pnError)")
            }
        }
    }

    func loadMessagesHistoryForChannelID(pubnubID: String) {
        var channel: PNChannel = PNChannel.channelWithName(pubnubID) as PNChannel
        self.loadMessagesHistoryForChannel(channel)
    }
    
    func loadMessagesHistoryForChannel(channel: PNChannel) {
        println("Requesting history for channel: \(channel.name)")

        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(channel.name)

        var lastMessageReceivedDate: NSDate?
        if (room == nil) {
            println("Local Room was found for channel. Skipping.")
            // TODO: If subscribed to a channel without a local Room create it locally if no User's private PubNubID?
            return
        }

        lastMessageReceivedDate = room!.lastMessageReceivedAt

        let completionBlock : PNClientHistoryLoadHandlingBlock = { (messages, channel, startDate, endDate, error) -> Void in
            let messages = messages as? Array<PNMessage>

            if (messages != nil && messages!.count > 0) {
                println("\(messages!.count) messages retrieved from channel \(channel.name)")
                for pnMessage in messages! {
                    self.delegate?.pubnubClient(PubNub.sharedInstance(),
                        didReceiveMessage:JSON(pnMessage.message),
                        atDate: pnMessage.receiveDate.date,
                        fromChannelName: pnMessage.channel.name)
                }
            } else if (error != nil) {
                println("Could not retrieve message history for channel \(channel.name). \(error.localizedDescription)")
            }
        }

        if (lastMessageReceivedDate == nil) {
            println("No message received for channel. Retrieving full history.")
            PubNub.requestFullHistoryForChannel(channel,
                includingTimeToken: true,
                withCompletionBlock: completionBlock)

        } else {
            println("Retrieving incremental history from: \(lastMessageReceivedDate)")
            PubNub.requestHistoryForChannel(channel,
                from: PNDate(date: NSDate()), // From: now
                to: PNDate(date: lastMessageReceivedDate?.dateByAddingTimeInterval(1)), // To: imediatelly after last received message timestamp
                includingTimeToken: true,
                withCompletionBlock: completionBlock)
        }
    }

    func loadMessagesHistory() {
        let subscribedChannels = PubNub.sharedInstance().subscribedObjectsList() as Array<PNChannelProtocol>

        for channelProtocol in subscribedChannels {
            var channel: PNChannel = PNChannel.channelWithName(channelProtocol.name) as PNChannel
            self.loadMessagesHistoryForChannel(channel)
        }
    }

    // MARK: - PNDelegate

    public func pubnubClient(client: PubNub!, error: PNError!) {
        println("Error connecting \(client) with error \(error)")
    }
	
	
    // MARK: - PNDelegate
    
    public func pubnubClient(client: PubNub!, didReceiveMessage pnMessage: PNMessage!) {
        println("Did receive message. Forwading it to delegate.")
        println("pnMessage.channel.name: \(pnMessage.channel.name)")

        let messageJSON: JSON = JSON(pnMessage.message)
        self.delegate?.pubnubClient(client, didReceiveMessage:messageJSON, atDate: pnMessage.receiveDate.date, fromChannelName: pnMessage.channel.name)
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
	
	
	// MARK: - Notifications Handler
	
    public func pubnubClient(client: PubNub!, didReceivePushNotificationEnabledChannels channels: [AnyObject]!) {
        println("didReceivePushNotificationEnabledChannels")
	}
}

protocol PubNubServiceDelegate {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date:NSDate, fromChannelName: String)
    
}