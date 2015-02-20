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
    
    var flipMessagesWaiting: [FlipMessage: Array<Flip>]
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        return Static.instance
    }
    
    
    // MARK: - Initialization
    
    override init() {
        self.flipMessagesWaiting = [FlipMessage: Array<Flip>]()
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
    }
    
    
    // MARK: - Events Methods
    
    private func onMessageReceived(flipMessage: FlipMessage) {
        // Notify any screen that there is a new message
        
        let flips = flipMessage.flips

        println("New Message Received")
        println("   From: \(flipMessage.from.firstName)")
        println("   Sent at: \(flipMessage.createdAt)")
        println("   #flips: \(flips.count)")
        
        var isTemporary = true
        if let loggedUser = User.loggedUser() {
            if (loggedUser.userID == flipMessage.from.userID) {
                isTemporary = false
            }
        }

        flipMessagesWaiting[flipMessage] = Array<Flip>()

        for var i = 0; i < flips.count; i++ {
            println("       flip #\(flips[i].flipID)")
            let flip = flips[i]
            flipMessagesWaiting[flipMessage]?.append(flip)
            
            let flipsCache = FlipsCache.sharedInstance
            flipsCache.videoForFlip(flip,
                success: { (localPath: String!) in
                    self.sendDownloadFinishedBroadcastForFlip(flip, flipMessage: flipMessage, error: nil)
                },
                failure: { (error: FlipError) in
                    println("Failed to get resource from cache, error: \(error)")
                    self.sendDownloadFinishedBroadcastForFlip(flip, flipMessage: flipMessage, error: error)
            })
        }
    }
    
    private func sendDownloadFinishedBroadcastForFlip(flip: Flip, flipMessage: FlipMessage, error: FlipError?) {
        var userInfo: Dictionary<String, AnyObject> = [DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY: flip.flipID, DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE: flipMessage]
        
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
        let flipMessage = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MESSAGE] as FlipMessage
        
        let flipDataSource = FlipDataSource()
        if let flip = flipDataSource.retrieveFlipWithId(flipID) {
            if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
                println("Download failed for flip: \(flip.flipID)")
            } else {
                println("Download finished for flip: \(flip.flipID)")
                self.onFlipContentDownloadFinished(flip, flipMessage: flipMessage)
            }
        } else {
            UIAlertView.showUnableToLoadFlip()
        }
    }
    
    private func onFlipContentDownloadFinished(flip: Flip, flipMessage: FlipMessage) {
        if (self.flipMessagesWaiting[flipMessage] == nil) {
            return
        }
        
        var flipMessagesToRemove = Array<FlipMessage>()

        let arrayOfFlips: Array<Flip> = self.flipMessagesWaiting[flipMessage]!
        for i in 0..<arrayOfFlips.count {
            if (flip.flipID == arrayOfFlips[i].flipID) {
                self.flipMessagesWaiting[flipMessage]!.removeAtIndex(i)
                break
            }
        }
        
        if (self.flipMessagesWaiting[flipMessage]!.isEmpty) {
            flipMessagesToRemove.append(flipMessage)
            flipMessage.messageThumbnail()
        }
        
        for flipMessage in flipMessagesToRemove {
            self.flipMessagesWaiting[flipMessage] = nil
        }
    }
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date: NSDate, fromChannelName: String) {
        println("\nMessage received:\n\(messageJson)\n")
        println("Received date: \(date)")
        if (messageJson[MESSAGE_TYPE] == nil) {
            println("MESSAGE IN OLD FORMAT. SHOULD BE IGNORED")
            return
        }
        
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
        let room = PersistentManager.sharedInstance.createOrUpdateRoomWithJson(messageJson[ChatMessageJsonParams.CONTENT])
        PubNubService.sharedInstance.subscribeToChannelID(room.pubnubID)
    }
}