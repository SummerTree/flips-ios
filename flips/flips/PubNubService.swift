//
// Copyright 2015 ArcTouch, Inc.
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
    private let PUBNUB_NON_SUBSCRIPTION_REQUEST_TIMEOUT = 60000
    
    private let LOAD_HISTORY_NUMBER_OF_RETRIES: Int = 5
    
    private var cryptoHelper: PNCryptoHelper
    
    private var onPubnubConnectedBlock: (() -> Void)?
    
    weak var delegate: PubNubServiceDelegate?
    
    private var pubnubConnectionIdentifier: String? // It changes when you disconnect and reconnect

    private var isLoadingHistory: Bool = false
    private var didLoadHistorySuccessfully: Bool = false
    
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
            print("Error initializing CryptoHelper")
        }

        super.init()
        
        let pubnubConfiguration = PNConfiguration(forOrigin: PUBNUB_ORIGIN,
            publishKey: pubnubPublishKey,
            subscribeKey: pubnubSubscribeKey,
            secretKey: pubnubSecretKey)
        
        pubnubConfiguration.useSecureConnection = true
        pubnubConfiguration.reduceSecurityLevelOnError = false
        pubnubConfiguration.ignoreSecureConnectionRequirement = false
        pubnubConfiguration.nonSubscriptionRequestTimeout = NSTimeInterval(PUBNUB_NON_SUBSCRIPTION_REQUEST_TIMEOUT)
        
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
            if (self.pubnubConnectionIdentifier == nil) {
                self.pubnubConnectionIdentifier = NSUUID().UUIDString
            }
            
            PubNub.connectWithSuccessBlock({ (origin: String!) -> Void in
                print("Successfully connected to PubNub")
            }, errorBlock: { (error: PNError!) -> Void in
                print("Could not connect to PubNub: \(error?.description)")
            })
        }
    }
    
    func disconnect() {
        self.disablePushNotificationOnMyChannels()
        PubNub.unsubscribeFrom(PubNub.subscribedObjectsList(), withCompletionHandlingBlock: { (channels: [AnyObject]!, error: PNError!) -> Void in
            print("PubNub unsubscribed from \(channels.count) channels with error: \(error)")
        })
        PubNub.disconnect()
        self.pubnubConnectionIdentifier = nil
    }
    
    func isConnected() -> Bool {
        return PubNub.sharedInstance().isConnected()
    }


    // MARK: - Channel Subscription

    func subscribeOnMyChannels(completion: CompletionBlock? = nil, progress: ((received: Int, total: Int) -> Void)? = nil) {
        if (User.loggedUser() == nil) {
            print("Subscribe my channels. User not logged.")
            return
        }
        
        let currentIdentifier = self.pubnubConnectionIdentifier
        print("Subscribing to user's channels")
        if (!self.isConnected()) {
            print("Pubnub not connect. Saving block to run later.")
            self.onPubnubConnectedBlock = { () -> Void in
                print("onPubnubConnectedBlock called")
                self.onPubnubConnectedBlock = nil
                self.subscribeOnMyChannels(completion, progress: progress)
            }
            return
        }
        
        if let myChannels: [PNChannel] = self.channelsForMyRooms() {
            progress?(received: 0, total: myChannels.count)
            
            var channelsToSubscribe: [PNChannel] = Array<PNChannel>()
            for channel in myChannels {
                if (!PubNub.isSubscribedOn(channel)) {
                    channelsToSubscribe.append(channel)
                } else {
                    print("   Already subscribed to channel \(channel.name).")
                }
            }
            
            if (channelsToSubscribe.count == 0) {
                self.loadMessagesHistoryWithCompletion(completion, progress: progress)
            } else {
                print("Subscribing to \(channelsToSubscribe.count) channels")
                PubNub.subscribeOn(channelsToSubscribe, withCompletionHandlingBlock: { (state, channels, error) -> Void in
                    print("Subscribing to channels completed")
                    if (currentIdentifier == self.pubnubConnectionIdentifier) {
                        if (error != nil) {
                            print("   Error subscribing to channels: \(error)")
                        }
                        self.loadMessagesHistoryWithCompletion(completion, progress: progress)
                    } else {
                        print("SubscribeOnMyChannels PubNub identifier changed.")
                    }
                })
            }
            
            self.enablePushNotificationOnMyChannels()
        }
    }
    
    func enablePushNotificationOnMyChannels() {
        if let token: NSData = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData() {
            PubNub.removeAllPushNotificationsForDevicePushToken(token, withCompletionHandlingBlock: { (error: PNError?) -> Void in
                if (error != nil) {
                    print("Push notification removed with error: \(error?.description)")
                }
                if let myChannels: [PNChannel] = self.channelsForMyRooms() {
                    PubNub.enablePushNotificationsOnChannels(myChannels, withDevicePushToken: token) { (channels, pnError) -> Void in
                        print("Result of enablePushNotificationOnChannels: channels=[\(channels)], with error: \(pnError)")
                    }
                }
            })
        }
    }
    
    private func channelsForMyRooms() -> [PNChannel]? {
        var channels: [PNChannel]?
        if let loggedUser = User.loggedUser() {
            channels = [PNChannel]()
            let ownChannel: PNChannel = PNChannel.channelWithName(loggedUser.pubnubID) as! PNChannel
            
            channels?.append(ownChannel)
            
            let roomDataSource = RoomDataSource()
            let rooms = roomDataSource.getAllRooms() // We need to subscribe even in rooms without messages
            for room in rooms {
                channels?.append(PNChannel.channelWithName(room.pubnubID) as! PNChannel)
            }
        }
        return channels
    }
    
    func subscribeToChannelID(pubnubID: String) {
        let channel: PNChannel = PNChannel.channelWithName(pubnubID) as! PNChannel
        self.subscribeToChannel(channel)
    }

    private func subscribeToChannel(channel: PNChannel) {
        if (!PubNub.isSubscribedOn(channel)) {
            PubNub.subscribeOn([channel], withCompletionHandlingBlock: { (state, channels, error) -> Void in
                if (error != nil) {
                    print("\nSubcribe error: \(error)\n")
                }
            })
            
            let token = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData()
            PubNub.enablePushNotificationsOnChannel(channel, withDevicePushToken: token) { (channels, pnError) -> Void in
                print("Result of enablePushNotificationsOnChannel: channels=[\(channels)], with error: \(pnError)")
            }
        }
    }

    
    // MARK: - Push Notifications
    
    func disablePushNotificationOnMyChannels() {
        if let token: NSData = DeviceHelper.sharedInstance.retrieveDeviceTokenAsNSData() {
            PubNub.removeAllPushNotificationsForDevicePushToken(token, withCompletionHandlingBlock: { (error: PNError?) -> Void in
                print("Push notification removed with error: \(error?.description)")
            })
        }
    }
    
    
    // MARK: - Encryption/decryption
    
    func encrypt(text: String?) -> String {
        if (text == nil || text == "") {
            return ""
        }
        var encryptionError: PNError?
        let encryptedInput = self.cryptoHelper.encryptedStringFromString(text!, error: &encryptionError)
        if (encryptionError != nil) {
            print("Error trying to encrypt text.")
            return ""
        }
        return encryptedInput
    }
    
    func decrypt(text: String?) -> String {
        if (text == nil || text == "") {
            return ""
        }
        var decryptionError: PNError?
        let decryptedInput = self.cryptoHelper.decryptedStringFromString(text!, error: &decryptionError)
        if (decryptionError != nil) {
            print("Error trying to decrypt text.")
            return ""
        }
        return decryptedInput
    }


    // MARK: - Message history
    
    func reloadHistory() {
        if (!self.isLoadingHistory) {
            loadMessagesHistoryWithCompletion(nil, progress: nil)
        }
    }
    
    func loadMessagesHistoryWithCompletion(completion: CompletionBlock? = nil, progress: ((received: Int, total: Int) -> Void)? = nil) {
        if (User.loggedUser() == nil) {
            print("Trying to get history for my channels but logged user is nil.")
            return
        }
        
        let currentIdentifier: String? = self.pubnubConnectionIdentifier
        
        print("Will start to load history")
        
        // Expire block - if the load didn't finish in 1:30 minutes, we will call the completion block or post the did fetch notification to do not let the user blocked.
        let time = 90 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) { () -> Void in
            if (self.isLoadingHistory) {
                if (currentIdentifier != self.pubnubConnectionIdentifier) {
                    print("\nHistory fetch expired PubNub identifier changed.")
                    return
                } else if (User.loggedUser() == nil) {
                    print("\nHistory fetch expired with user not logged.")
                    return
                } else if (completion != nil) {
                    print("\nCalling load history completion expired")
                    completion?(false)
                } else {
                    print("\nPosting load history expired notification")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
                    })
                }
                self.isLoadingHistory = false
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            if (currentIdentifier != self.pubnubConnectionIdentifier) {
                print("Load Messages History - SubscribeOnMyChannels PubNub identifier changed.")
                return
            }
            
            let list = PubNub.sharedInstance().subscribedObjectsList()
            if (list == nil) {
                print("Error: loadMessagesHistory - subscribed object list is nil.")
                completion?(false)
                return
            }
            
            let subscribedChannels = list as! Array<PNChannelProtocol>
            
            self.isLoadingHistory = true
            
            let group = dispatch_group_create()
            NSLog("FETCHING HISTORY FOR %d CHANNELS", subscribedChannels.count)
            
            // The idea here is to put the dispatch_group inside of the for statement, so we will only load one history per time and we will be able to interrupt it when the user logout.
            
            var historiesReceived: Int = 0
            for channelProtocol in subscribedChannels {
                if let channel: PNChannel = PNChannel.channelWithName(channelProtocol.name) as? PNChannel {
                    if let _: User = User.loggedUser() {
                        dispatch_group_enter(group)
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                            self.loadMessagesHistoryForChannel(channel, loadMessagesHistoryCompletion: { (success: Bool) -> Void in
                                if (currentIdentifier != self.pubnubConnectionIdentifier) {
                                    print("loadMessagesHistoryForChannel progress - PubNub identifier changed.")
                                } else if (User.loggedUser() != nil) {
                                    if (success) {
                                        historiesReceived += 1
                                        progress?(received: historiesReceived, total: subscribedChannels.count)
                                    }
                                }
                                print("   loadMessagesHistoryForChannel: success(\(success)) historiesReceived(\(historiesReceived))")
                                dispatch_group_leave(group)
                            })
                        })
                        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
                    } else {
                        print("   User not logged. Load history interrupted.")
                        break
                    }
                }
            }
            
            NSLog("HISTORY FETCH ENDED - subscribedChannels.count(\(subscribedChannels.count)) - historiesReceived(\(historiesReceived))")
            
            // Checking if the expire block wasn't called
            if (self.isLoadingHistory) {
                if (currentIdentifier != self.pubnubConnectionIdentifier) {
                    print("   SubscribeOnMyChannels finished PubNub identifier changed.")
                    return
                } else if (User.loggedUser() == nil) {
                    print("   History fetch ended with user not logged.")
                    return
                } else if (completion != nil) {
                    print("   Calling load history completion")
                    completion?(subscribedChannels.count == historiesReceived)
                } else {
                    print("   Posting load history finished notification")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
                    })
                }
                self.isLoadingHistory = false
                self.didLoadHistorySuccessfully = (subscribedChannels.count == historiesReceived)
            } else {
                self.didLoadHistorySuccessfully = (subscribedChannels.count == historiesReceived)
            }
        })
    }

    private func loadMessagesHistoryForChannel(channel: PNChannel, loadMessagesHistoryCompletion: (CompletionBlock)?) {
        let isLoadingHistoryFromUserPrivateChannel: Bool = (User.loggedUser()?.pubnubID == channel.name)
        
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(channel.name)
        
        var lastMessageReceivedDate: NSDate?
        if (room != nil) {
            lastMessageReceivedDate = room!.lastMessageFromHistoryReceivedAt
        } else if (isLoadingHistoryFromUserPrivateChannel) {
            lastMessageReceivedDate = DeviceHelper.sharedInstance.lastTimeUserSynchronizedPrivateChannel()
        } else {
            // Is not getting history from user's private channel, so should be ignored
            print("Local Room was not found for channel. Skipping.")
            loadMessagesHistoryCompletion?(false)
            return
        }
        
        let currentIdentifier: String? = self.pubnubConnectionIdentifier
        self.loadMessagesHistoryForChannelRetrying(self.LOAD_HISTORY_NUMBER_OF_RETRIES,
            channel: channel,
            lastMessageReceivedDate: lastMessageReceivedDate,
            success: { (messages: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: PNError!) -> Void in
                if (User.loggedUser() == nil) {
                    print("Load history for channel success. User not logged.")
                    return
                }
                
                if (currentIdentifier != self.pubnubConnectionIdentifier) {
                    print("Load history for channel success. Identifiers are different.")
                    return
                }
                
                if (error != nil) {
                    print("   Could not retrieve message history for channel \(channel.name). \(error.localizedDescription)")
                } else {
                    self.processChannelHistoryReceived(messages, channel: channel, isLoadingHistoryFromUserPrivateChannel: isLoadingHistoryFromUserPrivateChannel)
                }
                loadMessagesHistoryCompletion?(error == nil)
            }, failure: { (error: NSError!) -> Void in
                if (User.loggedUser() == nil) {
                    print("   Load history for channel failure. User not logged.")
                    return
                }
                
                if (currentIdentifier != self.pubnubConnectionIdentifier) {
                    print("   Load history for channel failure. Identifiers are different.")
                    return
                }
                
                print("   Load Messages History failed with error: \(error)")
                loadMessagesHistoryCompletion?(false)
            }, latestError: nil)
    }
    
    private func loadMessagesHistoryForChannelRetrying(numberOfRetries: Int, channel: PNChannel, lastMessageReceivedDate: NSDate?, success: PNClientHistoryLoadHandlingBlock, failure: FailureBlock, latestError: NSError?) {
        let currentIdentifier: String? = self.pubnubConnectionIdentifier
        if ((numberOfRetries <= 0) || (!self.isConnected())) {
            failure(latestError)
        } else {
            if (lastMessageReceivedDate == nil) {
                print("Requesting full history for channel: \(channel.name)")
                PubNub.requestFullHistoryForChannel(channel,
                    includingTimeToken: true,
                    withCompletionBlock: { (messages: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: PNError!) -> Void in
                        if (currentIdentifier == self.pubnubConnectionIdentifier) {
                            if (error != nil) {
                                print("   Loading Full History retrying - numberOfRetries(\(numberOfRetries))")
                                self.loadMessagesHistoryForChannelRetrying(numberOfRetries - 1,
                                    channel: channel,
                                    lastMessageReceivedDate: lastMessageReceivedDate,
                                    success: success,
                                    failure: failure,
                                    latestError: error)
                            } else {
                                success(messages, channel, startDate, endDate, error)
                            }
                        }
                })
            } else {
                print("Requesting history for channel: \(channel.name)")
                PubNub.requestHistoryForChannel(channel,
                    from: PNDate(date: NSDate()), // From: now
                    to: PNDate(date: lastMessageReceivedDate?.dateByAddingTimeInterval(1)), // To: imediatelly after last received message timestamp
                    includingTimeToken: true,
                    withCompletionBlock: { (messages: [AnyObject]!, channel: PNChannel!, startDate: PNDate!, endDate: PNDate!, error: PNError!) -> Void in
                        if (currentIdentifier == self.pubnubConnectionIdentifier) {
                            if (error != nil) {
                                print("   Loading History retrying - numberOfRetries(\(numberOfRetries))")
                                self.loadMessagesHistoryForChannelRetrying(numberOfRetries - 1,
                                    channel: channel,
                                    lastMessageReceivedDate: lastMessageReceivedDate,
                                    success: success,
                                    failure: failure,
                                    latestError: error)
                            } else {
                                success(messages, channel, startDate, endDate, error)
                            }
                        }
                })
            }
        }
    }
    
    private func processChannelHistoryReceived(channelMessages: [AnyObject]!, channel: PNChannel, isLoadingHistoryFromUserPrivateChannel: Bool) {
        let messages = channelMessages as? Array<PNMessage>
        
        if (messages != nil && messages!.count > 0) {
            print("   \(messages!.count) messages retrieved from channel \(channel.name)")
            
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
            
            self.delegate?.pubnubClient(PubNub.sharedInstance(), didReceiveMessageHistory: decryptedMessages, fromChannelName: channel.name)
        }
    }


    // MARK: - PNDelegate

    public func pubnubClient(client: PubNub!, error: PNError!) {
        print("Error connecting \(client) with error \(error)")
    }
    
    public func pubnubClient(client: PubNub!, didReceiveMessage pnMessage: PNMessage!) {
        print("Did receive message. Forwading it to delegate.")
        
        let messageJSON: JSON = JSON(pnMessage.message)
        let decryptedContentString = self.decrypt(messageJSON[MESSAGE_DATA].stringValue)
        let contentJson : JSON = JSON(self.dictionaryFromJSON(decryptedContentString))
        self.delegate?.pubnubClient(client, didReceiveMessage:contentJson, atDate: pnMessage.receiveDate.date, fromChannelName: pnMessage.channel.name)
        
        AnalyticsService.logMessageReceived()
    }
    
    public func pubnubClient(client: PubNub!, didConnectToOrigin origin: String!) {
        print("pubnubClient didConnectToOrigin")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_CONNECT_NOTIFICATION, object: nil)
        
        if (self.isLoadingHistory) {
            // For some reason sometimes PubNub is not resuming the requests. So, do not let user blocked waiting for the sync, we need to dismiss the sync view.
            NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
        } else if (!self.didLoadHistorySuccessfully) {
            self.loadMessagesHistoryWithCompletion(nil, progress: nil)
        }
        
        self.onPubnubConnectedBlock?()
    }
    
    public func pubnubClient(client: PubNub!, didDisconnectFromOrigin origin: String!, withError error: PNError!) {
        print("pubnubClient didDisconnectFromOrigin withError \(error)")
        if let _: User = User.loggedUser() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
        
        if (self.isLoadingHistory) {
            // For some reason sometimes PubNub is not resuming the requests. So, do not let user blocked waiting for the sync, we need to dismiss the sync view.
            NSNotificationCenter.defaultCenter().postNotificationName(PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
        }
    }
    
    public func pubnubClient(client: PubNub!, connectionDidFailWithError error: PNError!) {
        print("pubnubClient connectionDidFailWithError \(error)")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if NetworkReachabilityHelper.sharedInstance.hasInternetConnection(), let loggedUser : User = User.loggedUser() {
            Flurry.logError("PubNub Connection Failure", message: "Connection attempt failed for user: \(loggedUser.userID).", error: error)
        }
    }
    
    public func shouldReconnectPubNubClient(client: PubNub!) -> NSNumber! {
        return true
    }
    
    public func shouldResubscribeOnConnectionRestore() -> NSNumber! {
        return true
    }
    
    
    // MARK: - Helper Method
    
    private func dictionaryFromJSON(jsonString: String) -> [String: AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let dictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)))  as? [String: AnyObject] {
                return dictionary
            }
        }
        return [String: AnyObject]()
    }

    
    // MARK: - Send Messages Methods
    
    func sendMessage(message: Dictionary<String, AnyObject>, pubnubID: String, completion: CompletionBlock?) {
        let channel = PNChannel.channelWithName(pubnubID) as! PNChannel

        var encryptedMessage = message
        encryptedMessage.updateValue(self.encrypt(JSON(message[MESSAGE_DATA]!).rawString()), forKey: MESSAGE_DATA)
        
        PubNub.sendMessage(encryptedMessage, toChannel: channel, storeInHistory: true) { (state, data) -> Void in
            print("message sent: \(data)")
            switch (state) {
            case PNMessageState.Sending:
                // PubNub client is sending message at this moment. 'data' stores reference on PNMessage instance which is processing at this moment.
                print("Sending")
            case PNMessageState.SendingError:
                // PubNub client failed to send message and reason is in 'data' object.
                print("SendingError")
                completion?(false)
            case PNMessageState.Sent:
                // PubNub client successfully sent message to specified channel. 'data' stores reference on PNMessage instance which has been sent.
                print("Sent")
                completion?(true)
            default:
                print("default")
            }
        }
    }


    // MARK: - Notifications Handler
	
    public func pubnubClient(client: PubNub!, didReceivePushNotificationEnabledChannels channels: [AnyObject]!) {
        print("didReceivePushNotificationEnabledChannels")
	}
}

protocol PubNubServiceDelegate: class {
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date:NSDate, fromChannelName: String)
    func pubnubClient(client: PubNub!, didReceiveMessageHistory messages: Array<HistoryMessage>, fromChannelName: String)

}

protocol PubNubHistoryDownloaderDelegate: class {
//    func pubnubClient(client: Pubnub, didReceiveHistoryFrom)
}