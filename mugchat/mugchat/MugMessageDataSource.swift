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
        let loggedUser = User.loggedUser()
        
        var entity: MugMessage!
        if (json[MugMessageJsonParams.FLIP_MESSAGE_ID] != nil) { // JUST TO AVOID CRASHES WHILE OTHER PEOPLE ARE SENDING OLD FORMAT MESSAGES VIA WEBSITE.
            let flipMessageID = json[MugMessageJsonParams.FLIP_MESSAGE_ID].stringValue
            
            if (fromUserID == loggedUser?.userID!) {
                entity = self.getFlipMessageById(flipMessageID)
                if (entity != nil) {
                    return entity // if the user already has his message do not recreate
                }
            }
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
    
    func createMugMessageWithJson(json: JSON, receivedAtChannel pubnubID: String) -> MugMessage {
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID)
        
        let mugMessage = self.createEntityWithJson(json)
        mugMessage.room = room
        room.lastMessageReceivedAt = mugMessage.createdAt
        
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