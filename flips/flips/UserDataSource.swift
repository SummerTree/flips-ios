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
}

public typealias UserSyncFinished = (Bool, FlipError?) -> Void

@objc protocol UserDataSourceDelegate: NSObjectProtocol {
    optional func userDataSource(userDataSource: UserDataSource, didDownloadFlip: Flip)
    optional func userDataSourceDidFinishFlipsDownload(userDataSource: UserDataSource)
}


class UserDataSource : BaseDataSource {
    weak var delegate: UserDataSourceDelegate?
    
    var flipsDownloadCount = ThreadSafe(0)
    var flipsDownloadCounter = ThreadSafe(0)
    
    var isDownloadingFlips: Bool {
        return (flipsDownloadCount.value - flipsDownloadCounter.value) > 0
    }
    
    
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
        
//        // local user doesn't have device
//        if (user.device == nil) {
//            
//            // remote user has device
//            if (json[UserJsonParams.DEVICES] != nil && json[UserJsonParams.DEVICES].array?.count > 0) {
//                let device = json[UserJsonParams.DEVICES].array?[0]
//                var deviceDataSource = DeviceDataSource(context: currentContext)
//                user.device = deviceDataSource.createEntityWithJson(JSON(device!.object))
//            }
//        }
        
        user.firstName = json[UserJsonParams.FIRST_NAME].stringValue
        user.lastName = json[UserJsonParams.LAST_NAME].stringValue
        user.nickname = json[UserJsonParams.NICKNAME].stringValue
        user.photoURL = json[UserJsonParams.PHOTO_URL].stringValue
        user.phoneNumber = json[UserJsonParams.PHONE_NUMBER].stringValue
        user.isTemporary = json[UserJsonParams.IS_TEMPORARY].boolValue
        
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
//        let userID = json[UserJsonParams.ID].stringValue
        
//        var user = self.getUserById(userID)
        
//        if (user == nil) {
        var user = self.createEntityWithJson(json)
//        } else {
//            self.fillUser(user!, withJsonData: json)
//        }
        
        user.me = isLoggedUser
        
//        let contactDataSource = ContactDataSource(context: currentContext)
//        var contacts = contactDataSource.retrieveContactsWithPhoneNumber(user!.phoneNumber)
        
//        let isAuthenticated = AuthenticationHelper.sharedInstance.isAuthenticated()
//        let authenticatedId = AuthenticationHelper.sharedInstance.userInSession?.userID
        
//        if (contacts.isEmpty && isAuthenticated && authenticatedId != user?.userID) {
//            var facebookID = user?.facebookID
//            var phonetype = (facebookID != nil) ? facebookID : ""
//            
//            var contact = contactDataSource.createOrUpdateContactWith(user!.firstName, lastName: user!.lastName, phoneNumber: user!.phoneNumber, phoneType: phonetype!)
//            contactDataSource.setContactUserAndUpdateContact(user, contact: contact)
//        }
//        
//        for contact in contacts {
//            var contactInContext = contact.inContext(currentContext) as Contact
//            contactDataSource.setContactUserAndUpdateContact(user, contact: contactInContext)
//            user?.addContactsObject(contactInContext)
//        }
        
        return user
    }
    
    func updateUser(user: User, withJson json: JSON, isLoggedUser: Bool = false) -> User {
        var userInContext = user.inContext(currentContext) as User
        
        if (userInContext.userID == "1275") {
            println("log")
        }

        self.fillUser(userInContext, withJsonData: json)
//        userInContext.me = isLoggedUser
        
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
        
//        if (userContact != nil) {
//            var userContactInContext = currentContext.existingObjectWithID(userContact.objectID, error: nil) as Contact
//            var userContactInContext = userContact?.inContext(currentContext) as Contact
//            contactDataSource.setContactUserAndUpdateContact(userInContext, contact: userContact)
//        }
        
        for contact in contacts {
            var contactInContext = contact.inContext(currentContext) as Contact
            contactDataSource.setContactUserAndUpdateContact(userInContext, contact: contactInContext)
            userInContext.addContactsObject(contactInContext)
        }
    }
    
