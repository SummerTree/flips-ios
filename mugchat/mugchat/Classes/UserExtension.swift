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
        
        User.fillUser(entity, withJsonData: json)
        
        return entity
    }
    
    class func createEntityWithId(id: String) -> User {
        var entity: User! = self.createEntity() as User
        entity.userID = id
        return entity
    }
    
    class func createEntityInAnotherContextWithJson(json: JSON) -> User {
        var newContext = NSManagedObjectContext.MR_contextWithParent(NSManagedObjectContext.MR_context())
        println("Creating entity in new context: \(newContext)")
        var entity: User! = self.MR_createInContext(newContext) as User
        
        User.fillUser(entity, withJsonData: json)
        
        return entity
    }
    
    private class func fillUser(user: User, withJsonData json: JSON) {
        user.userID = json[ID].stringValue
        user.username = json[USERNAME].stringValue
        user.firstName = json[FIRST_NAME].stringValue
        user.lastName = json[LAST_NAME].stringValue
        user.birthday = NSDate(dateTimeString: json[BIRTHDAY].stringValue)
        user.nickname = json[NICKNAME].stringValue
        user.facebookID = json[FACEBOOK_ID].stringValue
        user.photoURL = json[PHOTO_URL].stringValue
        user.pubnubID = json[PUBNUB_ID].stringValue
    }
    
    class func save() {
        println("Saving entity in default context: \(NSManagedObjectContext.MR_defaultContext())")
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