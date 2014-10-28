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
    static let NAME = "name"
    static let PARTICIPANTS = "participants"
    static let ROOM_ID = "roomID"
    static let CONTENT = "content"
    static let CONTENT_ID = "id"
    static let CONTENT_WORD = "word"
    static let CONTENT_BACKGROUND_URL = "backgroundURL"
    static let CONTENT_SOUND_URL = "soundURL"
}

public class MessageReceiver: NSObject, PubNubServiceDelegate {
    
    public class var sharedInstance : MessageReceiver {
    struct Static {
        static let instance : MessageReceiver = MessageReceiver()
        }
        Static.instance.initMessageReceiver()
        return Static.instance
    }
    
    
    // MARK: - Initialization
    
    private func initMessageReceiver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)

    }
    
    // MARK: - Events Methods
    
    private func onMessageReceived(mugMessage: MugMessage) {
        // Notify any screen that there is a new message
        println("New Message Received")
        println("   From: \(mugMessage.from.firstName)")
        println("   Sent at: \(mugMessage.createdAt)")
        println("   #mugs: \(mugMessage.mugs.count)")
        
        let downloader = Downloader.sharedInstance
        for var i = 0; i < mugMessage.mugs.count; i++ {
            println("       mug #\(mugMessage.mugs.objectAtIndex(i).mugID)")
            downloader.downloadDataForMug(mugMessage.mugs.objectAtIndex(i) as Mug, isTemporary: true)
        }
    }
    
    private func onMugContentDownloadFinished(mug: Mug) {
        if (self.isMugWithAllDataDownloaded(mug)) {
            // create thumbnail - NOT TMP
            
            // And That's is
        }
    }
    
    
    // MARK: - Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var mug = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY] as Mug
//        var downloadFailed = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY]
//            = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] as Bool
        
        if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
            println("Download failed for mug: \(mug.mugID)")
        } else {
            self.onMugContentDownloadFinished(mug)
        }
    }
    
    
    // MARK: - Utils Methods
    
    func isMugWithAllDataDownloaded(mug: Mug) -> Bool {
        let cacheHanlder = CacheHandler.sharedInstance
        var allDataReceived = true
        
        if (!mug.backgroundURL.isEmpty) {
            if (!cacheHanlder.hasCachedFileForUrl(mug.backgroundURL)) {
                allDataReceived = false
            }
        }

        if (!mug.soundURL.isEmpty) {
            if (!cacheHanlder.hasCachedFileForUrl(mug.soundURL)) {
                allDataReceived = false
            }
        }
        
        return allDataReceived
    }
    
    // MARK: - PubnubServiceDelegate
    
    func pubnubClient(client: PubNub!, didReceiveMessage messageJson: JSON, fromChannelName: String, sentAt: NSDate) {
        let mugMessageDataSource = MugMessageDataSource()
        let mugMessage = mugMessageDataSource.createMugMessageWithJson(messageJson, receivedAtChannel: fromChannelName, sentAt: sentAt)
        self.onMessageReceived(mugMessage)
    }
    
    func startListeningMessages() {
        PubNubService.sharedInstance.delegate = self
    }
    
    func stopListeningMessages() {
        PubNubService.sharedInstance.delegate = nil
    }
}