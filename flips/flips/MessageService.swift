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

public typealias SendMessageCompletion = (Bool, String?, FlipError?) -> Void

public class MessageService {
    
    public class var sharedInstance : MessageService {
        struct Static {
            static let instance : MessageService = MessageService()
        }
        return Static.instance
    }
    
    func sendMessage(flipIds: [String]!, toContacts contactIds: [String], completion: SendMessageCompletion) {
        let roomService = RoomService()

        var userIds = Array<String>()
        var contactNumbers = Array<String>()
        
        let contactDataSource = ContactDataSource()
        for contactId in contactIds {
            let contact = contactDataSource.retrieveContactWithId(contactId)
            if let user = contact.contactUser {
                userIds.append(user.userID)
            } else {
                contactNumbers.append(PhoneNumberHelper.cleanFormattedPhoneNumber(contact.phoneNumber))
            }
        }
        
        var room: Room!
        var error: FlipError?
        
        var group = dispatch_group_create()
        dispatch_group_enter(group)
        roomService.createRoom(userIds, contactNumbers: contactNumbers, successCompletion: { (newRoom) -> Void in
            room = newRoom
            dispatch_group_leave(group);
        }) { (flipError) -> Void in
            error = flipError
            dispatch_group_leave(group);
        }

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        
        if (error != nil) {
            completion(false, nil, error)
            return
        }
        
        let roomInContext = room.inContext(NSManagedObjectContext.MR_defaultContext()) as Room
        PubNubService.sharedInstance.subscribeToChannelID(roomInContext.pubnubID)
        
        self.sendMessage(flipIds, roomID: roomInContext.roomID, completion: completion)
    }
    
    func sendMessage(flipIds: [String]!, roomID: String, completion: SendMessageCompletion) {
        let flipDataSource = FlipDataSource()
        let roomDataSource = RoomDataSource()
        
        var flips = Array<Flip>()
        for flipId in flipIds {
            if let flip = flipDataSource.retrieveFlipWithId(flipId) {
                flips.append(flip)
            }
        }
        
        let room = roomDataSource.retrieveRoomWithId(roomID)
        let flipMessage = PersistentManager.sharedInstance.createFlipMessageWithFlips(flips, toRoom: room)
        let messageJson = flipMessage.toJSON()
        
        PubNubService.sharedInstance.sendMessage(messageJson, pubnubID: room.pubnubID) { (success) -> Void in
            completion(success, roomID, nil)
        }
    }
}
