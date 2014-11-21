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

struct MugMessageJsonParams {
    static let FLIP_MESSAGE_ID = "flipMessageId" // used to identify messages sent by the logged user that are from history or not. To do not duplicate it.
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

        let fromUserID = json[MugMessageJsonParams.FROM_USER_ID].stringValue
        let flipMessageID = json[MugMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        
        var entity: MugMessage! = self.getFlipMessageById(flipMessageID)
        if (entity != nil) {
            return entity // if the user already has his message do not recreate
        }

        entity = MugMessage.createEntity() as MugMessage
        entity.mugMessageID = self.nextMugMessageID()
        
        entity.from = userDataSource.retrieveUserWithId(fromUserID)
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

        if (json[MugMessageJsonParams.FLIP_MESSAGE_ID] == nil) {
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
    
    func createFlipMessageWithFlips(flips: [Mug], toRoom room: Room) -> MugMessage {
        var entity: MugMessage! = MugMessage.createEntity() as MugMessage
        
        entity.mugMessageID = self.nextMugMessageID()
        entity.room = room
        entity.from = User.loggedUser()
        entity.createdAt = NSDate()
        entity.notRead = false
        entity.receivedAt = NSDate()
        for flip in flips {
            entity.addMug(flip)
        }
        
        self.save()
        
        return entity
    }
    
    private func nextMugMessageID() -> String {
        let loggedUser = User.loggedUser()
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        let newMessageId = "\(loggedUser?.userID):\(timestamp)"

        return newMessageId
    }
    
    func oldestNotReadMugMessageForRoomId(roomID: String) -> MugMessage? {
        var predicate = NSPredicate(format: "((\(MugMessageAttributes.ROOM).roomID == \(roomID)) AND (\(MugMessageAttributes.NOT_READ) == true) AND (\(MugMessageAttributes.REMOVED) == false))")
        var result = MugMessage.MR_findAllSortedBy(MugMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [MugMessage]
        return result.first
    }
    
    func newestNotReadMugMessageForRoomId(roomID: String) -> MugMessage? {
        var predicate = NSPredicate(format: "((\(MugMessageAttributes.ROOM).roomID == \(roomID)) AND (\(MugMessageAttributes.NOT_READ) == true) AND (\(MugMessageAttributes.REMOVED) == false))")
        var result = MugMessage.MR_findAllSortedBy(MugMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [MugMessage]
        return result.last
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
    
    private func getFlipMessageById(flipMessageID: String) -> MugMessage? {
        return MugMessage.findFirstByAttribute(MugMessageAttributes.MUG_MESSAGE_ID, withValue: flipMessageID) as? MugMessage
    }
    
    func retrieveFlipMessageById(flipMessageID: String) -> MugMessage {
        var flipMessage = self.getFlipMessageById(flipMessageID)
        
        if (flipMessage == nil) {
            println("FlipMessage with flipMessageID (\(flipMessage)) not found.")
        }
        
        return flipMessage!
    }
}