//    func retrieveUserWithId(id: String) -> User? {
//        var user = self.getUserById(id)
//        
//        if (user == nil) {
//            println("User (\(id)) not found in the database and it mustn't happen. Check why he wasn't added to database yet.")
//        }
//        
//        return user
//    }
    
    func getUserById(id: String) -> User? {
        return User.findFirstByAttribute(UserAttributes.USER_ID, withValue: id) as? User
    }
    
    func downloadMyFlips(myFlips: [Flip]) {
        let userService = UserService()
        
        self.flipsDownloadCount.value = countElements(myFlips)
        self.flipsDownloadCounter.value = 1
        
        for myFlip in myFlips {
            let flip = myFlip.inContext(currentContext) as Flip
            Downloader.sharedInstance.downloadDataForFlip(flip, isTemporary: false, completion: { (error) -> Void in
                if (error != nil) {
                    println("Error downloading data for my flip (\(flip.flipID))")
                }
                
                if (self.isDownloadingFlips) {
                    NSLog("Downloaded flips: \(self.flipsDownloadCounter.value) of \(self.flipsDownloadCount.value)")
                    self.delegate?.userDataSource?(self, didDownloadFlip: flip)
                    
                    self.flipsDownloadCounter.value++
                } else {
                    NSLog("Downloads complete!")
                    self.delegate?.userDataSourceDidFinishFlipsDownload?(self)
                }
            })
        }
    }
    
//    func syncUserData(callback: UserSyncFinished) {
//        println("\nsyncUserData")
//        let roomService = RoomService()
//        let builderService = BuilderService()
//        
//        
//        var error: FlipError?
//        
//        let group = dispatch_group_create()
//        
//        dispatch_group_enter(group)
//        let flipDataSource = FlipDataSource(context: currentContext)
//        userService.getMyFlips({ (jsonResponse) -> Void in
//            let myFlipsAsJSON = jsonResponse.array
//            
//            self.flipsDownloadCount.value = countElements(myFlipsAsJSON!)
//            self.flipsDownloadCounter.value = 1
//            
//            for myFlipJson in myFlipsAsJSON! {
//                let flip = flipDataSource.createOrUpdateFlipWithJson(myFlipJson)
//                Downloader.sharedInstance.downloadDataForFlip(flip, isTemporary: false, completion: { (error) -> Void in
//                    if (error != nil) {
//                        println("Error downloading data for my flip (\(flip.flipID))")
//                    }
//                    
//                    if (self.isDownloadingFlips) {
//                        NSLog("Downloaded flips: \(self.flipsDownloadCounter.value) of \(self.flipsDownloadCount.value)")
//                        self.delegate?.userDataSource?(self, didDownloadFlip: flip)
//                        
//                        self.flipsDownloadCounter.value++
//                    } else {
//                        NSLog("Downloads complete!")
//                        self.delegate?.userDataSourceDidFinishFlipsDownload?(self)
//                    }
//                })
//            }
//            dispatch_group_leave(group)
//            }, failCompletion: { (flipError) -> Void in
//                error = flipError
//                dispatch_group_leave(group)
//        })
//        
//        dispatch_group_enter(group)
//        roomService.getMyRooms({ (rooms) -> Void in
//            for room in rooms {
//                var roomInContext = room.inContext(NSManagedObjectContext.contextForCurrentThread()) as Room
//                println("   - subscribing to room: \(roomInContext.roomID)")
//                PubNubService.sharedInstance.subscribeToChannelID(roomInContext.pubnubID)
//            }
//            dispatch_group_leave(group)
//            }, failCompletion: { (flipError) -> Void in
//                error = flipError
//                dispatch_group_leave(group)
//        })
//        
//        dispatch_group_enter(group)
//        builderService.getSuggestedWords({ (words) -> Void in
////            let builderWordDataSource = BuilderWordDataSource(context: currentContext)
////            builderWordDataSource.addWords(words, fromServer: true)
//            DataFacade.sharedInstance.addBuilderWords(words, fromServer: true)
//            dispatch_group_leave(group)
//            }, failCompletion: { (flipError) -> Void in
//                error = flipError
//                dispatch_group_leave(group)
//        })
//        
//        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
//        
//        if (error != nil) {
//            println("sync fail\n")
//            callback(false, error)
//            return
//        }
//        
//        callback(true, nil)
//    }
    
    // Users from the App that are my contacts
    func getMyUserContacts() -> [User] {
        var predicate = NSPredicate(format: "((\(UserAttributes.ME) == false) AND (\(UserAttributes.CONTACTS).@count > 0))")
        var result = User.MR_findAllSortedBy("\(UserAttributes.FIRST_NAME)", ascending: true, withPredicate: predicate, inContext: currentContext)
        return result as [User]
    }
}