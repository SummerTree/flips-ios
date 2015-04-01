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

public struct FormattedFlip {
    var flip: Flip
    var word: String
}

extension FlipMessage {

    var flipsEntries: Array<FlipEntry> {
        get {
            var flipsEntries: Array<FlipEntry> = Array<FlipEntry>()
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            return self.entries.sortedArrayUsingDescriptors([sortDescriptor]) as Array<FlipEntry>
        }
    }

    func addFlip(formatedFlip: FormattedFlip, inContext context: NSManagedObjectContext) {
        let nextEntryOrder = self.entries.count

        var entry: FlipEntry! = FlipEntry.createInContext(context) as FlipEntry
        entry.order = nextEntryOrder
        entry.formattedWord = formatedFlip.word
        entry.flip = formatedFlip.flip.inContext(context) as Flip
        entry.message = self

        self.addEntriesObject(entry)
    }
    
    func messagePhrase() -> String {
        let flipsEntries = self.flipsEntries
        let words = flipsEntries.map {
            (var flipEntry) -> String in
            return flipEntry.formattedWord
        }

        return " ".join(words)
    }
    
    func messageThumbnail(success: ((UIImage?) -> Void)? = nil) -> Void {
        if let firstEntry: FlipEntry = self.flipsEntries.first {
            if let firstFlip: Flip = firstEntry.flip {
                if (firstFlip.thumbnailURL == nil || firstFlip.thumbnailURL == "") {
                    success?(UIImage.emptyFlipImage())
                    return
                }
                
                let thumbnailsCache = ThumbnailsCache.sharedInstance
                thumbnailsCache.get(NSURL(string: firstFlip.thumbnailURL!)!,
                    success: { (url: String!, localPath: String!) in
                        var image = UIImage(contentsOfFile: localPath)
                        success?(image)
                    }, failure: { (url: String!, error: FlipError) in
                        println("Could not get thumbnail for flip \(firstFlip).")
                })
            }
        } else {
            success?(UIImage.emptyFlipImage())
        }
    }
    
    
    // MARK: - Message Handler
    
    func toJsonUsingFlipWords(flipWords: [FlipText]) -> Dictionary<String, AnyObject> {
        var dictionary = Dictionary<String, AnyObject>()
        
        dictionary.updateValue(MESSAGE_FLIPS_INFO_TYPE, forKey: MESSAGE_TYPE)
        dictionary.updateValue(self.from.userID, forKey: FlipMessageJsonParams.FROM_USER_ID)
        dictionary.updateValue(self.createdAt.toFormattedString(), forKey: FlipMessageJsonParams.SENT_AT)
        dictionary.updateValue(self.flipMessageID, forKey: FlipMessageJsonParams.FLIP_MESSAGE_ID)
        
        var notificationMessage = ""
        if let loggedUser = User.loggedUser() {
            let loggedUserFirstName = loggedUser.firstName
            notificationMessage = "\(NOTIFICATION_MESSAGE) \(loggedUserFirstName)"
        }
        
        var notificationDictionary = Dictionary<String, AnyObject>()
        notificationDictionary.updateValue(notificationMessage, forKey: NOTIFICATION_ALERT_KEY)
        
        var notificationApsDictionary = Dictionary<String, AnyObject>()
        notificationApsDictionary.updateValue(notificationDictionary, forKey: NOTIFICATION_KEY)
        
        dictionary.updateValue(notificationApsDictionary, forKey: NOTIFICATION_PN_KEY)
        
        var flipsDictionary = Array<Dictionary<String, String>>()
        let flipsEntries = self.flipsEntries
        for (var i = 0; i < flipsEntries.count; i++) {
            let flip: Flip = flipsEntries[i].flip
            let flipWord: FlipText = flipWords[i]
            
            var dic = Dictionary<String, String>()

            dic.updateValue(flip.flipID, forKey: FlipJsonParams.ID)
            dic.updateValue(flipWord.text, forKey: FlipJsonParams.WORD)
            dic.updateValue(flip.backgroundURL, forKey: FlipJsonParams.BACKGROUND_URL)
            dic.updateValue(flip.isPrivate.stringValue, forKey: FlipJsonParams.IS_PRIVATE)
            dic.updateValue(flip.thumbnailURL, forKey: FlipJsonParams.THUMBNAIL_URL)

            flipsDictionary.append(dic)
        }
        
        dictionary.updateValue(flipsDictionary, forKey: FlipMessageJsonParams.CONTENT)
        return dictionary
    }
}