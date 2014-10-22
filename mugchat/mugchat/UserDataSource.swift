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
        println("mugsJSON: \(mugsJSON)")
        // TODO: sync my mugs with API

        var mug   = Mug.createEntity() as Mug
        mug.mugID = "2"
        mug.word = "I"
        mug.backgroundURL = "https://s3.amazonaws.com/mugchat-pictures/09212b08-2904-4576-a93d-d686e9a3cba1.jpg"
        mug.owner = User.loggedUser()
        mug.isPrivate = true
    
    
        
        // TODO: sync my contacts with API
        var user: User! = User.MR_createEntity() as User
        user.userID = "138"
        user.firstName = "Bruno"
        user.lastName = "Brüggemann"
        User.loggedUser()?.addContactsObject(user)
        
        var user2: User! = User.MR_createEntity() as User
        user2.userID = "138"
        user2.firstName = "Fernando"
        user2.lastName = "Ghisi"
        User.loggedUser()?.addContactsObject(user2)
        
        // TODO: sync my rooms with API
        for roomJson in roomsJSON["rooms"] {
            println("roomJson: \(roomJson)")
            println(" ")
        }
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        
        callback(true, nil)
    }
    
    // MARK: - Private Getters Methods
    
    private func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(USER_ID_ATTRIBUTE, withValue: id) as? User
    }
    
    
    /// JUST FOR TEST. IT WILL BE REMOVED
    
    let mugsJSON: JSON = JSON("{\"owner\": 8,        \"word\": \"I\",        \"backgroundURL\": \"https://s3.amazonaws.com/mugchat-pictures/09212b08-2904-4576-a93d-d686e9a3cba1.jpg\",\"soundURL\": null,        \"isPrivate\": true,        \"category\": null,        \"id\": 2,        \"createdAt\": \"2014-10-10T14:25:15.000Z\",        \"updatedAt\": \"2014-10-10T14:25:15.000Z\"}, {    \"owner\": 8,    \"word\": \"love\",    \"backgroundURL\": \"https://s3.amazonaws.com/mugchat-pictures/88a2af31-b250-4918-b773-9943a15406c7.jpg\",    \"soundURL\": null,    \"isPrivate\": true,    \"category\": null,    \"id\": 3,    \"createdAt\": \"2014-10-10T14:26:17.000Z\",    \"updatedAt\": \"2014-10-10T14:26:17.000Z\"}, {    \"owner\": 8,    \"word\": \"Mugchat\",    \"backgroundURL\": \"https://s3.amazonaws.com/mugchat-pictures/Screen+Shot+2014-10-10+at+11.27.00+AM.png\",    \"soundURL\": null,    \"isPrivate\": true,    \"category\": null,    \"id\":4,    \"createdAt\": \"2014-10-10T14:28:30.000Z\",    \"updatedAt\": \"2014-10-10T14:28:30.000Z\"}")
    
    let roomsJSON = JSON("{        'rooms': [{        'name': 'test',        'admin': 8,        'pubnubId': '',        'id': '1',        'createdAt': '2014-10-10T16:02:29.000Z',        'updatedAt': '2014-10-10T16:02:29.000Z',        'participants': [{        'userID': 8}, {    'userID': 138}, {    'userID': 23}]}]}")

    let contactsJSON = JSON("\"contacts\": [{        \"owner\": 8,        \"firstName\" : \"Bruno\",        \"lastName\" : \"Brüggemann\",        \"isMugChatUserWithId\" : 138,        \"createdAt\" : \"2014-10-09T16:02:29.000Z\",        \"updatedAt\" : \"2014-10-09T16:02:29.000Z\"}, {    \"owner\": 8,    \"firstName\" : \"Fernando\",    \"lastName\" : \"Ghisi\",    \"isMugChatUserWithId\" : 23,    \"createdAt\" : \"2014-10-10T16:02:29.000Z\",    \"updatedAt\" : \"2014-10-10T16:02:29.000Z\"}]")

}