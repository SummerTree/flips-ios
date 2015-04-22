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

struct UserJsonParams {
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
    static let IS_TEMPORARY = "isTemporary"
    static let UPDATED_AT = "updatedAt"
}


class UserDataSource : BaseDataSource {
    
    // MARK: - CoreData Creator Methods
    
    private func createEntityWithJson(json: JSON) -> User {
        var entity: User! = User.MR_createInContext(currentContext) as User
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
        user.nickname = json[UserJsonParams.NICKNAME].stringValue
        user.photoURL = json[UserJsonParams.PHOTO_URL].stringValue
        user.phoneNumber = json[UserJsonParams.PHONE_NUMBER].stringValue
        user.isTemporary = json[UserJsonParams.IS_TEMPORARY].boolValue
        user.updatedAt = NSDate(dateTimeString: json[UserJsonParams.UPDATED_AT].stringValue)
        
        if (json[UserJsonParams.BIRTHDAY].stringValue != "") {
            user.birthday = NSDate(dateTimeString: json[UserJsonParams.BIRTHDAY].stringValue)
        }
        
        if (json[UserJsonParams.FACEBOOK_ID].stringValue != "") {
            user.facebookID = json[UserJsonParams.FACEBOOK_ID].stringValue
        }
        
        if (json[UserJsonParams.PUBNUB_ID].stringValue != "") {
            user.pubnubID = json[UserJsonParams.PUBNUB_ID].stringValue
        }
    }
    
    
    // MARK - Public Methods
    
    func createUserWithJson(json: JSON, isLoggedUser: Bool = false) -> User {
        var user = self.createEntityWithJson(json)
        user.me = isLoggedUser
        return user
    }
    
    func updateUser(user: User, withJson json: JSON, isLoggedUser: Bool = false) -> User {
        let userIsTemporary = json[UserJsonParams.IS_TEMPORARY].boolValue
        let newUpdateTimestamp = NSDate(dateTimeString: json[UserJsonParams.UPDATED_AT].stringValue)
        let currentUpdateTimestamp = user.updatedAt!
        if (userIsTemporary) {
            return user
        }
        if (currentUpdateTimestamp.compare(newUpdateTimestamp) == NSComparisonResult.OrderedDescending ||
            currentUpdateTimestamp.compare(newUpdateTimestamp) == NSComparisonResult.OrderedSame) {
            return user
        }
        var userInContext = user.inContext(currentContext) as User
        self.fillUser(userInContext, withJsonData: json)
        return userInContext
    }
    
    func associateUser(user: User, withDeviceInJson json: JSON) {
        var userInContext = user.inContext(currentContext) as User
        // local user doesn't have device
        if (userInContext.device == nil) {
            
            // remote user has device
            if (json[UserJsonParams.DEVICES] != nil && json[UserJsonParams.DEVICES].array?.count > 0) {
                let device = json[UserJsonParams.DEVICES].array?[0]
                var deviceDataSource = DeviceDataSource(context: currentContext)
                userInContext.device = deviceDataSource.createEntityWithJson(JSON(device!.object))
            }
        }
    }
    
    func associateUser(user: User, withContacts contacts: [Contact]) {
        let contactDataSource = ContactDataSource(context: currentContext)
        var userInContext = user.inContext(currentContext) as User
        
        for contact in contacts {
            var contactInContext = contact.inContext(currentContext) as Contact
            contactDataSource.setContactUserAndUpdateContact(userInContext, contact: contactInContext)
            userInContext.addContactsObject(contactInContext)
        }
    }
    
    func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(UserAttributes.USER_ID, withValue: id, inContext: currentContext) as? User
    }
    
    // Users from the App that are my contacts
    func getMyUserContacts() -> [User] {
        var predicate = NSPredicate(format: "((\(UserAttributes.ME) == false) AND (\(UserAttributes.CONTACTS).@count > 0))")
        var result = User.MR_findAllSortedBy("\(UserAttributes.FIRST_NAME)", ascending: true, withPredicate: predicate, inContext: currentContext)
        return result as [User]
    }
}
