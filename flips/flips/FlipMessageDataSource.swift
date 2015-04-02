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
        
        var entity = FlipMessage.createInContext(currentContext) as FlipMessage
        entity.flipMessageID = flipMessageID
        entity.createdAt = NSDate(dateTimeString: json[FlipMessageJsonParams.SENT_AT].stringValue)
        entity.receivedAt = receivedDate
        entity.notRead = true
        
        return entity
    }

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

        let content = json[MESSAGE_CONTENT]
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

        return self.createEntityWithJson(json, andReceivedDate: receivedDate)
    }
    
    func associateFlipMessage(flipMessage: FlipMessage, withUser user: User, formattedFlips: [FormattedFlip], andRoom room: Room) {
        let flipMessageInContext = flipMessage.inContext(currentContext) as FlipMessage
        let userInContext = user.inContext(currentContext) as User
        
        flipMessageInContext.from = userInContext
        
        if let loggedUser = User.loggedUser() {
            if (flipMessageInContext.from.userID == loggedUser.userID) {
                flipMessageInContext.notRead = false
            }
        }

        for formattedFlip in formattedFlips {
            flipMessageInContext.addFlip(formattedFlip, inContext: currentContext)
        }
        
        let roomInContext = room.inContext(currentContext) as Room
        flipMessageInContext.room = roomInContext
        if ((roomInContext.lastMessageReceivedAt == nil) ||
            (room.lastMessageReceivedAt.compare(flipMessageInContext.receivedAt) == NSComparisonResult.OrderedAscending)) {
            flipMessage.room.lastMessageReceivedAt = flipMessageInContext.receivedAt
        }
    }
    
    func createFlipMessageWithId(flipMessageID: String, andFormattedFlips formattedFlips: [FormattedFlip], toRoom room: Room) -> FlipMessage {
        var entity = FlipMessage.createInContext(currentContext) as FlipMessage
        entity.flipMessageID = flipMessageID
        entity.room = room.inContext(currentContext) as Room
        entity.from = User.loggedUser()?.inContext(currentContext) as User
        entity.createdAt = NSDate()
        entity.notRead = false
        entity.receivedAt = NSDate()
        for formattedFlip in formattedFlips {
            entity.addFlip(formattedFlip, inContext: currentContext)
        }
        
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
        let deletedFlipMessageDataSource: DeletedFlipMessageDataSource = DeletedFlipMessageDataSource(context: currentContext)
        
        let roomDataSource = RoomDataSource(context: currentContext)
        let room = roomDataSource.retrieveRoomWithId(roomID)
        for (var i = 0; i < room.flipMessages.count; i++) {
            let flipMessage = room.flipMessages.objectAtIndex(i).inContext(currentContext) as FlipMessage
            flipMessage.removed = true
            
            let flipMessageID: String = flipMessage.flipMessageID
            if (!deletedFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)) {
                let deletedFlipMessage: DeletedFlipMessage = deletedFlipMessageDataSource.createDeletedFlipMessageWithID(flipMessageID)
                self.sendMessageForDeletedFlipMessage(deletedFlipMessage)
            }
        }
    }
    
    func markFlipMessageAsRemoved(flipMessage: FlipMessage) {
        let flipMessageInContext: FlipMessage = flipMessage.inContext(currentContext) as FlipMessage
        flipMessageInContext.removed = true
        
        let deletedFlipMessageDataSource: DeletedFlipMessageDataSource = DeletedFlipMessageDataSource(context: currentContext)
        let flipMessageID: String = flipMessageInContext.flipMessageID
        if (!deletedFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)) {
            let deletedFlipMessage: DeletedFlipMessage = deletedFlipMessageDataSource.createDeletedFlipMessageWithID(flipMessageID)
            self.sendMessageForDeletedFlipMessage(deletedFlipMessage)
        }
    }
    
    private func sendMessageForDeletedFlipMessage(deletedFlipMessage: DeletedFlipMessage) {
        if let loggedUser: User = User.loggedUser() {
            let deletedFlipMessageJson = deletedFlipMessage.toJSON()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                PubNubService.sharedInstance.sendMessage(deletedFlipMessageJson, pubnubID: loggedUser.pubnubID, completion: nil)
            })
        }
    }
    
    func flipMessagesForRoomID(roomID: String) -> [FlipMessage] {
        var predicate = NSPredicate(format: "((\(FlipMessageAttributes.ROOM).roomID == \(roomID)) AND (\(FlipMessageAttributes.REMOVED) == false))")
        return FlipMessage.MR_findAllSortedBy(FlipMessageAttributes.CREATED_AT, ascending: true, withPredicate: predicate, inContext: currentContext) as [FlipMessage]
    }
    
    func getFlipMessageById(flipMessageID: String) -> FlipMessage? {
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