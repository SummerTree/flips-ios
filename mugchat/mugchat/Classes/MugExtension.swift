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

private struct JsonParams {
    static let ID = "id"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let SOUND_URL = "soundURL"
}

extension Mug {

    class func createEntityWithJson(json: JSON) -> Mug {
        var entity: Mug! = self.createEntity() as Mug
        entity.mugID = json[JsonParams.ID].stringValue
        entity.word = json[JsonParams.WORD].stringValue
        entity.backgroundURL = json[JsonParams.BACKGROUND_URL].stringValue
        entity.soundURL = json[JsonParams.SOUND_URL].stringValue
        
        return entity
    }
    
    class func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
}
