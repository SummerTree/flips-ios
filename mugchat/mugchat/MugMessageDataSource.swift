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

private let FROM = "from"
private let USER_ID = "userID"
private let TO = "to"
private let ROOM_ID = "roomID"
private let CONTENT = "content"

class MugMessageDataSource : BaseDataSource {
    
    func createEntityWithJson(json: JSON) -> MugMessage {
        let userDataSource = UserDataSource()
        
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage
        
        entity.from = userDataSource.retrieveUserWithId(json[FROM].stringValue)
//        entity.from = User.createEntityWithId(json[FROM].stringValue)
        
        // TODO:
        //        var mugs = [Mug]()
        //        var sender = json[MessageParams.SENDER].stringValue
        //        var content = json[MessageParams.CONTENT]
        //        for (index: String, mug: JSON) in content {
        //            mugs.append(Mug.createEntityWithJson(mug))
        //        }
        //
        //        self.sender = sender
        //        self.mugs = mugs
        
        self.save()
        
        return entity
    }
}