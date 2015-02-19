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

    var flips: Array<Flip> {
        get {
            var flips = Array<Flip>()
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            var orderedEntries = self.entries.sortedArrayUsingDescriptors([sortDescriptor])

            for entry in orderedEntries {
                flips.append((entry as FlipEntry).flip)
            }

            return flips
        }
    }

    func addFlip(flip: Flip, inContext context: NSManagedObjectContext) {
        let nextEntryOrder = self.entries.count

        var entry: FlipEntry! = FlipEntry.createInContext(context) as FlipEntry
        entry.order = nextEntryOrder
        entry.flip = flip.inContext(context) as Flip
        entry.message = self

        self.addEntriesObject(entry)
    }
    
    func messagePhrase() -> String {
        let flips = self.flips
        let words = flips.map {
            (var flip) -> String in
            return flip.word
        }

        return " ".join(words)
    }
    
    func messageThumbnail(success: ((UIImage?) -> Void)? = nil) -> Void {
        let firstFlip = self.flips.first
        if (firstFlip == nil || firstFlip!.thumbnailURL == nil) {
            self.createThumbnail(success)
            return
        }
        
        let thumbnailsCache = ThumbnailsCache.sharedInstance
        thumbnailsCache.get(NSURL(string: firstFlip!.thumbnailURL!)!,
            success: {
                (localPath: String!) in
                var image = UIImage(contentsOfFile: localPath)
                success?(image)
            }, failure: {
                (error: FlipError) in
                println("Could not get thumbnail for flip \(firstFlip), trying to create it.")
                self.createThumbnail(success)
        })
    }
    
    private func createThumbnail(success: ((UIImage) -> Void)? = nil) -> Void {
        let firstFlip = self.flips.first
        if (firstFlip == nil) {
            return
        }
        
        if (firstFlip!.isBackgroundContentTypeImage()) {
            let cacheHandler = CacheHandler.sharedInstance
            var backgroundImageData = cacheHandler.dataForUrl(firstFlip!.backgroundURL)
            
            var thumbnailImage: UIImage
            
            if (backgroundImageData == nil) {
                thumbnailImage = UIImage.emptyFlipImage()
            } else {
                thumbnailImage = UIImage(data: backgroundImageData!)!
            }
            
            var url = firstFlip!.backgroundURL
            if (url == nil || countElements(url) == 0) {
                url = "greenBackground"
            }
            
            cacheHandler.saveThumbnail(thumbnailImage, forUrl: url)

            success?(thumbnailImage)
        } else if (firstFlip!.isBackgroundContentTypeVideo()) {
            let flipsCache = FlipsCache.sharedInstance
            flipsCache.videoForFlip(firstFlip!,
                success: {
                    (localPath: String!) in
                    if let videoThumbnailImage = VideoHelper.generateThumbImageForFile(localPath) {
                        let thumbnailsCache = ThumbnailsCache.sharedInstance
                        thumbnailsCache.put(NSURL(string: firstFlip!.thumbnailURL)!, data: UIImagePNGRepresentation(videoThumbnailImage))
                        success?(videoThumbnailImage)
                    }
                }, failure: {
                    (error: FlipError) in
                    println("Failed to get flip \(firstFlip!) from cache.")
                    //TODO Enhance error handling
            })
        }
    }
    
    
    // MARK: - Message Handler
    
    func toJSON() -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary.updateValue(MESSAGE_FLIPS_INFO_TYPE, forKey: MESSAGE_TYPE)
        dictionary.updateValue(self.from.userID, forKey: FlipMessageJsonParams.FROM_USER_ID)
        dictionary.updateValue(self.createdAt.toFormattedString(), forKey: FlipMessageJsonParams.SENT_AT)
        dictionary.updateValue(self.flipMessageID, forKey: FlipMessageJsonParams.FLIP_MESSAGE_ID)
        
        let loggedUserFirstName = User.loggedUser()!.firstName
        let notificationMessage = "\(NOTIFICATION_MESSAGE) \(loggedUserFirstName)"
        
        var notificationDictionary = Dictionary<String, AnyObject>()
        notificationDictionary.updateValue(notificationMessage, forKey: NOTIFICATION_ALERT_KEY)
        
        var notificationApsDictionary = Dictionary<String, AnyObject>()
        notificationApsDictionary.updateValue(notificationDictionary, forKey: NOTIFICATION_KEY)
        
        dictionary.updateValue(notificationApsDictionary, forKey: NOTIFICATION_PN_KEY)
        
        var flipsDictionary = Array<Dictionary<String, String>>()
        let flips = self.flips
        for (var i = 0; i < flips.count; i++) {
            let flip = flips[i]
            var dic = Dictionary<String, String>()

            dic.updateValue(flip.flipID, forKey: FlipJsonParams.ID)
            dic.updateValue(flip.word, forKey: FlipJsonParams.WORD)
            dic.updateValue(flip.backgroundURL, forKey: FlipJsonParams.BACKGROUND_URL)
            dic.updateValue(flip.soundURL, forKey: FlipJsonParams.SOUND_URL)
            dic.updateValue(flip.isPrivate.stringValue, forKey: FlipJsonParams.IS_PRIVATE)
            dic.updateValue(flip.thumbnailURL, forKey: FlipJsonParams.THUMBNAIL_URL)

            flipsDictionary.append(dic)
        }
        
        dictionary.updateValue(flipsDictionary, forKey: FlipMessageJsonParams.CONTENT)
        return dictionary
    }
}