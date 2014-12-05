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

extension Room {
    
    func numberOfUnreadMessages() -> Int {
        var notReadMessagesCount = 0
        let flipMessagesNotRemoved = self.flipMessagesNotRemoved()
        for (var i = 0; i < flipMessagesNotRemoved.count; i++) {
            let flipMessage = flipMessagesNotRemoved[i] as FlipMessage
            
            if (flipMessage.notRead.boolValue) {
                notReadMessagesCount++
            }
        }
        
        return notReadMessagesCount
    }
    
    func lastMessageReceivedWithContent() -> FlipMessage? {
        var currentLastMessageWithContent = self.flipMessagesNotRemoved().lastObject as FlipMessage!
        
        while (!currentLastMessageWithContent.hasAllContentDownloaded()) {
            var currentIndex = self.flipMessages.indexOfObject(currentLastMessageWithContent)
            if (currentIndex == 0) {
                return nil
            }
            currentLastMessageWithContent = self.flipMessages[--currentIndex] as FlipMessage
        }

        return currentLastMessageWithContent
    }
    
    func oldestNotReadMessage() -> FlipMessage? {
        let flipMessageDataSource = FlipMessageDataSource()
        
        var oldestMessageNotRead = flipMessageDataSource.oldestNotReadFlipMessageForRoomId(self.roomID)
        
        if (oldestMessageNotRead == nil) {
            return self.flipMessagesNotRemoved().lastObject as? FlipMessage
        }
        
        return oldestMessageNotRead
    }
    
    func flipMessagesNotRemoved() -> NSOrderedSet {
        var notRemovedMessages = NSMutableOrderedSet()
        
        for (var i = 0; i < self.flipMessages.count; i++) {
            let flipMessage = self.flipMessages[i] as FlipMessage
            
            if (!flipMessage.removed.boolValue) {
                notRemovedMessages.addObject(flipMessage)
            }
        }
        
        return notRemovedMessages
    }
    
    func markAllMessagesAsRemoved(completion: CompletionBlock) {
        let flipMessageDataSource = FlipMessageDataSource()
        flipMessageDataSource.removeAllFlipMessagesFromRoomID(self.roomID, completion)
    }
    
    func roomName() -> String {
        var roomName = ""
        var comma = ""
        
        let nameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let phoneNumberDescriptor = NSSortDescriptor(key: "phoneNumber", ascending: true)
        var sortedParticipants = self.participants.sortedArrayUsingDescriptors([nameDescriptor, lastNameDescriptor, phoneNumberDescriptor])
        
        for participant in sortedParticipants {
            if (participant.userID != AuthenticationHelper.sharedInstance.userInSession.userID) {
                var userFirstName = participant.firstName
                if (participant.isTemporary!.boolValue) {
                    if let phoneNumber = participant.phoneNumber {
                        userFirstName = phoneNumber!
                    }
                    
                    if let contacts = participant.contacts {
                        if (contacts.count > 0) {
                            var contact = contacts.allObjects[0] as Contact
                            if (contact.firstName != "") {
                                userFirstName = contact.firstName
                            } else if (contact.lastName != "") {
                                userFirstName = contact.lastName
                            } else if (contact.phoneNumber != "") {
                                userFirstName = contact.phoneNumber
                            }
                        }
                    }
                }
                roomName = "\(roomName)\(comma)\(userFirstName)"
                comma = ", "
            }
        }
        return roomName
    }
}
