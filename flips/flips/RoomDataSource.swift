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

struct RoomJsonParams {
    static let NAME = "name"
    static let PUBNUB_ID = "pubnubId"
    static let ROOM_ID = "id"
    static let ADMIN_ID = "admin"
    static let PARTICIPANTS = "participants"
    static let CREATED_AT = "createdAt"
    static let UPDATED_AT = "updatedAt"
}

struct RoomAttributes {
    static let ROOM_ID = "roomID"
    static let LAST_MESSAGE_RECEIVED_AT = "lastMessageReceivedAt"
    static let PUBNUB_ID = "pubnubID"
}

class RoomDataSource : BaseDataSource {
    
    private let FLIPBOYS_USERNAME: String = "flipboys@flipsapp.com"
    
    
    // MARK: - Creators
    
    private func createEntityWithJson(json: JSON) -> Room {
        var entity: Room! = Room.createInContext(currentContext) as Room
        self.fillRoom(entity, withJson: json)
        
        return entity
    }
    
    private func fillRoom(room: Room, withJson json: JSON) {
        if (room.roomID != json[RoomJsonParams.ROOM_ID].stringValue) {
            println("Possible error. Will change romom id from (\(room.roomID)) to (\(json[RoomJsonParams.ROOM_ID].stringValue))")
        }
        
        room.name = json[RoomJsonParams.NAME].stringValue
        room.pubnubID = json[RoomJsonParams.PUBNUB_ID].stringValue
        room.roomID = json[RoomJsonParams.ROOM_ID].stringValue
    }
    
    func createRoomWithJson(json: JSON) -> Room {
        return self.createEntityWithJson(json)
    }
    
    func updateRoom(room: Room, withJson json: JSON) -> Room {
        var roomInContext = room.inContext(currentContext) as Room
        fillRoom(roomInContext, withJson: json)
        return roomInContext
    }
    
    func associateRoom(room: Room, withAdmin admin: User, andParticipants participants: [User]) {
        var roomInContext = room.inContext(currentContext) as Room

        for user in participants {
            roomInContext.addParticipantsObject(user.inContext(currentContext) as User)
        }

        roomInContext.admin = admin.inContext(currentContext) as User
    }
    
    
    // MARK: - Getters
    
    func retrieveRoomWithId(roomId: String) -> Room {
        var room = self.getRoomById(roomId)
        
        if (room == nil) {
            println("Room (\(roomId)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
        }
        
        return room!
    }
    
    func getRoomById(roomId: String) -> Room? {
        return Room.findFirstByAttribute(RoomAttributes.ROOM_ID, withValue: roomId, inContext: currentContext) as? Room
    }
    
    func getAllRooms() -> [Room] {
        return Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: true, inContext: currentContext) as [Room]
    }
    
    func getFlipboysRoom() -> Room? {
        var rooms = getAllRooms()
        for room in rooms {
            var allParticipants = room.participants.allObjects as [User]
            for participant in allParticipants {
                if (participant.username == FLIPBOYS_USERNAME) {
                    return room
                }
            }
        }
        
        return nil
    }
    
    func getMyRooms() -> [Room] {
        var rooms = Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: false, inContext: currentContext) as [Room]
        var roomsWithMessages = Array<Room>()
        for room in rooms {
            if (room.flipMessagesNotRemoved().count > 0) {
                roomsWithMessages.append(room)
            }
        }
        
        return roomsWithMessages
    }
    
    func getMyRoomsOrderedByOldestNotReadMessage() -> [Room] {
        let now = NSDate()
        
        var myRooms = self.getMyRooms()
        return myRooms.sorted { (room, nextRoom) -> Bool in
            let roomOldestMessage = room.oldestNotReadMessage()
            var roomDate = roomOldestMessage?.createdAt
            if (roomDate == nil) {
                roomDate = now
            }
            
            let nextRoomOldestMessage = nextRoom.oldestNotReadMessage()
            var nextRoomDate = nextRoomOldestMessage?.createdAt
            if (nextRoomDate == nil) {
                nextRoomDate = now
            }
            
            return (roomDate!.compare(nextRoomDate!) != NSComparisonResult.OrderedAscending)
        }
    }
    
    func getMyRoomsOrderedByMostRecentMessage() -> [Room] {
        let now = NSDate()
        
        var myRooms = self.getMyRooms()
        return myRooms.sorted { (room, nextRoom) -> Bool in
            let roomMostRecentMessage = room.flipMessagesNotRemoved().lastObject as? FlipMessage
            var roomDate = roomMostRecentMessage?.createdAt
            if (roomDate == nil) {
                roomDate = now
            }
            
            let nextRoomMostRecentMessage = nextRoom.flipMessagesNotRemoved().lastObject as? FlipMessage
            var nextRoomDate = nextRoomMostRecentMessage?.createdAt
            if (nextRoomDate == nil) {
                nextRoomDate = now
            }
            
            return (roomDate!.compare(nextRoomDate!) != NSComparisonResult.OrderedAscending)
        }
    }
    
    func getRoomWithPubnubID(pubnubID: String) -> Room? {
        return Room.findFirstByAttribute(RoomAttributes.PUBNUB_ID, withValue: pubnubID, inContext: currentContext) as? Room
    }
    
    func hasRoomWithUserId(userId: String) -> (hasRoom: Bool, room: Room?) {
        let rooms = self.getAllRooms()
        
        var roomFound: Room?
        for room in rooms {
            if (room.participants.count == 2) {
                var allParticipants = room.participants.allObjects as [User]
                if ((allParticipants[0].userID == userId) || (allParticipants[1].userID == userId)) {
                    roomFound = room
                    break
                }
            }
        }
        
        if (roomFound != nil) {
            return (true, roomFound)
        } else {
            return (false, nil)
        }
    }
}