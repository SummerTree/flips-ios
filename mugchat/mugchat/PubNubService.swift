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
    private let PUBNUB_PUBLISH_KEY = "pub-c-44dbaf09-91c6-4e9d-98d2-99841736d52a"
    private let PUBNUB_SUBSCRIBE_KEY = "sub-c-fbc63a34-59fd-11e4-a91d-02ee2ddab7fe"
    private let PUBNUB_SECRET_KEY = "sec-c-NGUzZWFmNDgtYmNmNi00ZjRiLTgyMTYtOTMxYWIzYmExNmEx"
    
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
            self.subscribeOnMyChannels()
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
        for room in rooms {
            channels.append(PNChannel.channelWithName(room.pubnubID) as PNChannel)
        }
        
        let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
        
        PubNub.subscribeOnChannels(channels)
        PubNub.enablePushNotificationsOnChannels(channels, withDevicePushToken: token) { (channels, pnError) -> Void in
            println("Result of subscribing: channels=[\(channels), with error: \(pnError)")
        }
    }
    
    func subscribeToChannel(pubnubID: String) {
        var channel: PNChannel = PNChannel.channelWithName(pubnubID) as PNChannel
        if (!PubNub.isSubscribedOnChannel(channel)) {
            PubNub.subscribeOnChannel(channel)
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            PubNub.enablePushNotificationsOnChannel(channel, withDevicePushToken: token) { (channels, pnError) -> Void in
                println("Result of subscribing: channels=[\(channels), with error: \(pnError)")
            }
        }
    }
    
    public func pubnubClient(client: PubNub!, error: PNError!) {
        println("Error connecting \(client) with error \(error)")
    }
    
    public func pubnubClient(client: PubNub!, didReceiveMessage pnMessage: PNMessage!) {
        println("Did receive message. Forwading it to delegate.")
        println("pnMessage.channel.name: \(pnMessage.channel.name)")

        let messageJSON: JSON = JSON(pnMessage.message)
        self.delegate?.pubnubClient(client, didReceiveMessage:messageJSON, fromChannelName: pnMessage.channel.name)
    }
    
    public func pubnubClient(client: PubNub!, didReceivePushNotificationEnabledChannels channels: [AnyObject]!) {
        println("didReceivePushNotificationEnabledChannels")
    }
}

protocol PubNubServiceDelegate {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, fromChannelName: String)
    
}