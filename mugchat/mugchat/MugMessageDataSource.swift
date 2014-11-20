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
    static let MUG_MESSAGE_ID = "mugMessageID"
    static let CREATED_AT = "createdAt"
    static let NOT_READ = "notRead"
    static let ROOM = "room"
    static let FROM = "from"
    static let REMOVED = "removed"
}

class MugMessageDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> MugMessage {
        let userDataSource = UserDataSource()
        
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage

        entity.mugMessageID = self.nextMugMessageID()
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


    // TODO: Handle this message format that means: "You is invited to this new awesome room! Yay!"
    // {type : 1, content: {room_id : <ROOM_ID>, room_pubnubid : <PUBNUB_ID>}}


    private func isValidFlipMessage(json: JSON) -> Bool {
        if (json[MugMessageJsonParams.FROM_USER_ID] == nil) {
            return false
        }

        if (json[MugMessageJsonParams.SENT_AT] == nil) {
            return false
        }

        let content = json[MugMessageJsonParams.CONTENT]
        if (content == nil) {
            return false
        }

        return true
    }
    
    func createMugMessageWithJson(json: JSON, receivedDate:NSDate, receivedAtChannel pubnubID: String) -> MugMessage? {
        if (!self.isValidFlipMessage(json)) {
            println("Invalid message JSON")
            return nil
        }

        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID)

        if (room == nil) {
            // FIXME: This can actually happen if receiving a message from user's personal channel. There's no local room for that.
            println("Room with pubnubID (\(pubnubID)) not found - It cannot happen, because if user received a message, is because he is subscribed at a channel.")
        }

        let mugMessage = self.createEntityWithJson(json)
        mugMessage.room = room!

        // Only update room's lastMessageReceivedAt if earlier than this message's createdAt
        if (room!.lastMessageReceivedAt == nil || (room!.lastMessageReceivedAt.compare(receivedDate) == NSComparisonResult.OrderedAscending)) {
            mugMessage.room.lastMessageReceivedAt = receivedDate
        }
        
        self.save()
        
        return mugMessage
    }
    
    func saveTemporaryMugMessage(mugMessageToSave: MugMessage) {
        let userDataSource = UserDataSource()
        let mugDataSource = MugDataSource()
        
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage
        
        entity.mugMessageID = mugMessageToSave.mugMessageID
        entity.from = userDataSource.retrieveUserWithId(mugMessageToSave.from.userID)
        entity.createdAt = NSDate()
        entity.notRead = false
        entity.receivedAt = NSDate()
        
        let mugs = NSMutableOrderedSet()
        for (var i = 0; i < mugMessageToSave.mugs.count; i++) {
            var mug = mugMessageToSave.mugs.objectAtIndex(i) as Mug
            mugs.addObject(mugDataSource.retrieveMugWithId(mug.mugID))
        }
        entity.mugs = mugs
 
        self.save()
    }
    
    private func nextMugMessageID() -> Int {
        let mugMessages = MugMessage.MR_findAllSortedBy(MugMessageAttributes.MUG_MESSAGE_ID, ascending: false)
        
        if (mugMessages.first == nil) {
            return 0
        }
        
        var nextID = Int(mugMessages.first!.mugMessageID)
        return ++nextID
    }
    
    func oldestNotReadMugMessageForRoom(room: Room) -> MugMessage? {
        var predicate = NSPredicate(format: "((\(MugMessageAttributes.ROOM).roomID == \(room.roomID)) AND (\(MugMessageAttributes.NOT_READ) == true) AND (\(MugMessageAttributes.REMOVED) == false) AND (\(MugMessageAttributes.FROM).userID != \(AuthenticationHelper.sharedInstance.userInSession.userID)))")
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
    
    func flipMessagesForRoomID(roomID: String) -> [MugMessage] {
        var predicate = NSPredicate(format: "((\(MugMessageAttributes.ROOM).roomID == \(roomID)) AND (\(MugMessageAttributes.REMOVED) == false))")
        return MugMessage.MR_findAllSortedBy(MugMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [MugMessage]
    }
    
    func retrieveFlipMessageById(flipMessageID: String) -> MugMessage {
        var flipMessage = MugMessage.findFirstByAttribute(MugMessageAttributes.MUG_MESSAGE_ID, withValue: flipMessageID) as? MugMessage
        
        if (flipMessage == nil) {
            println("FlipMessage with flipMessageID (\(flipMessage)) not found.")
        }
        
        return flipMessage!
    }
}