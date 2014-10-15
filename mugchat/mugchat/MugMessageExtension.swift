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

private enum MessageParams {
    static let FROM = "from"
    static let CONTENT = "content"
}

extension MugMessage {
    
    class func createEntityWithJson(json: JSON) -> MugMessage {
        var entity: MugMessage! = self.createEntity() as MugMessage
        
        var senderId = json[MessageParams.FROM].stringValue
        var content = json[MessageParams.CONTENT]
        for (index: String, mug: JSON) in content {
            entity.addMugsObject(Mug.createEntityWithJson(mug))
        }
        
        entity.userFrom = UserDataSource().retrieveUserWithId(senderId)
        
        return entity
    }
    
    class func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
}