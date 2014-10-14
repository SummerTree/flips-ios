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

private let ID = "id"
private let USERNAME = "username"
private let FIRST_NAME = "firstName"
private let LAST_NAME = "lastName"
private let BIRTHDAY = "birthday"
private let NICKNAME = "nickname"
private let FACEBOOK_ID = "facebookID"
private let PHOTO_URL = "photoUrl"
private let PUBNUB_ID = "pubnubId"

private let LOGGED_USER_ATTRIBUTE = "me"

extension User {
    
    // MARK: - Static Methods
    
    class func createEntityWithObject(object : AnyObject) -> User {
        let json = JSON(object)
        return User.createEntityWithJson(json)
    }
    
    class func createEntityWithJson(json: JSON) -> User {
        var entity: User! = self.MR_createEntity() as User
        
        entity.userID = json[ID].stringValue
        entity.username = json[USERNAME].stringValue
        entity.firstName = json[FIRST_NAME].stringValue
        entity.lastName = json[LAST_NAME].stringValue
        entity.birthday = NSDate(dateTimeString: json[BIRTHDAY].stringValue)
        entity.nickname = json[NICKNAME].stringValue
        entity.facebookID = json[FACEBOOK_ID].stringValue
        entity.photoURL = json[PHOTO_URL].stringValue
        entity.pubnubID = json[PUBNUB_ID].stringValue
        
        return entity
    }
    
    class func createEntityWithId(id: String) -> User {
        var entity: User! = self.createEntity() as User
        entity.userID = id
        return entity
    }
    
    class func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    class func loggedUser() -> User? {
        var loggedAttributeUser: User? = User.MR_findFirstByAttribute(LOGGED_USER_ATTRIBUTE, withValue: true) as? User
        return loggedAttributeUser
    }

    class func isUserLoggedIn() -> Bool {
        var loggedUser = User.loggedUser() as User?
        return (loggedUser != nil)
    }
}