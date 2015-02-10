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
    
    private func createEntityWithJson(json: JSON, andReceivedDate receivedDate: NSDate) -> FlipMessage {
        let userDataSource = UserDataSource(context: currentContext)

        let fromUserID = json[FlipMessageJsonParams.FROM_USER_ID].stringValue
        let flipMessageID = json[FlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        
        var entity: FlipMessage! = self.getFlipMessageById(flipMessageID)
        if (entity != nil) {
            return entity // if the user already has his message do not recreate
        }

        entity = FlipMessage.createInContext(currentContext) as FlipMessage
        entity.flipMessageID = flipMessageID
        
//        entity.from = userDataSource.retrieveUserWithId(fromUserID)
        entity.createdAt = NSDate(dateTimeString: json[FlipMessageJsonParams.SENT_AT].stringValue)
        entity.receivedAt = receivedDate
        entity.notRead = true
        
//        let flipDataSource = FlipDataSource(context: currentContext)
//        let content = json[FlipMessageJsonParams.CONTENT]
//        
//        for (index: String, flipJson: JSON) in content {
//            var flip = flipDataSource.createOrUpdateFlipWithJson(flipJson)
//            entity.addFlip(flip, inContext: currentContext)
//        }
        
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
    
    func createFlipMessageWithJson(json: JSON, receivedDate:NSDate) -> FlipMessage? {
        if (!self.isValidFlipMessage(json)) {
            println("Invalid message JSON")
            return nil
        }

//        let roomDataSource = RoomDataSource(context: currentContext)
//        let room = roomDataSource.getRoomWithPubnubID(pubnubID) as Room!
        
        let flipMessage = self.createEntityWithJson(json, andReceivedDate: receivedDate)
//        flipMessage.room = room
        
        // Only update room's lastMessageReceivedAt if earlier than this message's createdAt
//        if (room.lastMessageReceivedAt == nil || (room.lastMessageReceivedAt.compare(receivedDate) == NSComparisonResult.OrderedAscending)) {
//            flipMessage.room.lastMessageReceivedAt = receivedDate
//        }
        
//        self.save()
        
        return flipMessage
    }
    
    func associateFlipMessage(flipMessage: FlipMessage, withUser user: User, flips: [Flip], andRoom room: Room) {
        let flipMessageInContext = flipMessage.inContext(currentContext) as FlipMessage
        let userInContext = user.inContext(currentContext) as User
        
        flipMessageInContext.from = userInContext
        
        if let loggedUser = AuthenticationHelper.sharedInstance.userInSession {
            if (flipMessageInContext.from.userID == loggedUser.userID) {
                flipMessageInContext.notRead = false
            }
        }

        for flip in flips {
            let flipInContext = flip.inContext(currentContext) as Flip
            flipMessageInContext.addFlip(flip, inContext: currentContext)
        }
        
        let roomInContext = room.inContext(currentContext) as Room
        flipMessageInContext.room = roomInContext
        if ((roomInContext.lastMessageReceivedAt == nil) ||
            (room.lastMessageReceivedAt.compare(flipMessageInContext.receivedAt) == NSComparisonResult.OrderedAscending)) {
            flipMessage.room.lastMessageReceivedAt = flipMessageInContext.receivedAt
        }
    }
    
    func createFlipMessageWithId(flipMessageID: String, andFlips flips: [Flip], toRoom room: Room) -> FlipMessage {
        var entity = FlipMessage.createInContext(currentContext) as FlipMessage
        entity.flipMessageID = flipMessageID
        entity.room = room
        entity.from = User.loggedUser()!.inContext(currentContext) as User
        entity.createdAt = NSDate()
        entity.notRead = false
        entity.receivedAt = NSDate()
        for flip in flips {
            entity.addFlip(flip.inContext(currentContext) as Flip, inContext: currentContext)
        }
        
//        self.save()
        return entity
    }
    
    func nextFlipMessageID() -> String {
        let loggedUser = User.loggedUser()?.inContext(currentContext) as User!
        let timestamp = NSDate.timeIntervalSinceReferenceDate()
        let newMessageId = "\(loggedUser!.userID):\(timestamp)"

        return newMessageId
    }
    
    func oldestNotReadFlipMessageForRoomId(roomID: String) -> FlipMessage? {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.NOT_READ) == true) AND (\(FlipMessageAttributes.REMOVED) == false))")
        var result = FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate, inContext: currentContext) as [FlipMessage]
        return result.first
    }
    
    func newestNotReadFlipMessageForRoomId(roomID: String) -> FlipMessage? {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.NOT_READ) == true) AND (\(FlipMessageAttributes.REMOVED) == false))")
        var result = FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate, inContext: currentContext) as [FlipMessage]
        return result.last
    }
    
    func removeAllFlipMessagesFromRoomID(roomID: String) {
        let roomDataSource = RoomDataSource(context: currentContext)
        let room = roomDataSource.retrieveRoomWithId(roomID)
        for (var i = 0; i < room.flipMessages.count; i++) {
            let flipMessage = room.flipMessages.objectAtIndex(i) as FlipMessage
            flipMessage.removed = true
        }
//        }, completionBlock: completion)
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//            self.save()

//            completion(true)
//        })
    }
    
    func flipMessagesForRoomID(roomID: String) -> [FlipMessage] {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.REMOVED) == false))")
        return FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate, inContext: currentContext) as [FlipMessage]
    }
    
    private func getFlipMessageById(flipMessageID: String) -> FlipMessage? {
        return FlipMessage.findFirstByAttribute(FlipMessageAttributes.FLIP_MESSAGE_ID, withValue: flipMessageID, inContext: currentContext) as? FlipMessage
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
    }
}