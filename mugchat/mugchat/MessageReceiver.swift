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
    
    var flipMessagesWaitingDownload: NSHashTable!
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        return Static.instance
    }
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        flipMessagesWaitingDownload = NSHashTable()
    }
    
    
    // MARK: - Events Methods
    
    private func onMessageReceived(flipMessage: FlipMessage) {
        // Notify any screen that there is a new message
        flipMessagesWaitingDownload.addObject(flipMessage)
        
        let downloader = Downloader.sharedInstance
        let flips = flipMessage.flips

        println("New Message Received")
        println("   From: \(flipMessage.from.firstName)")
        println("   Sent at: \(flipMessage.createdAt)")
        println("   #flips: \(flips.count)")

        for var i = 0; i < flips.count; i++ {
            println("       flip #\(flips[i].flipID)")
            let flip = flips[i]
            downloader.downloadDataForFlip(flip, isTemporary: true)
        }
    }
    
    private func onFlipContentDownloadFinished(flip: Flip) {
        if (flip.hasAllContentDownloaded()) {
            var flipMessagesToRemove = Array<FlipMessage>()
            
            for flipMessage: FlipMessage in flipMessagesWaitingDownload.allObjects as [FlipMessage] {
                if (flipMessage.hasAllContentDownloaded()) {
                    flipMessagesToRemove.append(flipMessage)
                    flipMessage.createThumbnail()
                }
            }
            
            for flipMessage in flipMessagesToRemove {
                flipMessagesWaitingDownload.removeObject(flipMessage)
            }
        }
    }
    
    
    // MARK: - Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var flipID = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY] as String
        
        let flipDataSource = FlipDataSource()
        let flip = flipDataSource.retrieveFlipWithId(flipID)
        
        if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
            println("Download failed for flip: \(flip.flipID)")
        } else {
            println("Download finished for flip: \(flip.flipID)")
            self.onFlipContentDownloadFinished(flip)
        }
    }
    
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, atDate date: NSDate, fromChannelName: String) {
        println("\nMessage received:\n\(messageJson)\n")
        
        if (messageJson[MESSAGE_TYPE] != nil) {
            if (messageJson[MESSAGE_TYPE].stringValue == MESSAGE_ROOM_INFO_TYPE) {
                self.onRoomReceived(messageJson)
            } else if (messageJson[MESSAGE_TYPE].stringValue == MESSAGE_FLIPS_INFO_TYPE) {
                // Message Received
                let flipMessageDataSource = FlipMessageDataSource()
                let flipMessage = flipMessageDataSource.createFlipMessageWithJson(messageJson, receivedDate: date, receivedAtChannel: fromChannelName)

                if (flipMessage != nil) {
                    self.onMessageReceived(flipMessage!)
                }
            }
        } else {
            // TODO: Old format - Should be remove later.
            let flipMessageDataSource = FlipMessageDataSource()
            let flipMessage = flipMessageDataSource.createFlipMessageWithJson(messageJson, receivedDate: date, receivedAtChannel: fromChannelName)
            if (flipMessage != nil) {
                self.onMessageReceived(flipMessage!)
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
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.createOrUpdateWithJson(messageJson[ChatMessageJsonParams.CONTENT])
        PubNubService.sharedInstance.subscribeToChannelID(room.pubnubID)
    }
}