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

private struct UserJsonParams {
    static let ID = "id"
    static let USERNAME = "username"
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    static let BIRTHDAY = "birthday"
    static let NICKNAME = "nickname"
    static let FACEBOOK_ID = "facebookID"
    static let PHOTO_URL = "photoUrl"
    static let PUBNUB_ID = "pubnubId"
    static let PHONE_NUMBER = "phoneNumber"
}

struct UserAttributes {
    static let USER_ID = "userID"
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    static let ME = "me"
    static let USER_CONTACT = "userContact"
}

public typealias UserSyncFinished = (Bool, NSError?) -> Void

class UserDataSource : BaseDataSource {
    
    // MARK: - CoreData Creator Methods
    
    private func createEntityWithJson(json: JSON) -> User {
        var entity: User! = User.MR_createEntity() as User
        
        self.fillUser(entity, withJsonData: json)
        
        return entity
    }
    
    // Entities in diferent context are not saved in the database. To save it, you need to merge the context where it was created.
    // Not sure if it will be used. Is here just like an example.
    private func createEntityInAnotherContextWithJson(json: JSON) -> User {
        var newContext = NSManagedObjectContext.MR_contextWithParent(NSManagedObjectContext.MR_context())
        
        println("Creating entity in new context: \(newContext)")
        var entity: User! = User.MR_createInContext(newContext) as User
        
        self.fillUser(entity, withJsonData: json)
        
        return entity
    }
    
    private func fillUser(user: User, withJsonData json: JSON) {
        if (user.userID != json[UserJsonParams.ID].stringValue) {
            println("Possible error. Will change user id from (\(user.userID)) to (\(json[UserJsonParams.ID].stringValue))")
        }
        
        user.userID = json[UserJsonParams.ID].stringValue
        user.username = json[UserJsonParams.USERNAME].stringValue
        user.firstName = json[UserJsonParams.FIRST_NAME].stringValue
        user.lastName = json[UserJsonParams.LAST_NAME].stringValue
        user.birthday = NSDate(dateTimeString: json[UserJsonParams.BIRTHDAY].stringValue)
        user.nickname = json[UserJsonParams.NICKNAME].stringValue
        user.facebookID = json[UserJsonParams.FACEBOOK_ID].stringValue
        user.photoURL = json[UserJsonParams.PHOTO_URL].stringValue
        user.pubnubID = json[UserJsonParams.PUBNUB_ID].stringValue
        user.phoneNumber = json[UserJsonParams.PHONE_NUMBER].stringValue
    }
    
    
    // MARK - Public Methods
    
    func createOrUpdateUserWithJson(json: JSON) -> User {
        let userID = json[UserJsonParams.ID].stringValue
        var user = self.getUserById(userID)
        
        if (user == nil) {
            user = self.createEntityWithJson(json)
        } else {
            self.fillUser(user!, withJsonData: json)
        }
        self.save()
        
        return user!
    }
    
    func retrieveUserWithId(id: String) -> User {
        var user = self.getUserById(id)
        
        if (user == nil) {
            println("User (\(id)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
        }
        
        return user!
    }
    
    func syncUserData(callback: UserSyncFinished) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            // TODO: sync my mugs with API
            
            println("   ")
            if (NSThread.currentThread() == NSThread.mainThread()) {
                println("syncUserData IN MAIN THREAD")
            } else {
                println("syncUserData NOT IN MAIN THREAD")
            }
            println("   ")
            
            // ONLY FOR TESTS
            var contacts = self.getMyUserContacts()
            if (contacts.count == 0) {
                var mug = Mug.createEntity() as Mug
                mug.mugID = "2"
                mug.word = "I"
                mug.backgroundURL = "https://s3.amazonaws.com/mugchat-pictures/09212b08-2904-4576-a93d-d686e9a3cba1.jpg"
                mug.owner = User.loggedUser()
                mug.isPrivate = true
                
                var mug2 = Mug.createEntity() as Mug
                mug2.mugID = "3"
                mug2.word = "Love"
                mug2.backgroundURL = "https://s3.amazonaws.com/mugchat-pictures/88a2af31-b250-4918-b773-9943a15406c7.jpg"
                mug2.soundURL = "audio.m4a"
                mug2.owner = User.loggedUser()
                mug2.isPrivate = true
                
                var mug21 = Mug.createEntity() as Mug
                mug21.mugID = "30"
                mug21.word = "love"
                mug21.backgroundURL = "http://lovesign.com.au/wp-content/uploads/2009/11/Stop-In-the-Name-of-Love-Alan-James-2003.jpg"
                mug21.owner = User.loggedUser()
                mug21.isPrivate = true
                
                var mug3 = Mug.createEntity() as Mug
                mug3.mugID = "4"
                mug3.word = "San Francisco"
                mug3.backgroundURL = "https://s3.amazonaws.com/mugchat-pictures/Screen+Shot+2014-10-10+at+11.27.00+AM.png"
                mug3.owner = User.loggedUser()
                mug3.isPrivate = true
                
                var user: User! = User.MR_createEntity() as User
                user.userID = "3"
                user.firstName = "Bruno"
                user.lastName = "User"
                user.phoneNumber = "+141512345678"
                user.photoURL = "http://upload.wikimedia.org/wikipedia/pt/9/9d/Maggie_Simpson.png"
                
                var mug4 = Mug.createEntity() as Mug
                mug4.mugID = "5"
                mug4.word = "San Francisco"
                mug4.backgroundURL = "http://baybridgeinfo.org/sites/default/files/images/background/ws/xws7.jpg.pagespeed.ic.ULYPGat4fH.jpg"
                mug4.owner = user
                mug4.isPrivate = true
                
                // NOT MY CONTACT
                var user3: User! = User.MR_createEntity() as User
                user3.userID = "5"
                user3.firstName = "Ecil"
                user3.lastName = "User"
                user3.phoneNumber = "+144423455555"
                user3.photoURL = "http://3.bp.blogspot.com/_339JZmAslb0/TG3x4LbfGeI/AAAAAAAAABU/QATFhgxPMvA/s200/Lisa_Simpson150.jpg"
                
                var contact: Contact! = Contact.MR_createEntity() as Contact
                contact.contactID = "1"
                contact.firstName = "Bruno"
                contact.lastName = "Contact"
                contact.phoneNumber = "+141512345678"
                contact.contactUser = user
                user.addUserContactObject(contact)
                
                // Simulating a user that is only contact on my agenda
                var contact2: Contact! = Contact.MR_createEntity() as Contact
                contact2.contactID = "2"
                contact2.firstName = "Fernando"
                contact2.lastName = "Contact"
                contact2.phoneNumber = "+144423456789"
                contact2.phoneType = "iPhone"
                
                var room: Room! = Room.MR_createEntity() as Room
                room.roomID = "1"
                room.pubnubID = "$2a$10$Rhq0o6l75GdKZepEUJ9nUO7iKxdEMbZ.jLy45qRLJYR.tjF0PXuEW"
                room.name = "Test"
                room.addParticipantsObject(user)
                room.addParticipantsObject(user3)
                PubNubService.sharedInstance.subscribeToChannel(room.pubnubID)
                
                var room2: Room! = Room.MR_createEntity() as Room
                room2.roomID = "2"
                room2.pubnubID = "$2a$10$LbkpRd14zxcSacF3kBnqTu8GHRDpI.LqHWOLQkx8qiL3n/H7vJci"
                room2.name = "Chat"
                room2.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room2.pubnubID)
                
                var room3: Room! = Room.MR_createEntity() as Room
                room3.roomID = "3"
                room3.pubnubID = "$2a$10$tHnGMFLALJpwAZzygOA7uOiG3KHMVMpsvZMW/3ojgi.eb7gfNXXS"
                room3.name = "Chat"
                room3.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room3.pubnubID)
                
