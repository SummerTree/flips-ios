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

private let USER_ID_ATTRIBUTE = "userID"

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
        if (user.userID != json[ID].stringValue) {
            println("Possible error. Will change user id from (\(user.userID)) to (\(json[ID].stringValue))")
        }
        
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
    
    
    // MARK - Public Methods
    
    func createOrUpdateUserWithJson(json: JSON) -> User {
        let userID = json[ID].stringValue
        var user = self.getUserById(userID)
        
        if (user == nil) {
            user = self.createEntityWithJson(json)
        } else {
            self.fillUser(user!, withJsonData: json)
            self.save()
        }
        
        return user!
    }
    
    func retrieveUserWithId(id: String) -> User {
        var user = self.getUserById(id)
        
        if (user == nil) {
            println("User (\(id)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
        }
        
        return user!
    }
    
    
    // MARK: - Private Getters Methods
    
    private func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(USER_ID_ATTRIBUTE, withValue: id) as? User
    }
}