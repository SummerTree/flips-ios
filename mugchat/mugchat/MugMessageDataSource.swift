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
    static let SENT_AT = "sentAt"
    static let CONTENT = "content"
}

private struct MugMessageAttributes {
    static let CREATED_AT = "createdAt"
    static let NOT_READ = "notRead"
    static let ROOM = "room"
}

class MugMessageDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> MugMessage {
        let userDataSource = UserDataSource()
        
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage
        
        entity.from = userDataSource.retrieveUserWithId(json[MugMessageJsonParams.FROM_USER_ID].stringValue)
        entity.createdAt = NSDate(dateTimeString: json[MugMessageJsonParams.SENT_AT].stringValue)
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
    
    func createMugMessageWithJson(json: JSON, receivedAtChannel pubnubID: String) -> MugMessage {
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID)
        
        let mugMessage = self.createEntityWithJson(json)
        mugMessage.room = room
        room.lastMessageReceivedAt = mugMessage.createdAt
        
        self.save()
        
        return mugMessage
    }
    
    func oldestNotReadMugMessageForRoom(room: Room) -> MugMessage? {
        var predicate = NSPredicate(format: "((\(MugMessageAttributes.ROOM).roomID == \(room.roomID)) AND (\(MugMessageAttributes.NOT_READ) == true))")
        var result = MugMessage.MR_findAllSortedBy(MugMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [MugMessage]
        return result.first

    }
    
    func removeAllMugMessagesFromRoomID(roomID: String, completion: CompletionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let roomDataSource = RoomDataSource()
            let roomAtContext = roomDataSource.retrieveRoomWithId(roomID)
            for (var i = 0; i < roomAtContext.mugMessages.count; i++) {
                let mugMessage = roomAtContext.mugMessages.objectAtIndex(i) as MugMessage
                mugMessage.removed = true
            }
            self.save()

            completion(true)
        })
    }
}