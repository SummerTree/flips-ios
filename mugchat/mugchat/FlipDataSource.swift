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

import Foundation

struct FlipJsonParams {
    static let ID = "id"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let SOUND_URL = "soundURL"
    static let OWNER = "owner"
    static let IS_PRIVATE = "isPrivate"
    static let THUMBNAIL_URL = "thumbnailURL"
}

struct FlipAttributes {
    static let FLIP_ID = "flipID"
    static let FLIP_OWNER = "owner"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let SOUND_URL = "soundURL"
    static let IS_PRIVATE = "isPrivate"
}

public typealias CreateFlipSuccess = (Flip) -> Void
public typealias CreateFlipFail = (FlipError) -> Void

class FlipDataSource : BaseDataSource {
    
    private let EMPTY_FLIP_ID = "-1"
    
    private func createEntityWithJson(json: JSON) -> Flip {
        var entity: Flip! = Flip.createEntity() as Flip
        self.fillFlip(entity, withJsonData: json)
        self.save()
        
        return entity
    }
    
    private func fillFlip(flip: Flip, withJsonData json: JSON) {
        if (flip.flipID != json[FlipJsonParams.ID].stringValue) {
            println("Possible error. Will update flip id from (\(flip.flipID)) to (\(json[FlipJsonParams.ID].stringValue))")
        }
        
        flip.flipID = json[FlipJsonParams.ID].stringValue
        flip.word = json[FlipJsonParams.WORD].stringValue
        flip.backgroundURL = json[FlipJsonParams.BACKGROUND_URL].stringValue
        flip.soundURL = json[FlipJsonParams.SOUND_URL].stringValue
        flip.isPrivate = json[FlipJsonParams.IS_PRIVATE].boolValue
        flip.thumbnailURL = json[FlipJsonParams.THUMBNAIL_URL].stringValue
        
        let flipOwnerID = json[FlipJsonParams.OWNER].stringValue
        if (!flipOwnerID.isEmpty) {
            let userDataSource = UserDataSource()
            flip.owner = userDataSource.retrieveUserWithId(flipOwnerID)
        }
    }
    
    
    // MARK: - Public Methods
    
    func createOrUpdateFlipsWithJson(json: JSON) -> Flip {
        var flipID = json[FlipJsonParams.ID].stringValue
        var flip = self.getFlipById(flipID)
        
        if (flip == nil) {
            flip = self.createEntityWithJson(json)
        } else {
            self.fillFlip(flip!, withJsonData: json)
            self.save()
        }
        
        return flip!
    }
    
    func createFlipWithWord(word: String, backgroundImage: UIImage?, soundURL: NSURL?, createFlipSuccess: CreateFlipSuccess, createFlipFail: CreateFlipFail) {
        let cacheHandler = CacheHandler.sharedInstance
        let flipService = FlipService()
        
        flipService.createFlip(word, backgroundImage: backgroundImage, soundPath: soundURL, createFlipSuccessCallback: { (flip) -> Void in
            var userDataSource = UserDataSource()
            flip.owner = User.loggedUser()
            flip.setBackgroundContentType(BackgroundContentType.Image)
            
            if (backgroundImage != nil) {
                cacheHandler.saveImage(backgroundImage!, withUrl: flip.backgroundURL, isTemporary: false)
            }
            
            if (soundURL != nil) {
                cacheHandler.saveDataAtPath(soundURL!.relativePath!, withUrl: flip.soundURL, isTemporary: false)
            }
            
            createFlipSuccess(flip)
        }) { (flipError) -> Void in
            createFlipFail(flipError!)
        }
    }
    
    func createFlipWithWord(word: String, videoURL: NSURL, createFlipSuccess: CreateFlipSuccess, createFlipFail: CreateFlipFail) {
        let cacheHandler = CacheHandler.sharedInstance
        let flipService = FlipService()
        
        flipService.createFlip(word, videoPath: videoURL, isPrivate: true, createFlipSuccessCallback: { (flip) -> Void in
            var userDataSource = UserDataSource()
            flip.owner = User.loggedUser()
            flip.setBackgroundContentType(BackgroundContentType.Video)
            
            cacheHandler.saveThumbnail(VideoHelper.generateThumbImageForFile(videoURL.relativePath!), forUrl: flip.backgroundURL)
            cacheHandler.saveDataAtPath(videoURL.relativePath!, withUrl: flip.backgroundURL, isTemporary: false)
            createFlipSuccess(flip)
        }) { (flipError) -> Void in
            createFlipFail(flipError!)
        }
    }
    
