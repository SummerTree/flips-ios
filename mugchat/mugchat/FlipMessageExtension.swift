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

private let NOTIFICATION_PN_KEY = "pn_apns"
private let NOTIFICATION_KEY = "aps"
private let NOTIFICATION_ALERT_KEY = "alert"
private let NOTIFICATION_MESSAGE = "You received a new flip message from"

extension FlipMessage {

    func addFlip(flip: Flip) {
        
        for (var i: Int = 0; i < self.flips.count; i++) {
            if (flip.flipID == self.flips.objectAtIndex(i).flipID) {
                println("Flip already added to this FlipMessage")
                return
            }
        }
        
        var mutableOrderedSet = NSMutableOrderedSet(orderedSet: self.flips)
        mutableOrderedSet.addObject(flip)
        self.flips = mutableOrderedSet
    }
    
    func messagePhrase() -> String {
        var message = ""
        var space = ""
        for (var i: Int = 0; i < self.flips.count; i++) {
            let flip = self.flips.objectAtIndex(i) as Flip
            message = "\(message)\(space)\(flip.word)"
            space = " "
        }
        
        return message
    }
    
    func messageThumbnail() -> UIImage? {
        let firstFlip = self.flips.firstObject as Flip
        return CacheHandler.sharedInstance.thumbnailForUrl(firstFlip.backgroundURL)
    }
    
    func createThumbnail() {
        let firstFlip = self.flips.firstObject as? Flip

        if (firstFlip == nil) {
            return
        }

        let cacheHandler = CacheHandler.sharedInstance
        if (firstFlip!.isBackgroundContentTypeImage()) {
            let backgroundImageData = cacheHandler.dataForUrl(firstFlip!.backgroundURL)
            if (backgroundImageData != nil) {
                cacheHandler.saveThumbnail(UIImage(data: backgroundImageData!)!, forUrl: firstFlip!.backgroundURL)
            }
        } else if (firstFlip!.isBackgroundContentTypeVideo()) {
            let videoPath = cacheHandler.getFilePathForUrlFromAnyFolder(firstFlip!.backgroundURL)
            if (videoPath != nil) {
                let videoThumbnailImage = VideoHelper.generateThumbImageForFile(videoPath!)
                cacheHandler.saveThumbnail(videoThumbnailImage, forUrl: firstFlip!.backgroundURL)
            }
        }
    }
    
    func hasAllContentDownloaded() -> Bool {
        var allContentReceived = true
        for var i = 0; i < self.flips.count; i++ {
            var flip = self.flips.objectAtIndex(i) as Flip
            if (!flip.hasAllContentDownloaded()) {
                allContentReceived = false
            }
        }
        return allContentReceived
    }
    
    
    // MARK: - Message Handler
    
    func toJSON() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary.updateValue(MESSAGE_FLIPS_INFO_TYPE, forKey: MESSAGE_TYPE)
        dictionary.updateValue(self.from.userID, forKey: FlipMessageJsonParams.FROM_USER_ID)
        dictionary.updateValue(self.createdAt.toFormattedString(), forKey: FlipMessageJsonParams.SENT_AT)
        dictionary.updateValue(self.flipMessageID, forKey: FlipMessageJsonParams.FLIP_MESSAGE_ID)
        
        let loggedUserFirstName = AuthenticationHelper.sharedInstance.userInSession.firstName
        let notificationMessage = "\(NOTIFICATION_MESSAGE) \(loggedUserFirstName)"
        
        var notificationDictionary = Dictionary<String, AnyObject>()
        notificationDictionary.updateValue(notificationMessage, forKey: NOTIFICATION_ALERT_KEY)
        
        var notificationApsDictionary = Dictionary<String, AnyObject>()
        notificationApsDictionary.updateValue(notificationDictionary, forKey: NOTIFICATION_KEY)
        
        dictionary.updateValue(notificationApsDictionary, forKey: NOTIFICATION_PN_KEY)
        
        var flips = Array<Dictionary<String, String>>()
        for (var i = 0; i < self.flips.count; i++) {
            let flip = self.flips.objectAtIndex(i) as Flip
            var flipDictionary = Dictionary<String, String>()
            flipDictionary.updateValue(flip.flipID, forKey: FlipJsonParams.ID)
            flipDictionary.updateValue(flip.word, forKey: FlipJsonParams.WORD)
            flipDictionary.updateValue(flip.backgroundURL, forKey: FlipJsonParams.BACKGROUND_URL)
            flipDictionary.updateValue(flip.soundURL, forKey: FlipJsonParams.SOUND_URL)
            
            flips.append(flipDictionary)
        }
        
        dictionary.updateValue(flips, forKey: FlipMessageJsonParams.CONTENT)
        return dictionary
    }
}