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

public class Mug {
    
    var id: String!
    var word: String!
    var backgroundURL: String!
    var soundURL: String?
    var owner: User?
    var isPrivate: Bool?
    var category: String?
    
    init(json: JSON) {
        self.id = json[JsonParams.ID].stringValue
        self.word = json[JsonParams.WORD].stringValue
        self.backgroundURL = json[JsonParams.BACKGROUND_URL].stringValue
        self.soundURL = json[JsonParams.SOUND_URL].stringValue
    }
    
}

private struct JsonParams {
    static let ID = "id"
    static let WORD = "word"
    static let BACKGROUND_URL = "backgroundURL"
    static let SOUND_URL = "soundURL"
}
