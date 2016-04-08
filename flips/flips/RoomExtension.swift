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

extension Room {
    
    func numberOfUnreadMessages() -> Int {
        var notReadMessagesCount = 0
        let flipMessagesNotRemoved = self.flipMessagesNotRemoved()
        for i in 0 ..< flipMessagesNotRemoved.count {
            let flipMessage = flipMessagesNotRemoved[i] as! FlipMessage
            
            if (flipMessage.notRead.boolValue) {
                notReadMessagesCount += 1
            }
        }
        
        return notReadMessagesCount
    }
    
    func oldestNotReadMessage() -> FlipMessage? {
        let flipMessageDataSource = FlipMessageDataSource(context: self.managedObjectContext!)
        
        let oldestMessageNotRead = flipMessageDataSource.oldestNotReadFlipMessageForRoomId(self.roomID)
        
        if (oldestMessageNotRead == nil) {
            return self.flipMessagesNotRemoved().lastObject as? FlipMessage
        }
        
        return oldestMessageNotRead
    }
    
    func flipMessagesNotRemoved() -> NSOrderedSet {
        let notRemovedMessages = NSMutableOrderedSet()
        
        for i in 0 ..< self.flipMessages.count {
            if let flipMessage: FlipMessage = self.flipMessages[i] as? FlipMessage {
                if (!flipMessage.removed.boolValue) {
                    notRemovedMessages.addObject(flipMessage)
                }
            }
        }
        
        return notRemovedMessages
    }
    
    func notRemovedFlipMessagesOrderedByReceivedAt() -> [FlipMessage] {
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: FlipMessageAttributes.RECEIVED_AT, ascending: true)
        let orderedFlipMessage: [AnyObject] = self.flipMessagesNotRemoved().sortedArrayUsingDescriptors([sortDescriptor])
        return orderedFlipMessage as! [FlipMessage]
    }
    
    func markAllMessagesAsRemoved(completion: CompletionBlock) {
        PersistentManager.sharedInstance.removeAllFlipMessagesFromRoomID(self.roomID, completion: completion)
    }
    
    func roomName() -> String {
        var roomName = ""
        var comma = ""
        
        let nameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let phoneNumberDescriptor = NSSortDescriptor(key: "phoneNumber", ascending: true)
        
        
        //change names vars
        let entries: NSMutableArray = NSMutableArray()
        if let testeEntries = self.participants as? Set<User> {
            for entrie: User in testeEntries {
                entries.addObject(entrie)
            }
        }

        let sortedParticipants = entries.sortedArrayUsingDescriptors([nameDescriptor, lastNameDescriptor, phoneNumberDescriptor])
        
        for participant: User in sortedParticipants as! [User] {
            if let loggedUser = User.loggedUser() {
                if (participant.userID != loggedUser.userID) {
                    var userFirstName = participant.firstName
                    if (participant.isTemporary!.boolValue) {
                        if (participant.phoneNumber) != nil {
                            userFirstName = participant.formattedPhoneNumber()
                        }
                        
                        if let contacts = Array(participant.contacts) as? [Contact] {
                            if (contacts.count > 0) {
                                var contact: Contact = contacts[0]
                                
                                for userContact: Contact in contacts {
                                    if (!hasTemporaryName(userContact.firstName)) {
                                        contact = userContact as Contact
                                    }
                                }
                                
                                if (hasTemporaryName(contact.firstName)) {
                                    userFirstName = contact.formattedPhoneNumber()
                                } else if (contact.firstName != "") {
                                    userFirstName = contact.firstName
                                } else if (contact.lastName != "") {
                                    userFirstName = contact.lastName
                                } else if (contact.formattedPhoneNumber() != "") {
                                    userFirstName = contact.formattedPhoneNumber()
                                }
                            }
                        }
                    }
                    roomName = "\(roomName)\(comma)\(userFirstName)"
                    comma = ", "
                }                
            }
        }
        return roomName
    }
    
    private func hasTemporaryName(firstName: String) -> Bool {
        return isValidUUID(firstName)
    }
    
    private func isValidUUID(uuidString: String) -> Bool {
        let uuid = NSUUID(UUIDString: uuidString)
        return uuid != nil
    }
}
