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

public typealias CreateFlipSuccessCompletion = (Flip) -> Void
public typealias CreateFlipFailureCompletion = (FlipError?) -> Void

@objc public class PersistentManager: NSObject {
    
    private let LAST_STOCK_FLIPS_SYNC_AT = "lastStockFlipsUpdatedAt"
    private let STOCK_FLIPS = "stock_flips"
    private let STOCK_FLIPS_LAST_TIMESTAMP = "last_timestamp"
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : PersistentManager {
        struct Static {
            static let instance : PersistentManager = PersistentManager()
        }
        return Static.instance
    }
    
    
    // MARK: - Room Methods
    
    func createOrUpdateRoomWithJson(json: JSON) -> Room {
        let roomDataSource = RoomDataSource()
        let roomID = json[RoomJsonParams.ROOM_ID].stringValue
        var room = roomDataSource.getRoomById(roomID)
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let roomDataSourceInContext = RoomDataSource(context: context)
            var roomInContext: Room
            if (room == nil) {
                roomInContext = roomDataSourceInContext.createRoomWithJson(json)
            } else {
                roomInContext = roomDataSourceInContext.updateRoom(room!, withJson: json)
            }
            
            room = roomInContext
        }
        
        var content = json[RoomJsonParams.PARTICIPANTS]
        var participants = Array<User>()
        for (index: String, json: JSON) in content {
            // ONLY USERS CAN PARTICIPATE IN A ROOM
            participants.append(self.createOrUpdateUserWithJson(json))
        }
        
