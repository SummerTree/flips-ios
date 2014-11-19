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

public class MessageService {
    
    public class var sharedInstance : MessageService {
        struct Static {
            static let instance : MessageService = MessageService()
        }
        return Static.instance
    }
    
    func sendMessage(flipIds: [String]!, toContacts contacts: [Contact], completion: CompletionBlock) {
        var room: Room!
        // TODO: create room in the server
        // self.sendMessage(flipIds, roomID: room.roomID, completion: completion)

        completion(false)
    }
    
    func sendMessage(flipIds: [String]!, roomID: String, completion: CompletionBlock) {
        let flipMessageDataSource = MugMessageDataSource()
        let flipDataSource = MugDataSource()
        let roomDataSource = RoomDataSource()
        
        var flips = Array<Mug>()
        for flipId in flipIds {
            var flip = flipDataSource.retrieveMugWithId(flipId)
            flips.append(flip)
        }
        
        let room = roomDataSource.retrieveRoomWithId(roomID)
        let flipMessage = flipMessageDataSource.createFlipMessageWithFlips(flips, toRoom: room)
        let messageJson = flipMessage.toJSON()
        
        PubNubService.sharedInstance.sendMessage(messageJson, pubnubID: room.pubnubID, completion: completion)
    }
}
