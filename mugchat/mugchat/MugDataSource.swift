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
}

let MUG_ID_ATTRIBUTE = "mugID"

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
    
    func retrieveMugWithId(id: String) -> Mug {
        var mug = self.getMugById(id)
        
        if (mug == nil) {
            println("Mug (\(id)) not found in the database and it mustn't happen. Check why it wasn't added to database yet.")
        }
        
        return mug!
    }

    
    // MARK: - Private Getters Methods
    
    private func getMugById(id: String) -> Mug? {
        return Mug.findFirstByAttribute(MUG_ID_ATTRIBUTE, withValue: id) as? Mug
    }
}