    // This flip is never uploaded to the server. It is used only via Pubnub
    func createEmptyFlipWithWord(word: String) -> Flip {
        var flip: Flip! = Flip.MR_createEntity() as Flip

        flip.word = word
        
        return flip
    }

    
    func retrieveFlipWithId(id: String) -> Flip {
        var flip = self.getFlipById(id)
        
        if (flip == nil) {
            println("Flip (\(id)) not found in the database and it mustn't happen. Check why it wasn't added to database yet.")
        }
        
        return flip!
    }
    
    func setFlipBackgroundContentType(contentType: BackgroundContentType, forFlip flip: Flip) {
        flip.setBackgroundContentType(contentType)
        self.save()
    }
    
    func getMyFlips() -> [Flip] {
        return Flip.findAllSortedBy(FlipAttributes.FLIP_ID, ascending: true, withPredicate: NSPredicate(format: "(\(FlipAttributes.FLIP_OWNER).userID == \(AuthenticationHelper.sharedInstance.userInSession.userID))")) as [Flip]
    }
    
    func getMyFlipsForWord(word: String) -> [Flip] {
        return Flip.findAllWithPredicate(NSPredicate(format: "((\(FlipAttributes.FLIP_OWNER).userID == \(AuthenticationHelper.sharedInstance.userInSession.userID)) and (\(FlipAttributes.WORD) ==[cd] %@) and ( (\(FlipAttributes.BACKGROUND_URL)  MATCHES '.{1,}') or (\(FlipAttributes.SOUND_URL) MATCHES '.{1,}') ))", word)) as [Flip]
    }
    
    func getMyFlipsIdsForWords(words: [String]) -> Dictionary<String, [String]> {
        var resultDictionary = Dictionary<String, [String]>()
        
        if (words.count == 0) {
            return resultDictionary
        }
        
        for word in words {
            resultDictionary[word] = Array<String>()
            
            // I didn't find a way to use a NSPredicate case-insensitive with an IN clause
            // I've tried in many diffent ways with NSPredicate or NSCompoundPredicate, but none of it worked and for some of it returned an weird error about a selector not found.
            // The error happened when I tried to use: NSPredicate(format: <#String#>, argumentArray: <#[AnyObject]?#>)
            // Error: swift predicate reason: '-[Swift._NSContiguousString countByEnumeratingWithState:objects:count:]: unrecognized selector
            var flips = self.getMyFlipsForWord(word)
            for flip in flips {
                resultDictionary[word]?.append(flip.flipID)
            }
        }
        
        return resultDictionary
    }
    
    func getStockFlipsForWord(word: String) -> [Flip] {
        return Flip.findAllWithPredicate(NSPredicate(format: "((\(FlipAttributes.IS_PRIVATE) == false) and (\(FlipAttributes.WORD) ==[cd] %@) and ( (\(FlipAttributes.BACKGROUND_URL)  MATCHES '.{1,}') or (\(FlipAttributes.SOUND_URL) MATCHES '.{1,}') ))", word)) as [Flip]
    }
    
    func getStockFlipsIdsForWords(words: [String]) -> Dictionary<String, [String]> {
        var resultDictionary = Dictionary<String, [String]>()
        
        if (words.count > 0) {
            for word in words {
                resultDictionary[word] = Array<String>()

                var flips = self.getStockFlipsForWord(word)
                for flip in flips {
                    resultDictionary[word]?.append(flip.flipID)
                }
            }
        }
        
        return resultDictionary
    }

    
    // MARK: - Private Getters Methods
    
    private func getFlipById(id: String) -> Flip? {
        return Flip.findFirstByAttribute(FlipAttributes.FLIP_ID, withValue: id) as? Flip
    }
}