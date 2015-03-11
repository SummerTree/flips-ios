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
    static let CONTENT = "content"
    static let CONTENT_ID = "id"
    static let CONTENT_WORD = "word"
    static let CONTENT_BACKGROUND_URL = "backgroundURL"
    static let CONTENT_SOUND_URL = "soundURL"
}

let MESSAGE_TYPE = "type"
let MESSAGE_ROOM_INFO_TYPE = "1"
let MESSAGE_FLIPS_INFO_TYPE = "2"

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
        let firstFlip = flipMessage.flips.first! as Flip
        flipMessagesWaiting[flipMessage.flipMessageID]?.append(firstFlip.flipID)

        println("   downloading thumbnail for flip #\(firstFlip.flipID)")

        let cache = ThumbnailsCache.sharedInstance
        cache.get(NSURL(string: firstFlip.thumbnailURL)!,
            success: { (localPath: String!) -> Void in
                self.sendDownloadFinishedBroadcastForFlip(firstFlip, flipMessageID: flipMessage.flipMessageID, error: nil)
            },
            failure: { (error: FlipError) -> Void in
                println("Failed to get resource from cache, error: \(error)")
                self.sendDownloadFinishedBroadcastForFlip(firstFlip, flipMessageID: flipMessage.flipMessageID, error: error)
        })
    }
    
    private func sendDownloadFinishedBroadcastForFlip(flip: Flip, flipMessageID: String, error: FlipError?) {
        var userInfo: Dictionary<String, AnyObject> = [DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: flip.flipID, DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE_KEY: flipMessageID]
        
        if (error != nil) {
            println("Error download flip content: \(error!)")
            userInfo.updateValue(true, forKey: DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil, userInfo: userInfo)
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
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date: NSDate, fromChannelName: String) {
        if (messageJson[MESSAGE_TYPE] == nil) {
            println("MESSAGE IN OLD FORMAT. SHOULD BE IGNORED")
            println("\nMessage received:\n\(messageJson)\n")
            return
        }
        
        if (!AuthenticationHelper.sharedInstance.isAuthenticated()) {
            println("User is not logged. Ignoring message.")
            return
        }
        
        println("\nMessage received:\n\(messageJson)\n")
        
        if (messageJson[MESSAGE_TYPE].stringValue == MESSAGE_ROOM_INFO_TYPE) {
            self.onRoomReceived(messageJson)
        } else if (messageJson[MESSAGE_TYPE].stringValue == MESSAGE_FLIPS_INFO_TYPE) {
            // Message Received
            let flipMessage = PersistentManager.sharedInstance.createFlipMessageWithJson(messageJson, receivedDate: date, receivedAtChannel: fromChannelName)
            
            if (flipMessage != nil) {
                self.onMessageReceived(flipMessage!.inContext(NSManagedObjectContext.contextForCurrentThread()) as FlipMessage)
            }
        }
    }
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
    
    func onRoomReceived(messageJson: JSON) {
        let room = PersistentManager.sharedInstance.createOrUpdateRoomWithJson(messageJson[ChatMessageJsonParams.CONTENT]).inContext(NSManagedObjectContext.MR_defaultContext()) as Room
        PubNubService.sharedInstance.subscribeToChannelID(room.pubnubID)
    }
}