//
// Copyright 2015 ArcTouch, Inc.
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

let TEAMFLIPS_USERNAME: String = "teamflips@flipsapp.com"

class RoomDataSource : BaseDataSource {
    
    // MARK: - Creators
    
    private func createEntityWithJson(json: JSON) -> Room {
        let entity: Room! = Room.createInContext(currentContext) as! Room
        self.fillRoom(entity, withJson: json)
        
        return entity
    }
    
    private func fillRoom(room: Room, withJson json: JSON) {
        if (room.roomID != json[RoomJsonParams.ROOM_ID].stringValue) {
            print("Possible error. Will change room id from (\(room.roomID)) to (\(json[RoomJsonParams.ROOM_ID].stringValue))")
        }
        
        room.name = json[RoomJsonParams.NAME].stringValue
        room.pubnubID = json[RoomJsonParams.PUBNUB_ID].stringValue
        room.roomID = json[RoomJsonParams.ROOM_ID].stringValue
    }
    
    func createRoomWithJson(json: JSON) -> Room {
        return self.createEntityWithJson(json)
    }
    
    func associateRoom(room: Room, withAdmin admin: User?, andParticipants participants: [User]) {
        let roomInContext = room.inContext(currentContext) as! Room

        for user in participants {
            roomInContext.addParticipantsObject(user.inContext(currentContext) as! User)
        }

        if (admin != nil) {
            roomInContext.admin = admin!.inContext(currentContext) as! User
        }
    }
    
    
    // MARK: - Getters
    
    func retrieveRoomWithId(roomId: String) -> Room {
        let room = self.getRoomById(roomId)
        
        if (room == nil) {
            print("Room (\(roomId)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
        }
        
        return room!
    }
    
    func getRoomById(roomId: String) -> Room? {
        return Room.findFirstByAttribute(RoomAttributes.ROOM_ID, withValue: roomId, inContext: currentContext) as? Room
    }
    
    func getAllRooms() -> [Room] {
        return Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: true, inContext: currentContext) as! [Room]
    }
    
    func getTeamFlipsRoom() -> Room? {
        let rooms = getAllRooms()
        for room in rooms {
            let allParticipants = Array(room.participants)
            for participant : User in allParticipants as! [User] {
                if (participant.username == TEAMFLIPS_USERNAME) {
                    return room
                }
            }
        }
        
        return nil
    }
    
    func getMyRoomsWithMessages() -> [Room] {
        let rooms = Room.findAllSortedBy(RoomAttributes.LAST_MESSAGE_RECEIVED_AT, ascending: false, inContext: currentContext) as! [Room]
        var roomsWithMessages = Array<Room>()
        for room in rooms {
            let roomFlipMessages: [FlipMessage] = room.flipMessages.array as! [FlipMessage]
            for flipMessage : FlipMessage in roomFlipMessages {
                if (!flipMessage.removed.boolValue) {
                    roomsWithMessages.append(room)
                    break
                }
            }
        }
        
        return roomsWithMessages
    }
    
    func getMyRoomsOrderedByOldestNotReadMessage() -> [Room] {
        let now = NSDate()
        
        let myRooms = self.getMyRoomsWithMessages()
        return myRooms.sort { (room, nextRoom) -> Bool in
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
        
        let myRooms = self.getMyRoomsWithMessages()
        return myRooms.sort { (room, nextRoom) -> Bool in
            let roomMostRecentMessage = room.flipMessagesNotRemoved().lastObject as? FlipMessage
            var roomDate = roomMostRecentMessage?.receivedAt
            if (roomDate == nil) {
                roomDate = now
            }
            
            let nextRoomMostRecentMessage = nextRoom.flipMessagesNotRemoved().lastObject as? FlipMessage
            var nextRoomDate = nextRoomMostRecentMessage?.receivedAt
            if (nextRoomDate == nil) {
                nextRoomDate = now
            }
            
            return (roomDate!.compare(nextRoomDate!) != NSComparisonResult.OrderedAscending)
        }
    }
    
    func getRoomWithPubnubID(pubnubID: String) -> Room? {
        return Room.findFirstByAttribute(RoomAttributes.PUBNUB_ID, withValue: pubnubID, inContext: currentContext) as? Room
    }
    
    func hasRoomWithUserIDs(userIDs: [String]) -> (hasRoom: Bool, room: Room?) {
        let rooms = self.getAllRooms()
        let loggedUserID: String? = User.loggedUser()?.userID
        
        var roomFound: Room? = nil
        for room in rooms {

            let allParticipants = Array(room.participants) as! [User]

            if (allParticipants.count != userIDs.count+1) {
                continue
            }
            
            var sameParticipants = true
            for participant: User in allParticipants as [User] {
                if (userIDs.indexOf(participant.userID) == nil && participant.userID != loggedUserID) {
                    sameParticipants = false
                    break
                }
            }
            
            if (sameParticipants) {
                roomFound = room
                break
            }
        }
        
        if (roomFound != nil) {
            return (true, roomFound)
        } else {
            return (false, nil)
        }
    }
}