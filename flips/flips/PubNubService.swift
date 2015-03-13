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

public let PUBNUB_DID_CONNECT_NOTIFICATION: String = "pubnub_did_connect_notification"
public let PUBNUB_DID_FETCH_MESSAGE_HISTORY: String = "pubnub_did_fetch_message_history"

public class PubNubService: FlipsService, PNDelegate {
    
    private let PUBNUB_ORIGIN = "pubsub.pubnub.com"
    private let PUBNUB_PUBLISH_KEY = "pub-c-579fbcaa-1c0a-44fc-bb1c-e02e43e7eb30"
    private let PUBNUB_SUBSCRIBE_KEY = "sub-c-3bcb7c42-59ff-11e4-9632-02ee2ddab7fe"
    private let PUBNUB_SECRET_KEY = "sec-c-MTA5MjJmZWUtOGI4Ni00NTUwLTgzN2ItNWU0ZGIyZmI0MWY4"
    private let PUBNUB_CIPHER_KEY = "FFC27DABA9708D16F9612E7AB37E81C26B76B2031946F6CF9458CD22419E6B22"
    
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
            secretKey: PUBNUB_SECRET_KEY,
            cipherKey: PUBNUB_CIPHER_KEY)
        
        pubnubConfiguration.useSecureConnection = true
        pubnubConfiguration.reduceSecurityLevelOnError = false
        pubnubConfiguration.ignoreSecureConnectionRequirement = false
        
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
                println("Successfully connected to PubNub");
            },
            errorBlock: { (error: PNError!) -> Void in
                println("Could not connect to PubNub");
            })
        }
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }


    // MARK: - Channel Subscription

    func subscribeOnMyChannels() {
        if let loggedUser = User.loggedUser() {
            var ownChannel: PNChannel = PNChannel.channelWithName(loggedUser.pubnubID) as PNChannel
            
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
                }
            })
            
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            PubNub.enablePushNotificationsOnChannel(channel, withDevicePushToken: token) { (channels, pnError) -> Void in
                println("Result of enablePushNotificationsOnChannel: channels=[\(channels), with error: \(pnError)")
            }
        }
    }


    // MARK: - Message history

    private func loadMessagesHistoryForChannel(channel: PNChannel, completion:(() -> Void)?) {
        println("Requesting history for channel: \(channel.name)")

        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(channel.name)

        var lastMessageReceivedDate: NSDate?
        if (room == nil) {
            println("Local Room was not found for channel. Skipping.")
            completion?()
            return
        }

        lastMessageReceivedDate = room!.lastMessageReceivedAt

        let completionBlock : PNClientHistoryLoadHandlingBlock = { (messages, channel, startDate, endDate, error) -> Void in
            let messages = messages as? Array<PNMessage>

            if (messages != nil && messages!.count > 0) {
                println("\(messages!.count) messages retrieved from channel \(channel.name)")
                self.delegate?.pubnubClient(PubNub.sharedInstance(),
                    didReceiveMessageHistory: messages!,
                    fromChannelName: channel.name)
            } else if (error != nil) {
                println("Could not retrieve message history for channel \(channel.name). \(error.localizedDescription)")
            }

            completion?()
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            let subscribedChannels = PubNub.sharedInstance().subscribedObjectsList() as Array<PNChannelProtocol>

            let group = dispatch_group_create()

            NSLog("FETCHING HISTORY FOR %d CHANNELS", subscribedChannels.count)

            for channelProtocol in subscribedChannels {
                dispatch_group_enter(group)

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    var channel: PNChannel = PNChannel.channelWithName(channelProtocol.name) as PNChannel
                    self.loadMessagesHistoryForChannel(channel, completion: { () -> Void in
                        dispatch_group_leave(group)
                    })
                })
            }

            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)

            NSLog("HISTORY FETCH ENDED")

            NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
        })
    }

    // MARK: - PNDelegate

    public func pubnubClient(client: PubNub!, error: PNError!) {
        println("Error connecting \(client) with error \(error)")
    }
    
    public func pubnubClient(client: PubNub!, didReceiveMessage pnMessage: PNMessage!) {
        println("Did receive message. Forwading it to delegate.")
        println("pnMessage.channel.name: \(pnMessage.channel.name)")

        let messageJSON: JSON = JSON(pnMessage.message)
        self.delegate?.pubnubClient(client, didReceiveMessage:messageJSON, atDate: pnMessage.receiveDate.date, fromChannelName: pnMessage.channel.name)
    }
    
    public func pubnubClient(client: PubNub!, didConnectToOrigin origin: String!) {
        NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_CONNECT_NOTIFICATION, object: nil)
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
    }
	
	
	// MARK: - Notifications Handler
	
    public func pubnubClient(client: PubNub!, didReceivePushNotificationEnabledChannels channels: [AnyObject]!) {
        println("didReceivePushNotificationEnabledChannels")
	}
}

protocol PubNubServiceDelegate {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date:NSDate, fromChannelName: String)
    func pubnubClient(client: PubNub!, didReceiveMessageHistory messages: Array<PNMessage>, fromChannelName: String)

}