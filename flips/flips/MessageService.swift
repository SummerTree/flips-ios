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

public typealias SendMessageCompletion = (Bool, String?, FlipError?) -> Void

public class MessageService {
    
    public class var sharedInstance : MessageService {
        struct Static {
            static let instance : MessageService = MessageService()
        }
        return Static.instance
    }
    
    func sendMessage(flipWords: [FlipText], toContacts contactIds: [String], completion: SendMessageCompletion) {
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
        
        self.sendMessage(flipWords, roomID: roomInContext.roomID, completion: completion)
    }
    
    func sendMessage(flipWords: [FlipText], roomID: String, completion: SendMessageCompletion) {
        QueueHelper.dispatchAsyncWithNewContext { (newContext) -> Void in
            let flipDataSource = FlipDataSource(context: newContext)
            let roomDataSource = RoomDataSource(context: newContext)
            
            var formattedFlips = Array<FormattedFlip>()
            for flipWord in flipWords {
                if let flipId: String = flipWord.associatedFlipId {
                    if let flip = flipDataSource.retrieveFlipWithId(flipId) {
                        var formattedFlip: FormattedFlip = FormattedFlip(flip: flip, word: flipWord.text)
                        formattedFlips.append(formattedFlip)
                    }
                }
            }
            
            let room = roomDataSource.retrieveRoomWithId(roomID)
            let newFlipMessage = PersistentManager.sharedInstance.createFlipMessageWithFlips(formattedFlips, toRoom: room)
            let flipMessage = newFlipMessage.inContext(newContext) as FlipMessage
            let messageJson = flipMessage.toJsonUsingFlipWords(flipWords)
            
            PubNubService.sharedInstance.sendMessage(messageJson, pubnubID: room.pubnubID) { (success) -> Void in
                if (!success) {
                    QueueHelper.dispatchAsyncWithNewContext { (newContext) -> Void in
                        var flipMessageInNewContext: FlipMessage = flipMessage.inContext(newContext) as FlipMessage

                        // We need to mark as removed the FlipMessage that wasn't sent.
                        PersistentManager.sharedInstance.markFlipMessageAsRemoved(flipMessageInNewContext, completion: { (result) -> Void in
                            completion(success, roomID, nil)
                        })
                    }
                } else {
                    completion(success, roomID, nil)
                }
            }
        }
    }
}
