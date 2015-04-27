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
    static let SENT_AT = "sentAt"
    static let PARTICIPANTS = "participants"
    static let ROOM_ID = "roomID"
    static let CONTENT_ID = "id"
    static let CONTENT_WORD = "word"
    static let CONTENT_BACKGROUND_URL = "backgroundURL"
    static let CONTENT_SOUND_URL = "soundURL"
}

let MESSAGE_TYPE = "type"
let MESSAGE_ROOM_INFO_TYPE = "1"
let MESSAGE_FLIPS_INFO_TYPE = "2"
let MESSAGE_READ_INFO_TYPE = "3"
let MESSAGE_DELETED_INFO_TYPE = "4"

let FLIP_MESSAGE_RECEIVED_NOTIFICATION: String = "flip_message_received_notification"
let FLIP_MESSAGE_RECEIVED_NOTIFICATION_PARAM_MESSAGE_KEY: String = "flip_message_received_notification_param_message_key"


public class MessageReceiver: NSObject, PubNubServiceDelegate {
    
    var flipMessagesWaiting: [String: Array<String>]
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        return Static.instance
    }
    
    
    // MARK: - Initialization
    
    override init() {
        self.flipMessagesWaiting = [String: Array<String>]()
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
    }
    
    
    // MARK: - Events Methods
    
    private func onMessageReceived(flipMessage: FlipMessage) {
        // Notify any screen that there is a new message

        println("New Message Received")
        println("   From: \(flipMessage.from.firstName)")
        println("   Sent at: \(flipMessage.createdAt)")
        
        var isTemporary = true
        if let loggedUser = User.loggedUser() {
            if (loggedUser.userID == flipMessage.from.userID) {
                isTemporary = false
            }
        }

        flipMessagesWaiting[flipMessage.flipMessageID] = Array<String>()

        // Download the thumbnail only for the first flip of the message
        let firstEntry = flipMessage.flipsEntries.first! as FlipEntry
        let firstFlip = firstEntry.flip
        flipMessagesWaiting[flipMessage.flipMessageID]?.append(firstFlip.flipID)

        println("   downloading thumbnail for flip #\(firstFlip.flipID)")

        let cache = ThumbnailsCache.sharedInstance
        cache.get(NSURL(string: firstFlip.thumbnailURL)!,
            success: { (remoteURL: String!, localPath: String!) -> Void in
                self.sendDownloadFinishedBroadcastForFlip(firstFlip, flipMessageID: flipMessage.flipMessageID, error: nil)
            },
            failure: { (remoteURL: String!, error: FlipError) -> Void in
                println("Failed to get resource from cache, error: \(error)")
                self.sendDownloadFinishedBroadcastForFlip(firstFlip, flipMessageID: flipMessage.flipMessageID, error: error)
        })
        
        self.sendMessageReceiveNotificationForFlipMessageID(flipMessage.flipMessageID)
    }
    
    private func sendDownloadFinishedBroadcastForFlip(flip: Flip, flipMessageID: String, error: FlipError?) {
        var userInfo: Dictionary<String, AnyObject> = [DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: flip.flipID, DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY: flipMessageID]
        
        if (error != nil) {
            println("Error download flip content: \(error!)")
            userInfo.updateValue(true, forKey: DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil, userInfo: userInfo)
    }
    
    private func sendMessageReceiveNotificationForFlipMessageID(flipMessageID: String) {
        var userInfo: Dictionary<String, String> = Dictionary<String, String>()
        userInfo.updateValue(flipMessageID, forKey: FLIP_MESSAGE_RECEIVED_NOTIFICATION_PARAM_MESSAGE_KEY)
        NSNotificationCenter.defaultCenter().postNotificationName(FLIP_MESSAGE_RECEIVED_NOTIFICATION, object: nil, userInfo: userInfo)
    }

    private func onRoomReceived(messageJson: JSON) {
        let room = PersistentManager.sharedInstance.createRoomWithJson(messageJson[MESSAGE_CONTENT]).inContext(NSManagedObjectContext.MR_defaultContext()) as Room
        PubNubService.sharedInstance.subscribeToChannelID(room.pubnubID)
    }


    // MARK: - Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        let userInfo: Dictionary = notification.userInfo!
        let flipID = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY] as String
        let flipMessageID = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY] as String
        
        let flipDataSource = FlipDataSource()
        if let flip = flipDataSource.retrieveFlipWithId(flipID) {
            if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
                println("Download failed for flip: \(flip.flipID)")
            } else {
                println("Download finished for flip: \(flip.flipID)")
                self.onFlipContentDownloadFinished(flip, flipMessageID: flipMessageID)
            }
        } else {
            if (AuthenticationHelper.sharedInstance.isAuthenticated()) {
                UIAlertView.showUnableToLoadFlip()
            }
        }
    }
    
    private func onFlipContentDownloadFinished(flip: Flip, flipMessageID: String) {
        if (self.flipMessagesWaiting[flipMessageID] == nil) {
            return
        }
        
        var flipMessagesToRemove = Array<FlipMessage>()

        let arrayOfFlips: Array<String> = self.flipMessagesWaiting[flipMessageID]!
        for i in 0..<arrayOfFlips.count {
            if (flip.flipID == arrayOfFlips[i]) {
                self.flipMessagesWaiting[flipMessageID]!.removeAtIndex(i)
                break
            }
        }
        
        if (self.flipMessagesWaiting[flipMessageID]!.isEmpty) {
            let flipMessageDataSource = FlipMessageDataSource()
            let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageID)
            flipMessagesToRemove.append(flipMessage)
            flipMessage.messageThumbnail()
        }
        
        for flipMessage in flipMessagesToRemove {
            self.flipMessagesWaiting[flipMessageID] = nil
        }
    }


    // MARK: - New message

    private func processFlipMessageJson(messageJson: JSON, atDate date: NSDate, fromChannelName: String, fromHistory: Bool) -> FlipMessage? {
        if (messageJson[MESSAGE_TYPE] == nil) {
            println("Msg ignored")
            return nil
        }

        if (!AuthenticationHelper.sharedInstance.isAuthenticated()) {
            println("User is not logged. Ignoring message.")
            return nil
        }
        
        let messageType: String = messageJson[MESSAGE_TYPE].stringValue

        switch messageType {
        case MESSAGE_ROOM_INFO_TYPE:
            self.onRoomReceived(messageJson)
        case MESSAGE_FLIPS_INFO_TYPE:
            return PersistentManager.sharedInstance.createFlipMessageWithJson(messageJson, receivedDate: date, receivedAtChannel: fromChannelName, isFromHistory: fromHistory)
        case MESSAGE_READ_INFO_TYPE:
            // Returning the updated flipMessage, so, if it was updated, the app will refresh any screen that is showing the message or has it cached.
            return PersistentManager.sharedInstance.onMarkFlipMessageAsReadReceivedWithJson(messageJson)
        case MESSAGE_DELETED_INFO_TYPE:
            return PersistentManager.sharedInstance.onMessageForDeletedFlipMessageReceivedWithJson(messageJson)
        default:
            break;
        }

        return nil
    }

    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date: NSDate, fromChannelName: String) {
        println("\nMessage received:\n\(messageJson)\n")

        let flipMessage = self.processFlipMessageJson(messageJson, atDate: date, fromChannelName: fromChannelName, fromHistory: false)

        if (flipMessage != nil) {
            self.onMessageReceived(flipMessage!.inContext(NSManagedObjectContext.contextForCurrentThread()) as FlipMessage)
        }
    }

    func pubnubClient(client: PubNub!, didReceiveMessageHistory messages: Array<HistoryMessage>, fromChannelName: String) {
        for hMessage in messages {
            self.processFlipMessageJson(hMessage.message, atDate: hMessage.receivedDate, fromChannelName: fromChannelName, fromHistory: true)
        }
    }


    // MARK: - Event Handlers

    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }

}
