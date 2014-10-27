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

private struct MugMessageJsonParams {
    static let FROM_USER_ID = "fromUserId"
    static let CONTENT = "content"
}

class MugMessageDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> MugMessage {
        let userDataSource = UserDataSource()
        
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage
        
        entity.from = userDataSource.retrieveUserWithId(json[MugMessageJsonParams.FROM_USER_ID].stringValue)
        entity.notRead = true
        entity.receivedAt = NSDate()

        let mugDataSource = MugDataSource()
        let content = json[MugMessageJsonParams.CONTENT]
        
        for (index: String, mugJson: JSON) in content {
            var mug = mugDataSource.createOrUpdateMugsWithJson(mugJson)
            entity.addMug(mug)
        }
        
        return entity
    }
    
    func createMugMessageWithJson(json: JSON, receivedAtChannel pubnubID: String, sentAt sentDate: NSDate) -> MugMessage {
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID)
        
        let mugMessage = self.createEntityWithJson(json)
        mugMessage.createdAt = sentDate
        mugMessage.room = room
        
        self.save()
        
        return mugMessage
    }
}