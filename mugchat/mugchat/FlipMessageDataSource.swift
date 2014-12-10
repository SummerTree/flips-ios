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

struct FlipMessageJsonParams {
    static let FLIP_MESSAGE_ID = "flipMessageId" // used to identify messages sent by the logged user that are from history or not. To do not duplicate it.
    static let FROM_USER_ID = "fromUserId"
    static let SENT_AT = "sentAt"
    static let CONTENT = "content"
}

private struct FlipMessageAttributes {
    static let FLIP_MESSAGE_ID = "flipMessageID"
    static let CREATED_AT = "createdAt"
    static let NOT_READ = "notRead"
    static let ROOM = "room"
    static let FROM = "from"
    static let REMOVED = "removed"
}

class FlipMessageDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> FlipMessage {
        let userDataSource = UserDataSource()

        let fromUserID = json[FlipMessageJsonParams.FROM_USER_ID].stringValue
        let flipMessageID = json[FlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        
        var entity: FlipMessage! = self.getFlipMessageById(flipMessageID)
        if (entity != nil) {
            return entity // if the user already has his message do not recreate
        }

        entity = FlipMessage.createEntity() as FlipMessage
        entity.flipMessageID = self.nextFlipMessageID()
        
        entity.from = userDataSource.retrieveUserWithId(fromUserID)
        entity.createdAt = NSDate(dateTimeString: json[FlipMessageJsonParams.SENT_AT].stringValue)
        entity.notRead = true
        entity.receivedAt = NSDate()

        let flipDataSource = FlipDataSource()
        let content = json[FlipMessageJsonParams.CONTENT]
        
        for (index: String, flipJson: JSON) in content {
            var flip = flipDataSource.createOrUpdateFlipsWithJson(flipJson)
            entity.addFlip(flip)
        }
        
        return entity
    }


    // TODO: Handle this message format that means: "You is invited to this new awesome room! Yay!"
    // {type : 1, content: {room_id : <ROOM_ID>, room_pubnubid : <PUBNUB_ID>}}


    private func isValidFlipMessage(json: JSON) -> Bool {
        if (json[FlipMessageJsonParams.FROM_USER_ID] == nil) {
            return false
        }

        if (json[FlipMessageJsonParams.SENT_AT] == nil) {
            return false
        }

        if (json[FlipMessageJsonParams.FLIP_MESSAGE_ID] == nil) {
            return false
        }

        let content = json[FlipMessageJsonParams.CONTENT]
        if (content == nil) {
            return false
        }

        return true
    }
    
    func createFlipMessageWithJson(json: JSON, receivedDate:NSDate, receivedAtChannel pubnubID: String) -> FlipMessage? {
        if (!self.isValidFlipMessage(json)) {
            println("Invalid message JSON")
            return nil
        }

        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID)

        if (room == nil) {
            println("Room with pubnubID (\(pubnubID)) not found - It cannot happen, because if user received a message, is because he is subscribed at a channel.")
        }

        let flipMessage = self.createEntityWithJson(json)
        flipMessage.room = room!

        // Only update room's lastMessageReceivedAt if earlier than this message's createdAt
        if (room!.lastMessageReceivedAt == nil || (room!.lastMessageReceivedAt.compare(receivedDate) == NSComparisonResult.OrderedAscending)) {
            flipMessage.room.lastMessageReceivedAt = receivedDate
        }
        
        self.save()
        
        return flipMessage
    }
    
    func createFlipMessageWithFlips(flips: [Flip], toRoom room: Room) -> FlipMessage {
        var entity: FlipMessage! = FlipMessage.createEntity() as FlipMessage
        
        entity.flipMessageID = self.nextFlipMessageID()
        entity.room = room
        entity.from = User.loggedUser()
        entity.createdAt = NSDate()
        entity.notRead = false
        entity.receivedAt = NSDate()
        for flip in flips {
            entity.addFlip(flip)
        }
        
        self.save()
        
        return entity
    }
    
    private func nextFlipMessageID() -> String {
        let loggedUser = User.loggedUser()
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        let newMessageId = "\(loggedUser?.userID):\(timestamp)"

        return newMessageId
    }
    
    func oldestNotReadFlipMessageForRoomId(roomID: String) -> FlipMessage? {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.NOT_READ) == true) AND (\(FlipMessageAttributes.REMOVED) == false))")
        var result = FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [FlipMessage]
        return result.first
    }
    
    func newestNotReadFlipMessageForRoomId(roomID: String) -> FlipMessage? {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.NOT_READ) == true) AND (\(FlipMessageAttributes.REMOVED) == false))")
        var result = FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [FlipMessage]
        return result.last
    }
    
    func removeAllFlipMessagesFromRoomID(roomID: String, completion: CompletionBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let roomDataSource = RoomDataSource()
            let roomAtContext = roomDataSource.retrieveRoomWithId(roomID)
            for (var i = 0; i < roomAtContext.flipMessages.count; i++) {
                let flipMessage = roomAtContext.flipMessages.objectAtIndex(i) as FlipMessage
                flipMessage.removed = true
            }
            self.save()

            completion(true)
        })
    }
    
    func flipMessagesForRoomID(roomID: String) -> [FlipMessage] {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.REMOVED) == false))")
        return FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate) as [FlipMessage]
    }
    
    private func getFlipMessageById(flipMessageID: String) -> FlipMessage? {
        return FlipMessage.findFirstByAttribute(FlipMessageAttributes.FLIP_MESSAGE_ID, withValue: flipMessageID) as? FlipMessage
    }
    
    func retrieveFlipMessageById(flipMessageID: String) -> FlipMessage {
        var flipMessage = self.getFlipMessageById(flipMessageID)
        
        if (flipMessage == nil) {
            println("FlipMessage with flipMessageID (\(flipMessage)) not found.")
        }
        
        return flipMessage!
    }
    
    func markFlipMessageAsRead(flipMessageId: String) {
        let flipMessage = self.retrieveFlipMessageById(flipMessageId)
        flipMessage.notRead = false
        self.save()
    }
}