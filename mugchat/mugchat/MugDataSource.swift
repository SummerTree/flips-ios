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

private struct MugJsonParams {
    static let ID = "id"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let SOUND_URL = "soundURL"
    static let OWNER = "owner"
}

struct MugAttributes {
    static let MUG_ID = "mugID"
    static let MUG_OWNER = "owner"
    static let WORD = "word"
}

public typealias CreateMugSuccess = (Mug) -> Void
public typealias CreateMugFail = (String) -> Void

class MugDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> Mug {
        var entity: Mug! = Mug.createEntity() as Mug
        self.fillMug(entity, withJsonData: json)
        self.save()
        
        return entity
    }
    
    private func fillMug(mug: Mug, withJsonData json: JSON) {
        if (mug.mugID != json[MugJsonParams.ID].stringValue) {
            println("Possible error. Will update mug id from (\(mug.mugID)) to (\(json[MugJsonParams.ID].stringValue))")
        }
        
        mug.mugID = json[MugJsonParams.ID].stringValue
        mug.word = json[MugJsonParams.WORD].stringValue
        mug.backgroundURL = json[MugJsonParams.BACKGROUND_URL].stringValue
        mug.soundURL = json[MugJsonParams.SOUND_URL].stringValue
        
        let mugOwnerID = json[MugJsonParams.OWNER].stringValue
        if (!mugOwnerID.isEmpty) {
            let userDataSource = UserDataSource()
            mug.owner = userDataSource.retrieveUserWithId(mugOwnerID)
        }
    }
    
    
    // MARK: - Public Methods
    
    func createOrUpdateMugsWithJson(json: JSON) -> Mug {
        var mugID = json[MugJsonParams.ID].stringValue
        var mug = self.getMugById(mugID)
        
        if (mug == nil) {
            mug = self.createEntityWithJson(json)
        } else {
            self.fillMug(mug!, withJsonData: json)
            self.save()
        }
        
        return mug!
    }
    
    func createMugWithWord(word: String, backgroundImage: UIImage?, soundURL: NSURL?, createMugSuccess: CreateMugSuccess, createMugFail: CreateMugFail) {
        let cacheHandler = CacheHandler.sharedInstance
        let mugService = MugService()
        
        mugService.createMug(word, backgroundImage: backgroundImage, soundPath: soundURL, createMugSuccessCallback: { (mug) -> Void in
            var userDataSource = UserDataSource()
            mug.owner = User.loggedUser()
            mug.setBackgroundContentType(BackgroundContentType.Image)
            
            // TODO: SAVE IMAGE AND AUDIO IN THE CACHE
            if (backgroundImage != nil) {
                cacheHandler.saveImage(backgroundImage!, withUrl: mug.backgroundURL, isTemporary: false)
            }
            
            if (soundURL != nil) {
                cacheHandler.saveDataAtPath(soundURL!.absoluteString!, withUrl: mug.soundURL, isTemporary: false)
            }
            
            createMugSuccess(mug)
        }) { (mugError) -> Void in
            var message = mugError?.error as String!
            createMugFail(message)
        }
    }
    
    func createMugWithWord(word: String, videoURL: NSURL, createMugSuccess: CreateMugSuccess, createMugFail: CreateMugFail) {
        let cacheHandler = CacheHandler.sharedInstance
        let mugService = MugService()
        
        mugService.createMug(word, videoPath: videoURL, isPrivate: true, createMugSuccessCallback: { (mug) -> Void in
            var userDataSource = UserDataSource()
            mug.owner = User.loggedUser()
            mug.setBackgroundContentType(BackgroundContentType.Video)
            
            // TODO: SAVE VIDEO IN THE CACHE
            cacheHandler.saveDataAtPath(videoURL.absoluteString!, withUrl: mug.backgroundURL, isTemporary: false)
            
            createMugSuccess(mug)
        }) { (mugError) -> Void in
            var message = mugError?.error as String!
            createMugFail(message)
        }
    }
    
    func createEmptyMugWithWord(word: String) -> Mug {
        var mug: Mug! = Mug.MR_createEntity() as Mug
        mug.word = word
        
        return mug
    }

    
    func retrieveMugWithId(id: String) -> Mug {
        var mug = self.getMugById(id)
        
        if (mug == nil) {
            println("Mug (\(id)) not found in the database and it mustn't happen. Check why it wasn't added to database yet.")
        }
        
        return mug!
    }
    
    func getMyMugs() -> [Mug] {
        return Mug.findAllSortedBy(MugAttributes.MUG_ID, ascending: true, withPredicate: NSPredicate(format: "(\(MugAttributes.MUG_OWNER).userID == \(AuthenticationHelper.sharedInstance.userInSession.userID))")) as [Mug]
    }
    
    func getMyMugsForWord(word: String) -> [Mug] {
        return Mug.findAllWithPredicate(NSPredicate(format: "((\(MugAttributes.MUG_OWNER).userID == \(AuthenticationHelper.sharedInstance.userInSession.userID)) and (\(MugAttributes.WORD) like[cd] %@))", word)) as [Mug]
    }
    
    func getMyMugsForWords(words: [String]) -> Dictionary<String, [Mug]> {
        var resultDictionary = Dictionary<String, [Mug]>()
        
        if (words.count == 0) {
            return resultDictionary
        }
        
        for word in words {
            resultDictionary[word] = Array<Mug>()
            
            // I didn't find a way to use a NSPredicate case-insensitive with an IN clause
            // I've tried in many diffent ways with NSPredicate or NSCompoundPredicate, but none of it worked and for some of it returned an weird error about a selector not found.
            // The error happened when I tried to use: NSPredicate(format: <#String#>, argumentArray: <#[AnyObject]?#>)
            // Error: swift predicate reason: '-[Swift._NSContiguousString countByEnumeratingWithState:objects:count:]: unrecognized selector
            var mugs = self.getMyMugsForWord(word)
            for mug in mugs {
                resultDictionary[word]?.append(mug)
            }
        }
        
        return resultDictionary
    }

    
    // MARK: - Private Getters Methods
    
    private func getMugById(id: String) -> Mug? {
        return Mug.findFirstByAttribute(MugAttributes.MUG_ID, withValue: id) as? Mug
    }
}