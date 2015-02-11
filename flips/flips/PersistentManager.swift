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

public class PersistentManager: NSObject {

    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : PersistentManager {
        struct Static {
            static let instance : PersistentManager = PersistentManager()
        }
        return Static.instance
    }
    

    // MARK: - Room Methods
    
//    func createRoomWithJson(json: JSON) -> Room {
//        var room: Room!
//        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
//            let roomDataSource = RoomDataSource(context: context)
//            room = roomDataSource.createOrUpdateWithJson(json)
//        }
//        
//        // Associate rooms with users (admin and participants)
//        
//        return room
//    }
    
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
//            room = roomDataSource.createOrUpdateWithJson(json)
        }
        
        // Associate rooms with users (admin and participants)
        // get or create admin
        // get or create participants
        
        var content = json[RoomJsonParams.PARTICIPANTS]
        var participants = Array<User>()
        for (index: String, json: JSON) in content {
            // ONLY USERS CAN PARTICIPATE IN A ROOM
                participants.append(self.createOrUpdateUserWithJson(json))
//                var user = userDataSource.createOrUpdateUserWithJson(json)
//                room.addParticipantsObject(user as User)
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
        
//        room.admin = userDataSource.retrieveUserWithId(json[RoomJsonParams.ADMIN_ID].stringValue) as User
        
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
                flip = flipDataSourceInContext.createFlipWithJson(json)
            } else {
                flip = flipDataSourceInContext.updateFlip(flip!.inContext(context) as Flip, withJson: json)
            }
        }, completion: { (success, error) -> Void in
            if (success) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    self.associateFlip(flip!, withOwnerInJson: json)
                })
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
//            owner = self.createOrUpdateUserWithJson(ownerJson)
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
        println("   createOrUpdateFlipWithJson: \(json)")
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let flipDataSourceInContext = FlipDataSource(context: context)
            if (flip == nil) {
                flip = flipDataSourceInContext.createFlipWithJson(json)
            } else {
                flip = flipDataSourceInContext.updateFlip(flip!.inContext(context) as Flip, withJson: json)
            }
        }
        println("   createOrUpdateFlipWithJson: \(json)")
        
        self.associateFlip(flip!, withOwnerInJson: json)
        
        return NSManagedObjectContext.MR_defaultContext().existingObjectWithID(flip!.objectID, error: nil) as Flip
    }
    