                var room4: Room! = Room.MR_createEntity() as Room
                room4.roomID = "4"
                room4.pubnubID = "$2a$10$5ooP3jZY.tjvOBNydDkJ7.kd.VT8LTOMvDu8fz6lCdNxBdPxhOEW"
                room4.name = "Chat"
                room4.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room4.pubnubID)
                
                var room5: Room! = Room.MR_createEntity() as Room
                room5.roomID = "5"
                room5.pubnubID = "$2a$10$ipXtNr1gtFbOGWsf26nLWOKDYETNDwyYn.zA5SkOHD4SevtT41rS"
                room5.name = "Chat"
                room5.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room5.pubnubID)
                
                var room6: Room! = Room.MR_createEntity() as Room
                room6.roomID = "6"
                room6.pubnubID = "$2a$10$z1pMh0oBiuzZF4sbRRC1desEImzj4G0K3CP7wLz.kafQKWjOWfVw."
                room6.name = "Chat"
                room6.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room6.pubnubID)
                
                var room7: Room! = Room.MR_createEntity() as Room
                room7.roomID = "7"
                room7.pubnubID = "$2a$10$.0zxIsZ1.zQJ2ZkrZm.WW.NMy/kMAzRr79rGkeizZ/AkvQogFeAC"
                room7.name = "Chat"
                room7.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room7.pubnubID)
                
                var room8: Room! = Room.MR_createEntity() as Room
                room8.roomID = "8"
                room8.pubnubID = "$2a$10$XDyoTHXDSVVzJqqVsLtC.ejbaz5jFE2x55cK480IjHhoqaz8AKmm"
                room8.name = "Chat"
                room8.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room8.pubnubID)
                
                var room9: Room! = Room.MR_createEntity() as Room
                room9.roomID = "9"
                room9.pubnubID = "$2a$10$88salVtKxvNJ8Vll1POyFOorUFf7CLdeKok2Hg3k4HIG12Qy8xRiG"
                room9.name = "Chat"
                room9.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room9.pubnubID)
                
                var room10: Room! = Room.MR_createEntity() as Room
                room10.roomID = "10"
                room10.pubnubID = "$2a$10$IdbkXv3RK6WPy4039I8QoegAjdJZ.hoZXqqGLZkMVHt3iVOIk3gVi"
                room10.name = "Chat"
                room10.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room10.pubnubID)
                
                var room11: Room! = Room.MR_createEntity() as Room
                room11.roomID = "11"
                room11.pubnubID = "$2a$10$t.pA7LXizbWYAhlYOLf22OWrekd6ONjsaaG36iqvaKhbewuodsua"
                room11.name = "Chat"
                room11.addParticipantsObject(user)
                PubNubService.sharedInstance.subscribeToChannel(room11.pubnubID)
                
                println("NSManagedObjectContext.MR_defaultContext(): \(NSManagedObjectContext.MR_defaultContext())")
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
            }
            // ONLY FOR TESTS
            
            callback(true, nil)
        })
    }
    
    // Users from the App that are my contacts
    func getMyUserContacts() -> [User] {
        var predicate = NSPredicate(format: "((\(UserAttributes.ME) == false) AND (\(UserAttributes.USER_CONTACT).@count > 0))")
        var result = User.MR_findAllSortedBy("\(UserAttributes.FIRST_NAME)", ascending: true, withPredicate: predicate)
        return result as [User]
    }
    
    // MARK: - Private Getters Methods
    
    private func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(UserAttributes.USER_ID, withValue: id) as? User
    }
}