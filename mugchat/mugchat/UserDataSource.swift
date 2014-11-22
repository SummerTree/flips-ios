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
    static let DEVICES = "devices"
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

public typealias UserSyncFinished = (Bool, NSError?) -> Void

class UserDataSource : BaseDataSource {
    
    let deviceDataSource = DeviceDataSource()
    
    
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
        
        // local user doesn't have device
        if (user.device == nil) {
            
            // remote user has device
            if (json[UserJsonParams.DEVICES] != nil && json[UserJsonParams.DEVICES].array?.count > 0) {
                let device = json[UserJsonParams.DEVICES].array?[0]
                user.device = deviceDataSource.createEntityWithObject(device!.object)
            }
        }
        
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
        
        let contactDataSource = ContactDataSource()
        var contacts = contactDataSource.retrieveContactsWithPhoneNumber(user!.phoneNumber)
        for contact in contacts {
            contact.contactUser = user
            user?.addContactsObject(contact)
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
            println("Logged as \n   First Name: \(AuthenticationHelper.sharedInstance.userInSession.firstName)\n    ID: \(AuthenticationHelper.sharedInstance.userInSession.userID)")
            println("   ")
            
            // ONLY FOR TESTS
            var contacts = self.getMyUserContacts()
            if (contacts.count == 0) {
                var user4: User! = User.MR_createEntity() as User
                user4.userID = "637"
                user4.firstName = "Caio"
                user4.lastName = "Fonseca"
                user4.phoneNumber = "4158889999"
                user4.photoURL = "https://s3.amazonaws.com/flips-pictures/dc652458-41da-4115-87b7-c08a8e715fc1.jpg"
                var contact111: Contact! = Contact.MR_createEntity() as Contact
                contact111.contactID = "100"
                contact111.firstName = "Caio"
                contact111.lastName = "Contact"
                contact111.phoneNumber = "4158889999"
                contact111.contactUser = user4
                user4.addContactsObject(contact111)
                
                var user222: User! = User.MR_createEntity() as User
                user222.userID = "684"
                user222.firstName = "Diego"
                user222.lastName = "Santiviago"
                user222.phoneNumber = "4153213321"
                user222.photoURL = "https://s3.amazonaws.com/flips-pictures/1681aaa9-817f-46e5-96e1-8bbe2e089a43.jpg"
                var contact222: Contact! = Contact.MR_createEntity() as Contact
                contact222.contactID = "101"
                contact222.firstName = "Diego"
                contact222.lastName = "Contact"
                contact222.phoneNumber = "4153213321"
                contact222.contactUser = user222
                user222.addContactsObject(contact222)

                println("NSManagedObjectContext.MR_defaultContext(): \(NSManagedObjectContext.MR_defaultContext())")
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
            }
            // ONLY FOR TESTS
            
            callback(true, nil)
        })
    }
    
    // Users from the App that are my contacts
    func getMyUserContacts() -> [User] {
        var predicate = NSPredicate(format: "((\(UserAttributes.ME) == false) AND (\(UserAttributes.CONTACTS).@count > 0))")
        var result = User.MR_findAllSortedBy("\(UserAttributes.FIRST_NAME)", ascending: true, withPredicate: predicate)
        return result as [User]
    }
    
    // MARK: - Private Getters Methods
    
    private func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(UserAttributes.USER_ID, withValue: id) as? User
    }
}