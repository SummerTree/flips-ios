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

public struct HistoryMessage {
    var receivedDate : NSDate
    var message : JSON
}

public class PubNubService: FlipsService, PNDelegate {
    
    private let PUBNUB_ORIGIN = "pubsub.pubnub.com"
    private let PUBNUB_CIPHER_KEY = "FFC27DABA9708D16F9612E7AB37E81C26B76B2031946F6CF9458CD22419E6B22"
    
    private var cryptoHelper: PNCryptoHelper
    
    private var onPubnubConnectedBlock: (() -> Void)?
    
    weak var delegate: PubNubServiceDelegate?
    
    
    // MARK: - Initialization Methods
    
    override init() {
        let pubnubPublishKey = AppSettings.currentSettings().pubNubPublishKey()
        let pubnubSubscribeKey = AppSettings.currentSettings().pubNubSubscribeKey()
        let pubnubSecretKey = AppSettings.currentSettings().pubNubSecretKey()
    
        let cipherConfiguration = PNConfiguration(forOrigin: PUBNUB_ORIGIN,
            publishKey: pubnubPublishKey,
            subscribeKey: pubnubSubscribeKey,
            secretKey: pubnubSecretKey,
            cipherKey: PUBNUB_CIPHER_KEY)
        
        cryptoHelper = PNCryptoHelper()
        var helperInitializationError : PNError?
        cryptoHelper.updateWithConfiguration(cipherConfiguration, withError: &helperInitializationError)

        
        if (helperInitializationError != nil) {
            println("Error initializing CryptoHelper")
        }

        super.init()
        
        var pubnubConfiguration = PNConfiguration(forOrigin: PUBNUB_ORIGIN,
            publishKey: pubnubPublishKey,
            subscribeKey: pubnubSubscribeKey,
            secretKey: pubnubSecretKey)
        
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
                self.onPubnubConnectedBlock?()
            },
            errorBlock: { (error: PNError!) -> Void in
                println("Could not connect to PubNub: \(error.description)");
            })
        }
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }


    // MARK: - Channel Subscription

    func subscribeOnMyChannels() {
        if (!self.isConnected()) {
            self.onPubnubConnectedBlock = { () -> Void in
                self.subscribeOnMyChannels()
            }
            return
        }
        
        if let loggedUser = User.loggedUser() {
            var ownChannel: PNChannel = PNChannel.channelWithName(loggedUser.pubnubID) as PNChannel
            println("LoggedUser PubnubID: \(loggedUser.pubnubID)")
            
            var channels = [PNChannel]()
            channels.append(ownChannel)
            
            let roomDataSource = RoomDataSource()
            var rooms = roomDataSource.getAllRooms() // We need to subscribe even in rooms without messages
            for room in rooms {
                println("   Will subscribe to room: \(room.roomID)")
                channels.append(PNChannel.channelWithName(room.pubnubID) as PNChannel)
            }
            
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            
            PubNub.subscribeOn(channels, withCompletionHandlingBlock: { (state, channels, error) -> Void in
                if (error != nil) {
                    println("Error subscribing to channels: \(error)")
                }
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
                    println("\nSubcribe error: \(error)\n")
                }
            })
            
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            PubNub.enablePushNotificationsOnChannel(channel, withDevicePushToken: token) { (channels, pnError) -> Void in
                println("Result of enablePushNotificationsOnChannel: channels=[\(channels)], with error: \(pnError)")
            }
        }
    }

    
    // MARK: - Push Notifications
    
    func disablePushNotificationOnMyChannels() {
        if let token: NSData = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData() {
            PubNub.removeAllPushNotificationsForDevicePushToken(token, withCompletionHandlingBlock: { (error: PNError!) -> Void in
                println("Push notification removed with error: \(error.description)")
            })
        }
    }
    
    
    // MARK: - Encryption/decryption
    
    func encrypt(text: String?) -> String {
        if (text == nil || text == "") {
            return ""
        }
        var encryptionError: PNError?
        var encryptedInput = self.cryptoHelper.encryptedStringFromString(text!, error: &encryptionError)
        if (encryptionError != nil) {
            println("Error trying to encrypt text.")
            return ""
        }
        return encryptedInput
    }
    
    func decrypt(text: String?) -> String {
        if (text == nil || text == "") {
            return ""
        }
        var decryptionError: PNError?
        var decryptedInput = self.cryptoHelper.decryptedStringFromString(text!, error: &decryptionError)
        if (decryptionError != nil) {
            println("Error trying to decrypt text.")
            return ""
        }
        return decryptedInput
    }


    // MARK: - Message history

    private func loadMessagesHistoryForChannel(channel: PNChannel, completion:(() -> Void)?) {
        println("Requesting history for channel: \(channel.name)")

        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(channel.name)

        let isLoadingHistoryFromUserPrivateChannel: Bool = (User.loggedUser()?.pubnubID == channel.name)
        
        var lastMessageReceivedDate: NSDate?
        if (room != nil) {
            lastMessageReceivedDate = room!.lastMessageReceivedAt
        } else if (isLoadingHistoryFromUserPrivateChannel) {
            lastMessageReceivedDate = DeviceHelper.sharedInstance.lastTimeUserSynchronizedPrivateChannel()
        } else {
            // Is not getting history from user's private channel, so should be ignored
            println("Local Room was not found for channel. Skipping.")
            completion?()
            return
        }

        let completionBlock : PNClientHistoryLoadHandlingBlock = { (messages, channel, startDate, endDate, error) -> Void in
            let messages = messages as? Array<PNMessage>
            
            if (messages != nil && messages!.count > 0) {
                println("\(messages!.count) messages retrieved from channel \(channel.name)")
                
                if (isLoadingHistoryFromUserPrivateChannel) {
                    DeviceHelper.sharedInstance.setLastTimeUserSynchronizePrivateChannel(NSDate())
                }
                
                var decryptedMessages : Array<HistoryMessage> = []
                
                for pnMessage in messages! {
                    let messageJSON: JSON = JSON(pnMessage.message)
                    let decryptedContentString = self.decrypt(messageJSON[MESSAGE_DATA].stringValue)
                    let decryptedMessage = JSON(self.dictionaryFromJSON(decryptedContentString))
                    decryptedMessages.append(HistoryMessage(receivedDate: pnMessage.receiveDate.date, message: decryptedMessage))
                }
                
                self.delegate?.pubnubClient(PubNub.sharedInstance(),
                    didReceiveMessageHistory: decryptedMessages,
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

            NSLog("\nFETCHING HISTORY FOR %d CHANNELS", subscribedChannels.count)

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
        let decryptedContentString = self.decrypt(messageJSON[MESSAGE_DATA].stringValue)
        let contentJson : JSON = JSON(self.dictionaryFromJSON(decryptedContentString))
        self.delegate?.pubnubClient(client, didReceiveMessage:contentJson, atDate: pnMessage.receiveDate.date, fromChannelName: pnMessage.channel.name)
    }
    
    public func pubnubClient(client: PubNub!, didConnectToOrigin origin: String!) {
        NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_CONNECT_NOTIFICATION, object: nil)
    }
    
    private func dictionaryFromJSON(jsonString: String) -> [String: AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [String: AnyObject] {
                return dictionary
            }
        }
        return [String: AnyObject]()
    }

    
    // MARK: - Send Messages Methods
    
    func sendMessage(message: Dictionary<String, AnyObject>, pubnubID: String, completion: CompletionBlock?) {
        let channel = PNChannel.channelWithName(pubnubID) as PNChannel

        var encryptedMessage = message
        encryptedMessage.updateValue(self.encrypt(JSON(message[MESSAGE_DATA]!).rawString()), forKey: MESSAGE_DATA)
        
        PubNub.sendMessage(encryptedMessage, toChannel: channel, storeInHistory: true) { (state, data) -> Void in
            println("message sent: \(data)")
            switch (state) {
            case PNMessageState.Sending:
                // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
                println("Sending")
            case PNMessageState.SendingError:
                // PubNub client failed to send message and reason is in 'data' object.
                println("SendingError")
                completion?(false)
            case PNMessageState.Sent:
                // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
                println("Sent")
                completion?(true)
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

protocol PubNubServiceDelegate: class {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date:NSDate, fromChannelName: String)
    func pubnubClient(client: PubNub!, didReceiveMessageHistory messages: Array<HistoryMessage>, fromChannelName: String)

}