        let userDataSource = UserDataSource()
        var admin = userDataSource.getUserById(json[RoomJsonParams.ADMIN_ID].stringValue)
        if (admin == nil) {
            println("An error happened. Room's admin doesn't exists in database. He should be created with the others participants.")
        }
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let roomDataSourceInContext = RoomDataSource(context: context)
            roomDataSourceInContext.associateRoom(room!, withAdmin: admin!, andParticipants: participants)
        }
        
        return room!
    }
    
    
    // MARK: - Flip Methods
    
    func createOrUpdateFlipWithJsonAsync(json: JSON) {
        let flipDataSource = FlipDataSource()
        let flipID = json[FlipJsonParams.ID].stringValue
        var flip = flipDataSource.getFlipById(flipID)
        
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
            let flipDataSourceInContext = FlipDataSource(context: context)
            if (flip == nil) {
                if (!flipDataSourceInContext.isFlipToBeDeleted(json)) {
                    flip = flipDataSourceInContext.createFlipWithJson(json)
                }
            } else {
                flip = flipDataSourceInContext.updateFlip(flip!.inContext(context) as Flip, withJson: json)
            }
        }, completion: { (success, error) -> Void in
            if (success) {
                if (flip != nil) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                        self.associateFlip(flip!, withOwnerInJson: json)
                    })
                }
            }
        })
    }
    
    private func associateFlip(flip: Flip, withOwnerInJson json: JSON) {
        let ownerJson = json[FlipJsonParams.OWNER]
        // if response JSON contains owner data (owner is populated)
        var flipOwnerID = ownerJson[FlipJsonParams.ID].stringValue
        if (flipOwnerID.isEmpty) {
            // owner is not populated, it contains only owner ID
            flipOwnerID = ownerJson.stringValue
        }
        
        var owner: User?
        if (!flipOwnerID.isEmpty) {
            let userDataSource = UserDataSource()
            owner = userDataSource.getUserById(flipOwnerID)
        }
        
        if (owner != nil) {
            MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
                let flipDataSourceInContext = FlipDataSource(context: context)
                flipDataSourceInContext.associateFlip(flip, withOwner: owner!)
            }
        }
    }
    
    func createOrUpdateFlipWithJson(json: JSON) -> Flip {
        let flipDataSource = FlipDataSource()
        let flipID = json[FlipJsonParams.ID].stringValue
        var flip = flipDataSource.getFlipById(flipID)
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let flipDataSourceInContext = FlipDataSource(context: context)
            if (flip == nil) {
                flip = flipDataSourceInContext.createFlipWithJson(json)
            } else {
                flip = flipDataSourceInContext.updateFlip(flip!.inContext(context) as Flip, withJson: json)
            }
        }
        
        self.associateFlip(flip!, withOwnerInJson: json)
        
        return NSManagedObjectContext.MR_defaultContext().existingObjectWithID(flip!.objectID, error: nil) as Flip
    }

    func createAndUploadFlip(word: String, videoURL: NSURL?, thumbnailURL: NSURL?, category: String = "", isPrivate: Bool = true, createFlipSuccessCompletion: CreateFlipSuccessCompletion, createFlipFailCompletion: CreateFlipFailureCompletion) {
        if let loggedUser = User.loggedUser() {
            let flipService = FlipService()
            flipService.createFlip(word, videoURL: videoURL, thumbnailURL: thumbnailURL, category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: { (json: JSON) -> Void in
                var flip: Flip!
                
                MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
                    let flipDataSource = FlipDataSource(context: context)
                    flip = flipDataSource.createFlipWithJson(json)
                    flipDataSource.associateFlip(flip, withOwner: loggedUser)
                })
                
                var flipInContext = flip.inContext(NSManagedObjectContext.MR_defaultContext()) as Flip
                
                if (videoURL != nil) {
                    FlipsCache.sharedInstance.put(NSURL(string: flipInContext.backgroundURL)!, localPath: videoURL!.path!)
                }
                
                if (thumbnailURL != nil) {
                    ThumbnailsCache.sharedInstance.put(NSURL(string: flipInContext.thumbnailURL)!, localPath: thumbnailURL!.path!)
                }
                
                createFlipSuccessCompletion(flipInContext)
                }) { (flipError: FlipError?) -> Void in
                    createFlipFailCompletion(flipError)
            }
        }
    }
    

    // MARK: - FlipMessage Methods
    
    func createFlipMessageWithJson(json: JSON, receivedDate:NSDate, receivedAtChannel pubnubID: String) -> FlipMessage? {
        var flipMessage: FlipMessage?
        
        let userDataSource = UserDataSource()
        let fromUserID = json[FlipMessageJsonParams.FROM_USER_ID].stringValue
        let user = userDataSource.getUserById(fromUserID)
        
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID) as Room!
        
        let content = json[MESSAGE_CONTENT]

        var formattedFlips: [FormattedFlip] = Array<FormattedFlip>()
        for (index: String, flipJson: JSON) in content {
            let flip = self.createOrUpdateFlipWithJson(flipJson)
            
            var formattedFlip: FormattedFlip = FormattedFlip(flip: flip, word: flipJson[FlipJsonParams.WORD].stringValue)
            formattedFlips.append(formattedFlip)
        }
        
        let flipMessageID = json[FlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        let deletedFlipMessageDataSource: DeletedFlipMessageDataSource = DeletedFlipMessageDataSource()
        let isMessageDeleted: Bool = deletedFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)
        
        // Shouldn't add a message if it already was removed.
        if (!isMessageDeleted) {
            let readFlipMessageDataSource: ReadFlipMessageDataSource = ReadFlipMessageDataSource()
            let isMessageMarkedAsRead: Bool = readFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)
            
            let flipMessageDataSource = FlipMessageDataSource()
            var entity: FlipMessage! = flipMessageDataSource.getFlipMessageById(flipMessageID)
            if (entity != nil) {
                return entity // if the user already has his message do not recreate
            }
            
            MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
                let flipMessageDataSourceInContext = FlipMessageDataSource(context: context)
                flipMessage = flipMessageDataSourceInContext.createFlipMessageWithJson(json, receivedDate: receivedDate)
                
                if (isMessageMarkedAsRead) {
                    flipMessage?.notRead = false
                }
                
                flipMessageDataSourceInContext.associateFlipMessage(flipMessage!, withUser: user!, formattedFlips: formattedFlips, andRoom: room)
            }
            return flipMessage
        }
        
        return nil
    }
    
    func createFlipMessageWithFlips(formattedFlips: [FormattedFlip], toRoom room: Room) -> FlipMessage {
        var flipMessage: FlipMessage!
        
        let flipMessageDataSource = FlipMessageDataSource()
        let messageId = flipMessageDataSource.nextFlipMessageID()
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSourceInContext = FlipMessageDataSource(context: context)
            flipMessage = flipMessageDataSourceInContext.createFlipMessageWithId(messageId, andFormattedFlips: formattedFlips, toRoom: room)
        }
        return flipMessage.inContext(NSManagedObjectContext.MR_defaultContext()) as FlipMessage
    }
    
    func removeAllFlipMessagesFromRoomID(roomID: String, completion: CompletionBlock) {
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessageDataSource.removeAllFlipMessagesFromRoomID(roomID)
        }, completion: { (success, error) -> Void in
            completion(success)
        })
    }
    
    func markFlipMessageAsRemoved(flipMessage: FlipMessage, completion: CompletionBlock) {
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessageDataSource.markFlipMessageAsRemoved(flipMessage)
        }, completion: { (success, error) -> Void in
            completion(success)
        })
    }
    
    func markFlipMessageAsRead(flipMessageId: String) {
        let readFlipMessageDataSource: ReadFlipMessageDataSource = ReadFlipMessageDataSource()
        let hasFlipMessagedMarkedAsRead = readFlipMessageDataSource.hasFlipMessageWithID(flipMessageId)
        
        var readFlipMessageJSON: Dictionary<String, AnyObject>? = nil
        
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessageDataSource.markFlipMessageAsRead(flipMessageId)
            
            if (!hasFlipMessagedMarkedAsRead) {
                let readFlipMessageDataSourceInContext: ReadFlipMessageDataSource = ReadFlipMessageDataSource(context: context)
                let readFlipMessage = readFlipMessageDataSourceInContext.createReadFlipMessageWithID(flipMessageId)
                readFlipMessageJSON = readFlipMessage.toJSON()
            }
        }, completion: { (success: Bool, error: NSError!) -> Void in
            if (success) {
                if (readFlipMessageJSON != nil) {
                    if let loggedUser: User = User.loggedUser() {
                        PubNubService.sharedInstance.sendMessage(readFlipMessageJSON!, pubnubID: loggedUser.pubnubID, completion: nil)
                    }
                } else {
                    println("Error: readFlipMessageJSON is nil")
                }
            } else {
                println("Marking message(\(flipMessageId) as read failed with error - \(error))")
            }
        })
    }
    
    // MARK: - ReadFlipMessage Method
    
    func onMarkFlipMessageAsReadReceivedWithJson(json: JSON) -> FlipMessage? {
        let flipMessageID: String = json[ReadFlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue

        let readFlipMessageDataSource: ReadFlipMessageDataSource = ReadFlipMessageDataSource()
        let hasFlipMessagedMarkedAsRead = readFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)

        var updatedFlipMessage: FlipMessage? = nil
        if (!hasFlipMessagedMarkedAsRead) {
            MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
                let readFlipMessageDataSourceInContext: ReadFlipMessageDataSource = ReadFlipMessageDataSource(context: context)
                readFlipMessageDataSourceInContext.createReadFlipMessageWithJSON(json)
                
                let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource(context: context)
                if let flipMessage: FlipMessage = flipMessageDataSource.getFlipMessageById(flipMessageID) {
                    flipMessage.notRead = false
                    updatedFlipMessage = flipMessage
                }
            })
        }
        
        return updatedFlipMessage
    }
    
    
    // MARK: - DeletedFlipMessage Method
    
    func onMessageForDeletedFlipMessageReceivedWithJson(json: JSON) -> FlipMessage? {
        let flipMessageID: String = json[DeletedFlipMessageJsonParams.FLIP_MESSAGE_ID].stringValue
        
        let deletedFlipMessageDataSource: DeletedFlipMessageDataSource = DeletedFlipMessageDataSource()
        let hasDeletedFlipMessage = deletedFlipMessageDataSource.hasFlipMessageWithID(flipMessageID)
        
        var updatedFlipMessage: FlipMessage? = nil
        if (!hasDeletedFlipMessage) {
            MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
                let deletedFlipMessageDataSourceInContext: DeletedFlipMessageDataSource = DeletedFlipMessageDataSource(context: context)
                deletedFlipMessageDataSourceInContext.createDeletedFlipMessageWithJSON(json)
                
                let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource(context: context)
                if let flipMessage: FlipMessage = flipMessageDataSource.getFlipMessageById(flipMessageID) {
                    flipMessage.removed = true
                    updatedFlipMessage = flipMessage
                }
            })
        }
        
        return updatedFlipMessage
    }
    
    // MARK: - User Methods
    
    func createOrUpdateUserWithJson(json: JSON, isLoggedUser: Bool = false) -> User {
        let userID = json[UserJsonParams.ID].stringValue
        
        let userDataSource = UserDataSource()
        var user = userDataSource.getUserById(userID)
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let userDataSourceInContext = UserDataSource(context: context)
            var userInContext: User
            if (user == nil) {
                userInContext = userDataSourceInContext.createUserWithJson(json, isLoggedUser: isLoggedUser)
            } else {
                userInContext = userDataSourceInContext.updateUser(user!, withJson: json, isLoggedUser: isLoggedUser)
            }
            
            userDataSourceInContext.associateUser(userInContext, withDeviceInJson: json)
            user = userInContext
        }
        
        if (!isLoggedUser) {
            let contactDataSource = ContactDataSource()
            var userInContext = user!.inThreadContext() as User
            
            let contactsWithSamePhoneNumber: [Contact] = contactDataSource.retrieveContactsWithPhoneNumber(userInContext.phoneNumber)
            
            if (contactsWithSamePhoneNumber.count > 0) {
                self.associateUser(userInContext, withContacts: contactsWithSamePhoneNumber)
            } else {
                if (!userInContext.isTemporary.boolValue) { // Do not create a contact for temporary users.
                    if let authenticatedId = User.loggedUser()?.userID {
                        var userContact: Contact?
                        
                        if (authenticatedId != userInContext.userID) {
                            var facebookID = user!.facebookID
                            var phonetype = (facebookID != nil) ? facebookID : ""
                            userContact = self.createOrUpdateContactWith(userInContext.firstName, lastName: userInContext.lastName, phoneNumber: userInContext.phoneNumber, phoneType: phonetype!, andContactUser: userInContext)
                        }
                    }
                }
            }
        }
        
        return NSManagedObjectContext.MR_defaultContext().existingObjectWithID(user!.objectID, error: nil) as User
    }
    
    func defineAsLoggedUser(user: User) {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            var userInContext = user.inContext(context) as User
            userInContext.me = true
            AuthenticationHelper.sharedInstance.onLogin(userInContext)
        }
    }
    
    func defineAsLoggedUserSync(user: User) {
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            var userInContext = user.inContext(context) as User
            userInContext.me = true
            AuthenticationHelper.sharedInstance.onLogin(userInContext)
        }
    }
    
    private func associateUser(user: User, withContacts contacts:[Contact]) {
        MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
            let userInContext: User = user.inContext(context) as User
            for contact in contacts {
                let contactInContext = contact.inContext(context) as Contact
                userInContext.addContactsObject(contactInContext)
                contactInContext.contactUser = userInContext
            }
        })
    }
    
    func syncUserData(callback:(Bool, FlipError?, UserDataSource) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let userService = UserService()
            let flipDataSource = FlipDataSource()
            
            var error: FlipError?
            var myFlips = Array<Flip>()
            
            let userDataSource = UserDataSource()
            
            let group = dispatch_group_create()
            
            dispatch_group_enter(group)
            println("getMyFlips")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                userService.getMyFlips({ (jsonResponse) -> Void in
                    println("   getMyFlips - success")
                    let myFlipsAsJSON = jsonResponse.array
                    
                    for myFlipJson in myFlipsAsJSON! {
                        let flip = self.createOrUpdateFlipWithJson(myFlipJson)
                        myFlips.append(flip)
                    }
                    
                    userDataSource.downloadMyFlips(myFlips)
                    
                    dispatch_group_leave(group)
                }, failCompletion: { (flipError) -> Void in
                    println("   getMyFlips - fail")
                    error = flipError
                    dispatch_group_leave(group)
                })
            })
            
            let roomService = RoomService()
            println("getMyRooms")
            dispatch_group_enter(group)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                roomService.getMyRooms({ (rooms) -> Void in
                    println("   getMyRooms - success")
                    PubNubService.sharedInstance.subscribeOnMyChannels()
                    dispatch_group_leave(group)
                }, failCompletion: { (flipError) -> Void in
                    println("   getMyRooms - fail")
                    error = flipError
                    dispatch_group_leave(group)
                })
            })
            
            var builderService = BuilderService()
            dispatch_group_enter(group)
            println("getSuggestedWords")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                builderService.getSuggestedWords({ (words) -> Void in
                    println("   getSuggestedWords - success")

                    let flipDataSource = FlipDataSource()
                    let myFlips = flipDataSource.getMyFlipsIdsForWords(words)
                    var newWords = [String]()

                    for word in words {
                        if (myFlips[word]?.count == 0) {
                            newWords.append(word)
                        }
                    }

                    // Only add the words that doesn't have flips associated
                    self.addBuilderWords(newWords, fromServer: true)
                    dispatch_group_leave(group)
                }, failCompletion: { (flipError) -> Void in
                    println("   getSuggestedWords - fail")
                    error = flipError
                    dispatch_group_leave(group)
                })
            })
            
            // sync stock flips
            let flipService = FlipService()
            let timestamp = NSUserDefaults.standardUserDefaults().valueForKey(self.LAST_STOCK_FLIPS_SYNC_AT) as NSDate?
            dispatch_group_enter(group)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                flipService.stockFlips(timestamp,
                    success: { (responseAsJSON) -> Void in
                        let stockFlipsAsJSON = responseAsJSON?[self.STOCK_FLIPS].array
                        for stockFlipJson in stockFlipsAsJSON! {
                            PersistentManager.sharedInstance.createOrUpdateFlipWithJsonAsync(stockFlipJson)
                        }
                        if let json = responseAsJSON {
                            let lastTimestampAsString = json[self.STOCK_FLIPS_LAST_TIMESTAMP].stringValue
                            if (lastTimestampAsString != "") {
                                AuthenticationHelper.sharedInstance.saveLastTimestampForStockFlip(NSDate(dateTimeString: lastTimestampAsString))
                            }
                        }
                        dispatch_group_leave(group)
                    },
                    failure: { (flipError) -> Void in
                        if (flipError != nil) {
                            println("Error \(flipError)")
                        }
                        error = flipError
                        dispatch_group_leave(group)
                    }
                )
            })
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            if (error != nil) {
                println("sync fail\n")
                callback(false, error, userDataSource)
                return
            }
            
            dispatch_sync(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(USER_DATA_SYNCED_NOTIFICATION_NAME, object: nil, userInfo: nil)
            })
            
            callback(true, nil, userDataSource)
        })
    }
    
    
    // MARK: - Contact Methods

    func createOrUpdateContacts(contacts: Array<ContactListHelperContact>, user: User? = nil) {
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let contactDataSource = ContactDataSource(context: context)

            var contactID = contactDataSource.nextContactID()

            for (var i = 0; i < contacts.count; i++) {
                let contact: ContactListHelperContact = contacts[i] as ContactListHelperContact
                let existingContact = contactDataSource.fetchContactByPhoneNumber(contact.phoneNumber)

                if (existingContact == nil) {
                    contactDataSource.createContactWith(String(contactID),
                        firstName: contact.firstName, lastName: contact.lastName, phoneNumber: contact.phoneNumber,
                        phoneType: contact.phoneType, andContactUser: user)

                    contactID++

                } else {
                    contactDataSource.updateContact(existingContact!, withFirstName: contact.firstName,
                        lastName: contact.lastName, phoneNumber: contact.phoneNumber, phoneType: contact.phoneType)
                }
            }
        }
    }

    func createOrUpdateContactWith(firstName: String, lastName: String?, phoneNumber: String, phoneType: String, andContactUser contactUser: User? = nil) -> Contact {
        let contactDataSource = ContactDataSource()
        var contact = contactDataSource.findContactBy(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        let contactID = String(contactDataSource.nextContactID())
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let contactDataSourceInContext = ContactDataSource(context: context)
            var contactInContext: Contact!
            if (contact == nil) {
                contactInContext = contactDataSourceInContext.createContactWith(contactID, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType, andContactUser: contactUser)
            } else {
                contactInContext = contactDataSourceInContext.updateContact(contact?.inContext(context) as Contact, withFirstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
            }
            
            contact = contactInContext
        }
        
        return contact!
    }
    
    
    // MARK: - Device Methods
    
    func createDeviceWithJson(json: JSON) -> Device {
        var device: Device!
        
        let userDataSource = UserDataSource()
        let user = userDataSource.getUserById(json[DeviceJsonParams.USER].stringValue)
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let deviceDataSource = DeviceDataSource(context: context)
            device = deviceDataSource.createEntityWithJson(json)
            
            deviceDataSource.associateDevice(device, withUser: user!)
        }
        return device.inContext(NSManagedObjectContext.MR_defaultContext()) as Device
    }
    
    
    // MARK: - Builder Word Methods
    
    func cleanBuilderWordsFromServer() {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            var builderWordDataSource = BuilderWordDataSource(context: context)
            builderWordDataSource.cleanWordsFromServer()
        }
    }
    
    func addBuilderWords(words: [String], fromServer: Bool) {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            var builderWordDataSource = BuilderWordDataSource(context: context)
            builderWordDataSource.addWords(words, fromServer: fromServer)
        }
    }
    
    func addBuilderWord(word: String, fromServer: Bool) -> Bool {
        var result: Bool!
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            var builderWordDataSource = BuilderWordDataSource(context: context)
            result = builderWordDataSource.addWord(word, fromServer: fromServer)
        }
        return result
    }
    
    func removeBuilderWordWithWord(word: String) {
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            var builderWordDataSource = BuilderWordDataSource(context: context)
            builderWordDataSource.removeBuilderWordWithWord(word)
        }
    }
    
}