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
    static let OWNER = "owner"
    static let IS_PRIVATE = "isPrivate"
    static let THUMBNAIL_URL = "thumbnailURL"
}

struct FlipAttributes {
    static let FLIP_ID = "flipID"
    static let FLIP_OWNER = "owner"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let IS_PRIVATE = "isPrivate"
}

public typealias CreateFlipSuccess = (Flip) -> Void
public typealias CreateFlipFail = (FlipError) -> Void

class FlipDataSource : BaseDataSource {
    
    private let EMPTY_FLIP_ID = "-1"
    
    private func createEntityWithJson(json: JSON) -> Flip {
        var entity: Flip!
        entity = Flip.createInContext(currentContext) as Flip
        self.fillFlip(entity, withJsonData: json)
        
        return entity
    }
    
    private func fillFlip(flip: Flip, withJsonData json: JSON) {
        if (flip.flipID != json[FlipJsonParams.ID].stringValue) {
            println("Possible error. Will update flip id from (\(flip.flipID)) to (\(json[FlipJsonParams.ID].stringValue))")
        }

        flip.flipID = json[FlipJsonParams.ID].stringValue
        flip.word = json[FlipJsonParams.WORD].stringValue
        flip.backgroundURL = json[FlipJsonParams.BACKGROUND_URL].stringValue
        flip.thumbnailURL = json[FlipJsonParams.THUMBNAIL_URL].stringValue
        flip.isPrivate = json[FlipJsonParams.IS_PRIVATE].boolValue
    }
    

    // MARK: - Public Methods
    
    func createFlipWithJson(json: JSON) -> Flip {
        return self.createEntityWithJson(json)
    }
    
    func updateFlip(flip: Flip, withJson json: JSON) -> Flip {
        var flipInContext = flip.inContext(currentContext) as Flip
        self.fillFlip(flipInContext, withJsonData: json)
        return flipInContext
    }
    
    func associateFlip(flip: Flip, withOwner owner: User) {
        var flipInContext = flip.inContext(currentContext) as Flip
        var ownerInContext = owner.inContext(currentContext) as User
        flipInContext.owner = ownerInContext
    }
    
    // This flip is never uploaded to the server. It is used only via Pubnub
    func createEmptyFlipWithWord(word: String) -> Flip {
        var flip: Flip! = Flip.MR_createEntity() as Flip
        flip.word = word
        return flip
    }

    func retrieveFlipWithId(id: String) -> Flip! {
        return self.getFlipById(id)
    }
    
    func getFlipById(id: String) -> Flip? {
        return Flip.findFirstByAttribute(FlipAttributes.FLIP_ID, withValue: id) as Flip?
    }

    func getMyFlips() -> [Flip] {
        return Flip.findAllSortedBy(FlipAttributes.FLIP_ID,
            ascending: true,
            withPredicate: NSPredicate(format: "(\(FlipAttributes.FLIP_OWNER).userID == \(User.loggedUser()!.userID))"),
            inContext: currentContext) as [Flip]
    }
    
    func getMyFlipsForWord(word: String) -> [Flip] {
        let predicate = NSPredicate(format: "((\(FlipAttributes.FLIP_OWNER).userID == \(User.loggedUser()!.userID)) and (\(FlipAttributes.WORD) ==[cd] %@) and (\(FlipAttributes.BACKGROUND_URL)  MATCHES '.{1,}'))", word)
        
        return Flip.findAllSortedBy(FlipAttributes.FLIP_ID, ascending: false, withPredicate: predicate, inContext: currentContext) as [Flip]
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
        let predicate = NSPredicate(format: "((\(FlipAttributes.IS_PRIVATE) == false) and (\(FlipAttributes.WORD) ==[cd] %@) and (\(FlipAttributes.BACKGROUND_URL)  MATCHES '.{1,}'))", word)
        return Flip.findAllSortedBy(FlipAttributes.FLIP_ID, ascending: false, withPredicate: predicate, inContext: currentContext) as [Flip]
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
}