//    func createFlipWithWord(word: String, backgroundImage: UIImage?, soundURL: NSURL?, createFlipSuccess: CreateFlipSuccess, createFlipFail: CreateFlipFail) {
//        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
//            let flipDataSource = FlipDataSource(context: context)
//            flipDataSource.createFlipWithWord(word, backgroundImage: backgroundImage, soundURL: soundURL, createFlipSuccess: createFlipSuccess, createFlipFail: createFlipFail)
//        }
//    }
//    
//    func createFlipWithWord(word: String, videoURL: NSURL, createFlipSuccess: CreateFlipSuccess, createFlipFail: CreateFlipFail) {
//        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
//            let flipDataSource = FlipDataSource(context: context)
//            flipDataSource.createFlipWithWord(word, videoURL: videoURL, createFlipSuccess: createFlipSuccess, createFlipFail: createFlipFail)
//        }
//    }
    
    func createAndUploadFlip(word: String, backgroundImage: UIImage?, soundPath: NSURL?, category: String = "", isPrivate: Bool = true, createFlipSuccessCompletion: CreateFlipSuccessCompletion, createFlipFailCompletion: CreateFlipFailureCompletion) {
        let cacheHandler = CacheHandler.sharedInstance
        let loggedUser = User.loggedUser() as User!
        
        let flipService = FlipService()
        flipService.createFlip(word, backgroundImage: backgroundImage, soundPath: soundPath, category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: { (json: JSON) -> Void in
            
            var flip: Flip!
            MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
                let flipDataSource = FlipDataSource(context: context)
                flip = flipDataSource.createFlipWithJson(json)
                
                flipDataSource.associateFlip(flip, withOwner: loggedUser)
                flip.setBackgroundContentType(BackgroundContentType.Image)
            })
            
            if (backgroundImage != nil) {
                cacheHandler.saveImage(backgroundImage!, withUrl: flip.backgroundURL, isTemporary: false)
            }
            
            if (soundPath != nil) {
                cacheHandler.saveDataAtPath(soundPath!.relativePath!, withUrl: flip.soundURL, isTemporary: false)
            }
            
            createFlipSuccessCompletion(flip)
        }) { (flipError: FlipError?) -> Void in
            createFlipFailCompletion(flipError)
        }
        //            flipService.createFlip(word, backgroundImage: backgroundImage, soundPath: soundPath, category: category, isPrivate: isPrivate, createFlipSuccessCallback: createFlipSuccessCallback, createFlipFailCallBack: createFlipFailCallBack, inContext: context)
    }
    
    func createAndUploadFlip(word: String, videoURL: NSURL, category: String = "", isPrivate: Bool = true, createFlipSuccessCompletion: CreateFlipSuccessCompletion, createFlipFailCompletion: CreateFlipFailureCompletion) {
        let cacheHandler = CacheHandler.sharedInstance
        let loggedUser = User.loggedUser() as User!
        
        let flipService = FlipService()
        flipService.createFlip(word, videoPath: videoURL, category: category, isPrivate: isPrivate, uploadFlipSuccessCallback: { (json: JSON) -> Void in
            var flip: Flip!
            MagicalRecord.saveWithBlockAndWait({ (context: NSManagedObjectContext!) -> Void in
                let flipDataSource = FlipDataSource(context: context)
                flip = flipDataSource.createFlipWithJson(json)
                
                flipDataSource.associateFlip(flip, withOwner: loggedUser)
                flip.setBackgroundContentType(BackgroundContentType.Video)
            })
            
            if let thumbnail = VideoHelper.generateThumbImageForFile(videoURL.relativePath!) {
                cacheHandler.saveThumbnail(thumbnail, forUrl: flip.backgroundURL)
            }
            
            cacheHandler.saveDataAtPath(videoURL.relativePath!, withUrl: flip.backgroundURL, isTemporary: false)

            createFlipSuccessCompletion(flip)
        }) { (flipError: FlipError?) -> Void in
            createFlipFailCompletion(flipError)
        }
    }
    
    func setFlipBackgroundContentType(contentType: BackgroundContentType, forFlip flip: Flip) {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            let flipDataSource = FlipDataSource(context: context)
            flipDataSource.setFlipBackgroundContentType(contentType, forFlip: flip.inContext(context) as Flip)
        }
    }
    
    
    // MARK: - FlipMessage Methods
    
    func createFlipMessageWithJson(json: JSON, receivedDate:NSDate, receivedAtChannel pubnubID: String) -> FlipMessage? {
        var flipMessage: FlipMessage?
        
        // get user
        let userDataSource = UserDataSource()
        let fromUserID = json[FlipMessageJsonParams.FROM_USER_ID].stringValue
        let user = userDataSource.getUserById(fromUserID)
        
        // get room
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.getRoomWithPubnubID(pubnubID) as Room!

        // get flips
        let flipDataSource = FlipDataSource()
        let content = json[FlipMessageJsonParams.CONTENT]
        var flips = Array<Flip>()
        for (index: String, flipJson: JSON) in content {
            let flip = self.createOrUpdateFlipWithJson(flipJson)
//            var flip = flipDataSource.createOrUpdateFlipWithJson(flipJson)
            flips.append(flip)
//            entity.addFlip(flip, inContext: currentContext)
        }
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessage = flipMessageDataSource.createFlipMessageWithJson(json, receivedDate: receivedDate)
            
            flipMessageDataSource.associateFlipMessage(flipMessage!, withUser: user!, flips: flips, andRoom: room)
        }
        return flipMessage
    }
    
    func createFlipMessageWithFlips(flips: [Flip], toRoom room: Room) -> FlipMessage {
        var flipMessage: FlipMessage!
        
        let flipMessageDataSource = FlipMessageDataSource()
        let messageId = flipMessageDataSource.nextFlipMessageID()
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSourceInContext = FlipMessageDataSource(context: context)
            flipMessage = flipMessageDataSourceInContext.createFlipMessageWithId(messageId, andFlips: flips, toRoom: room)
        }
        return flipMessage
    }
    
    func removeAllFlipMessagesFromRoomID(roomID: String, completion: CompletionBlock) {
        MagicalRecord.saveWithBlock({ (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessageDataSource.removeAllFlipMessagesFromRoomID(roomID)
        }, completion: { (success, error) -> Void in
            completion(success)
        })
    }
    
    func markFlipMessageAsRead(flipMessageId: String) {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            let flipMessageDataSource = FlipMessageDataSource(context: context)
            flipMessageDataSource.markFlipMessageAsRead(flipMessageId)
        }
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
//            user = userDataSourceInContext.createOrUpdateUserWithJson(json, isLoggedUser: isLoggedUser)
        }
        
        if (!isLoggedUser) {
            let contactDataSource = ContactDataSource()
            
            let isAuthenticated = AuthenticationHelper.sharedInstance.isAuthenticated()
            let authenticatedId = User.loggedUser()?.userID
            
            var userContact: Contact?
            var userInContext = user!.inThreadContext() as User
            if (authenticatedId != userInContext.userID) {
                //        var userInContext = user!.inContext(context) as User
                var facebookID = user!.facebookID
                var phonetype = (facebookID != nil) ? facebookID : ""
                //            var contact = contactDataSource.createOrUpdateContactWith(user.firstName, lastName: user.lastName, phoneNumber: user.phoneNumber, phoneType: phonetype!)
                userContact = self.createOrUpdateContactWith(userInContext.firstName, lastName: userInContext.lastName, phoneNumber: userInContext.phoneNumber, phoneType: phonetype!, andContactUser: userInContext)
            }
            
//            var contacts = contactDataSource.retrieveContactsWithPhoneNumber(user!.phoneNumber)
//            
//            MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
//                let userDataSourceInContext = UserDataSource(context: context)
//                userDataSourceInContext.associateUser(user!, withContacts: contacts)
//            }
        }
        
        return NSManagedObjectContext.MR_defaultContext().existingObjectWithID(user!.objectID, error: nil) as User
    }
    
    func defineAsLoggedUser(user: User) {
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            var userInContext = user.inContext(context) as User
            userInContext.me = true
            AuthenticationHelper.sharedInstance.onLogin(userInContext)
//            AuthenticationHelper.sharedInstance.userInSession = userInContext
        }
    }
    
    func defineAsLoggedUserSync(user: User) {
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            var userInContext = user.inContext(context) as User
            userInContext.me = true
            AuthenticationHelper.sharedInstance.onLogin(userInContext)
        }
    }
    
    func syncUserData(callback:(Bool, FlipError?, UserDataSource) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        
        
        let userService = UserService()
        let flipDataSource = FlipDataSource()

        var error: FlipError?
        var myFlips = Array<Flip>()
        
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
                
                dispatch_group_leave(group)
                }, failCompletion: { (flipError) -> Void in
                    println("   getMyFlips - fail")
                    error = flipError
                    dispatch_group_leave(group)
            })
        })
        
        let userDataSource = UserDataSource()
        userDataSource.downloadMyFlips(myFlips)
        
        
        let roomService = RoomService()
        println("getMyRooms")
        dispatch_group_enter(group)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        roomService.getMyRooms({ (rooms) -> Void in
            println("   getMyRooms - success")
            for room in rooms {
                var roomInContext = room.inContext(NSManagedObjectContext.MR_defaultContext()) as Room
                println("   - subscribing to room: \(roomInContext.roomID)")
                PubNubService.sharedInstance.subscribeToChannelID(roomInContext.pubnubID)
            }
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
            self.addBuilderWords(words, fromServer: true)
            dispatch_group_leave(group)
        }, failCompletion: { (flipError) -> Void in
            println("   getSuggestedWords - fail")
            error = flipError
            dispatch_group_leave(group)
        })
        })
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        
        if (error != nil) {
            println("sync fail\n")
            callback(false, error, userDataSource)
            return
        }
        
        callback(true, nil, userDataSource)
            
        })
    }

    
    // MARK: - Contact Methods
    
    func createOrUpdateContactWith(firstName: String, lastName: String?, phoneNumber: String, phoneType: String, andContactUser contactUser: User? = nil) -> Contact {
        let contactDataSource = ContactDataSource()
        var contact = contactDataSource.getContactBy(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        let contactID = String(contactDataSource.nextContactID())
        
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            let contactDataSourceInContext = ContactDataSource(context: context)
            var contactInContext: Contact!
            if (contact == nil) {
                contactInContext = contactDataSourceInContext.createContactWith(contactID, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType, andContactUser: contactUser)
            } else {
                contactInContext = contactDataSourceInContext.updateContact(contact?.inContext(context) as Contact, withFirstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneNumber)
            }
            
            contact = contactInContext
//            contactDataSourceInContext.createOrUpdateContactWith(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
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
        MagicalRecord.saveWithBlock { (context: NSManagedObjectContext!) -> Void in
            var builderWordDataSource = BuilderWordDataSource(context: context)
            builderWordDataSource.removeBuilderWordWithWord(word)
        }
    }
    
}