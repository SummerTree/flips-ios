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

class MugDataSource : BaseDataSource {
    
    func createEntityWithJson(json: JSON) -> Mug {
        var entity: Mug! = Mug.createEntity() as Mug
        
        entity.mugID = json[MugJsonParams.ID].stringValue
        entity.word = json[MugJsonParams.WORD].stringValue
        entity.backgroundURL = json[MugJsonParams.BACKGROUND_URL].stringValue
        entity.soundURL = json[MugJsonParams.SOUND_URL].stringValue
        
        self.save()
        
        return entity
    }
}