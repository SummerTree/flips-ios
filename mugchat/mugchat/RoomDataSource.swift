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
    static let PUBNUB_ID = ""
    static let ROOM_ID = ""
    static let ADMIN_ID = ""
    static let PARTICIPANTS = ""
}

class RoomDataSource : BaseDataSource {
    
    private func createEntityWithJson(json: JSON) -> Room {
        let userDataSource = UserDataSource()
        
        var entity: Room! = Room.createEntity() as Room
        
        entity.name = json[RoomJsonParams.NAME].stringValue
        entity.pubnubID = json[RoomJsonParams.PUBNUB_ID].stringValue
        entity.roomID = json[RoomJsonParams.ROOM_ID].stringValue

        // TODO: need to check if the server is returning the admin info - maybe we don't have it in the database yet
        entity.admin = userDataSource.retrieveUserWithId(json[RoomJsonParams.ADMIN_ID].stringValue)
        
        var content = json[RoomJsonParams.PARTICIPANTS]
        for (index: String, json: JSON) in content {
            entity.addParticipantsObject(userDataSource.retrieveUserWithId(json["userID"].stringValue))
        }
        
        self.save()
        
        return entity
    }
    
    func createOrUpdateWithId(roomID: String, roomName: String, pubnubID: String, adminID: String, participantsIDs: [String]) {
        
    }
    
    func retriveRoomWithName(name: String) {
        // TODO:
    }
}