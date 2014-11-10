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

public class MessageReceiver: NSObject, PubNubServiceDelegate {
    
    var mugMessagesWaitingDownload: NSHashTable!
    
    
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
        mugMessagesWaitingDownload = NSHashTable()
    }
    
    
    // MARK: - Events Methods
    
    private func onMessageReceived(mugMessage: MugMessage) {
        // Notify any screen that there is a new message
        println("New Message Received")
        println("   From: \(mugMessage.from.firstName)")
        println("   Sent at: \(mugMessage.createdAt)")
        println("   #mugs: \(mugMessage.mugs.count)")
        
        mugMessagesWaitingDownload.addObject(mugMessage)
        
        let downloader = Downloader.sharedInstance
        for var i = 0; i < mugMessage.mugs.count; i++ {
            println("       mug #\(mugMessage.mugs.objectAtIndex(i).mugID)")
            downloader.downloadDataForMug(mugMessage.mugs.objectAtIndex(i) as Mug, isTemporary: true)
        }
    }
    
    private func onMugContentDownloadFinished(mug: Mug) {
        if (mug.hasAllContentDownloaded()) {
            var mugMessagesToRemove = Array<MugMessage>()
            
            for mugMessage: MugMessage in mugMessagesWaitingDownload.allObjects as [MugMessage] {
                if (mugMessage.hasAllContentDownloaded()) {
                    mugMessagesToRemove.append(mugMessage)
                    mugMessage.createThumbnail()
                }
            }
            
            for mugMessage in mugMessagesToRemove {
                mugMessagesWaitingDownload.removeObject(mugMessage)
            }
        }
    }
    
    
    // MARK: - Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var mug = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY] as Mug
        if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
            println("Download failed for mug: \(mug.mugID)")
        } else {
            println("Download finished for mug: \(mug.mugID)")
            self.onMugContentDownloadFinished(mug)
        }
    }
    
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, fromChannelName: String) {
        let mugMessageDataSource = MugMessageDataSource()
        let mugMessage = mugMessageDataSource.createMugMessageWithJson(messageJson, receivedAtChannel: fromChannelName)
        self.onMessageReceived(mugMessage)
    }
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
}