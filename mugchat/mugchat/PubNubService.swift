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
        
        var channels = Array<PNChannel>()
        channels.append(ownChannel)
        
        let roomDataSource = RoomDataSource()
        var rooms = roomDataSource.getAllRooms() // We need to subscribe even in rooms without messages
        for room in rooms {
            channels.append(PNChannel.channelWithName(room.pubnubID) as PNChannel)
        }
        
        PubNub.subscribeOnChannels(channels, withCompletionHandlingBlock: { (state, channels, error) -> Void in
            self.loadMessagesHistory()
        })
    }
    
    func subscribeToChannelID(pubnubID: String) {
        var channel: PNChannel = PNChannel.channelWithName(pubnubID) as PNChannel
        self.subscribeToChannel(channel)
    }

    func subscribeToChannel(channel: PNChannel) {
        if (!PubNub.isSubscribedOnChannel(channel)) {
            PubNub.subscribeOnChannel(channel)
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
        let subscribedChannels = PubNub.subscribedChannels() as Array<PNChannel>

        for channel in subscribedChannels {
            self.loadMessagesHistoryForChannel(channel)
        }
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
}

protocol PubNubServiceDelegate {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date:NSDate, fromChannelName: String)
    
}