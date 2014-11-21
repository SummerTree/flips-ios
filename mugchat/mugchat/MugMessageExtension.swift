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

extension MugMessage {

    func addMug(mug: Mug) {
        
        for (var i: Int = 0; i < self.mugs.count; i++) {
            if (mug.mugID == self.mugs.objectAtIndex(i).mugID) {
                println("Mug already added to this MugMessage")
                return
            }
        }
        
        var mutableOrderedSet = NSMutableOrderedSet(orderedSet: self.mugs)
        mutableOrderedSet.addObject(mug)
        self.mugs = mutableOrderedSet
    }
    
    func messagePhrase() -> String {
        var message = ""
        var space = ""
        for (var i: Int = 0; i < self.mugs.count; i++) {
            let mug = self.mugs.objectAtIndex(i) as Mug
            message = "\(message)\(space)\(mug.word)"
            space = " "
        }
        
        return message
    }
    
    func messageThumbnail() -> UIImage? {
        let firstMug = self.mugs.firstObject as Mug
        return CacheHandler.sharedInstance.thumbnailForUrl(firstMug.backgroundURL)
    }
    
    func createThumbnail() {
        let firstMug = self.mugs.firstObject as Mug
        let cacheHandler = CacheHandler.sharedInstance
        if (firstMug.isBackgroundContentTypeImage()) {
            let backgroundImageData = cacheHandler.dataForUrl(firstMug.backgroundURL)
            if (backgroundImageData != nil) {
                cacheHandler.saveThumbnail(UIImage(data: backgroundImageData!)!, forUrl: firstMug.backgroundURL)
            }
        } else if (firstMug.isBackgroundContentTypeVideo()) {
            // TODO:
        }
    }
    
    func hasAllContentDownloaded() -> Bool {
        var allContentReceived = true
        for var i = 0; i < self.mugs.count; i++ {
            var mug = self.mugs.objectAtIndex(i) as Mug
            if (!mug.hasAllContentDownloaded()) {
                allContentReceived = false
            }
        }
        return allContentReceived
    }
    
    
    // MARK: - Message Handler
    
    func toJSON() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary.updateValue(MESSAGE_FLIPS_INFO_TYPE, forKey: MESSAGE_TYPE)
        dictionary.updateValue(self.from.userID, forKey: MugMessageJsonParams.FROM_USER_ID)
        dictionary.updateValue(self.createdAt.toFormattedString(), forKey: MugMessageJsonParams.SENT_AT)
        dictionary.updateValue(self.mugMessageID, forKey: MugMessageJsonParams.FLIP_MESSAGE_ID)
        
        let loggedUserFirstName = AuthenticationHelper.sharedInstance.userInSession.firstName
        let notificationMessage = "\(NOTIFICATION_MESSAGE) \(loggedUserFirstName)"
        
        var notificationDictionary = Dictionary<String, AnyObject>()
        notificationDictionary.updateValue(notificationMessage, forKey: NOTIFICATION_ALERT_KEY)
        
        var notificationApsDictionary = Dictionary<String, AnyObject>()
        notificationApsDictionary.updateValue(notificationDictionary, forKey: NOTIFICATION_KEY)
        
        dictionary.updateValue(notificationApsDictionary, forKey: NOTIFICATION_PN_KEY)
        
        var flips = Array<Dictionary<String, String>>()
        for (var i = 0; i < self.mugs.count; i++) {
            let flip = self.mugs.objectAtIndex(i) as Mug
            var flipDictionary = Dictionary<String, String>()
            flipDictionary.updateValue(flip.mugID, forKey: MugJsonParams.ID)
            flipDictionary.updateValue(flip.word, forKey: MugJsonParams.WORD)
            flipDictionary.updateValue(flip.backgroundURL, forKey: MugJsonParams.BACKGROUND_URL)
            flipDictionary.updateValue(flip.soundURL, forKey: MugJsonParams.SOUND_URL)
            
            flips.append(flipDictionary)
        }
        
        dictionary.updateValue(flips, forKey: MugMessageJsonParams.CONTENT)
        return dictionary
    }
}