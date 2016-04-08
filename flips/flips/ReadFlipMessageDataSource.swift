//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

struct ReadFlipMessageJsonParams {
    static let FLIP_MESSAGE_ID = "flipMessageId"
}


class ReadFlipMessageDataSource: BaseDataSource {
    
    private let FLIP_MESSAGE_ID: String = "flipMessageID"

    func createReadFlipMessageWithID(flipMessageID: String) -> ReadFlipMessage {
        let entity = ReadFlipMessage.createInContext(currentContext) as! ReadFlipMessage
        entity.flipMessageID = flipMessageID

        return entity
    }
    
    func createReadFlipMessageWithJSON(json: JSON) -> ReadFlipMessage {
        let entity = ReadFlipMessage.createInContext(currentContext) as! ReadFlipMessage
        
        let flipMessageID: String = json[ReadFlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        entity.flipMessageID = flipMessageID

        return entity
    }
    
    func hasFlipMessageWithID(flipMessageID: String) -> Bool {
        if let _: ReadFlipMessage = ReadFlipMessage.findFirstByAttribute(FLIP_MESSAGE_ID, withValue: flipMessageID) as? ReadFlipMessage {
            return true
        }
        return false
    }
}
