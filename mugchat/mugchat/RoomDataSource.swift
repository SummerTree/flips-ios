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

private struct RoomJsonParams {
    static let NAME = "name"
    static let PUBNUB_ID = "pubnubId"
    static let ROOM_ID = "roomId"
    static let ADMIN_ID = "adminId"
    static let PARTICIPANTS = "participants" // TODO: not defined yet
}

struct RoomAttributes {
    static let ROOM_ID = "roomID"
    static let LAST_MESSAGE_RECEIVED_AT = "lastMessageReceivedAt"
    static let PUBNUB_ID = "pubnubID"
}

class RoomDataSource : BaseDataSource {
    
    // MARK: - Creators
    
    private func createEntityWithJson(json: JSON) -> Room {
        var entity: Room! = Room.createEntity() as Room
        self.fillRoom(entity, withJson: json)
        
        return entity
    }
    
    private func fillRoom(room: Room, withJson json: JSON) {
        let userDataSource = UserDataSource()
        
        room.name = json[RoomJsonParams.NAME].stringValue
        room.pubnubID = json[RoomJsonParams.PUBNUB_ID].stringValue
        room.roomID = json[RoomJsonParams.ROOM_ID].stringValue
        room.admin = userDataSource.retrieveUserWithId(json[RoomJsonParams.ADMIN_ID].stringValue)
        
        var content = json[RoomJsonParams.PARTICIPANTS]
        for (index: String, json: JSON) in content {
            // ONLY USERS CAN PARTICIPATE IN A ROOM
            var user = userDataSource.createOrUpdateUserWithJson(json)
            room.addParticipantsObject(user)
        }
    }
    
    func createOrUpdateWithJson(json: JSON) {
        let roomID = json[RoomJsonParams.ROOM_ID].stringValue
        var room = self.getRoomById(roomID)
        
        if (room == nil) {
            room = self.createEntityWithJson(json)
        } else {
            self.fillRoom(room!, withJson: json)
        }
        
        self.save()
    }
    
    
    // MARK: - Getters
    
    func retrieveRoomWithId(roomId: String) -> Room {
        var room = self.getRoomById(roomId)
        
        if (room == nil) {
            println("Room (\(roomId)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
        }
        
        return room!
    }
    
    func getAllRooms() -> [Room] {
        return Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: true) as [Room]
    }
    
    func getMyRooms() -> [Room] {
        var rooms = Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: false) as [Room]
        var roomsWithMessages = Array<Room>()
        for room in rooms {
            if (room.mugMessagesNotRemoved().count > 0) {
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
    
    func getRoomWithPubnubID(pubnubID: String) -> Room {
        var room = Room.findFirstByAttribute(RoomAttributes.PUBNUB_ID, withValue: pubnubID) as? Room
        
        if (room == nil) {
            println("Room with pubnubID (\(pubnubID)) not found - It cannot happen, because if user received a message, is because he is subscribed at a channel.")
        }
        
        return room!
    }
    
    
    // MARK: - Private Getters
    
    private func getRoomById(roomId: String) -> Room? {
        return Room.findFirstByAttribute(RoomAttributes.ROOM_ID, withValue: roomId) as? Room
    }
}