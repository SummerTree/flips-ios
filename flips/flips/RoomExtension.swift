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
    
    func numberOfUnreadMessages(inContext context: NSManagedObjectContext? = NSManagedObjectContext.MR_defaultContext()) -> Int {
        var notReadMessagesCount = 0
        let flipMessagesNotRemoved = self.flipMessagesNotRemoved(inContext: context)
        for (var i = 0; i < flipMessagesNotRemoved.count; i++) {
            let flipMessage = flipMessagesNotRemoved[i] as FlipMessage
            
            if (flipMessage.notRead.boolValue) {
                notReadMessagesCount++
            }
        }
        
        return notReadMessagesCount
    }
    
    func oldestNotReadMessage(inContext context: NSManagedObjectContext) -> FlipMessage? {
        let flipMessageDataSource = FlipMessageDataSource()
        
        var oldestMessageNotRead = flipMessageDataSource.oldestNotReadFlipMessageForRoomId(self.roomID)
        
        if (oldestMessageNotRead == nil) {
            return self.flipMessagesNotRemoved(inContext: context).lastObject as? FlipMessage
        }
        
        return oldestMessageNotRead
    }
    
    func flipMessagesNotRemoved(inContext context: NSManagedObjectContext? = NSManagedObjectContext.MR_defaultContext()) -> NSOrderedSet {
        var notRemovedMessages = NSMutableOrderedSet()
        
        // http://stackoverflow.com/questions/6139989/core-data-nsoperation-crash-while-enumerating-through-and-deleting-objects
        var messages: NSOrderedSet = NSOrderedSet(orderedSet: self.flipMessages) //, copyItems: true
        
        for (var i = 0; i < messages.count; i++) {
            if let flipMessage: FlipMessage = messages[i].inContext(context) as? FlipMessage {
                if (!flipMessage.removed.boolValue) {
                    notRemovedMessages.addObject(flipMessage)
                }
            }
        }
        
        return notRemovedMessages
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
        var sortedParticipants = self.participants.sortedArrayUsingDescriptors([nameDescriptor, lastNameDescriptor, phoneNumberDescriptor])
        
        for participant in sortedParticipants {
            if let loggedUser = User.loggedUser() {
                if (participant.userID != loggedUser.userID) {
                    var userFirstName = participant.firstName
                    if (participant.isTemporary!.boolValue) {
                        if let phoneNumber = participant.phoneNumber {
                            userFirstName = (participant as User).formattedPhoneNumber()
                        }
                        
                        if let contacts = participant.contacts {
                            if (contacts.count > 0) {
                                var contact: Contact = contacts.allObjects[0] as Contact
                                
                                for userContact in contacts.allObjects {
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
