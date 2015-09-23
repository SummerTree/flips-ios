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

struct DeletedFlipMessageJsonParams {
    static let FLIP_MESSAGE_ID = "flipMessageID"
}

class DeletedFlipMessageDataSource: BaseDataSource {

    private let FLIP_MESSAGE_ID: String = "flipMessageID"
    
    func createDeletedFlipMessageWithID(flipMessageID: String) -> DeletedFlipMessage {
        let entity = DeletedFlipMessage.createInContext(currentContext) as! DeletedFlipMessage
        entity.flipMessageID = flipMessageID
        
        return entity
    }
    
    func createDeletedFlipMessageWithJSON(json: JSON) -> DeletedFlipMessage {
        let entity = DeletedFlipMessage.createInContext(currentContext) as! DeletedFlipMessage
        
        let flipMessageID: String = json[DeletedFlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        entity.flipMessageID = flipMessageID
        
        return entity
    }
    
    func hasFlipMessageWithID(flipMessageID: String) -> Bool {
        if let readFlipMessage: DeletedFlipMessage = DeletedFlipMessage.findFirstByAttribute(FLIP_MESSAGE_ID, withValue: flipMessageID) as? DeletedFlipMessage {
            return true
        }
        return false
    }

}
