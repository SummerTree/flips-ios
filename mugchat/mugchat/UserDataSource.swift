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
    static let IS_TEMPORARY = "isTemporary"
}

public typealias UserSyncFinished = (Bool, FlipError?) -> Void

@objc protocol UserDataSourceDelegate: NSObjectProtocol {
    optional func userDataSource(userDataSource: UserDataSource, didDownloadFlip: Flip)
    optional func userDataSourceDidFinishFlipsDownload(userDataSource: UserDataSource)
}


class UserDataSource : BaseDataSource {
    weak var delegate: UserDataSourceDelegate?
    
    let deviceDataSource = DeviceDataSource()
    var flipsDownloadCount = ThreadSafe(0)
    var flipsDownloadCounter = ThreadSafe(0)
    
    var isDownloadingFlips: Bool {
        return (flipsDownloadCount.value - flipsDownloadCounter.value) > 0
    }
    
    
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
        
        let isAuthenticated = AuthenticationHelper.sharedInstance.isAuthenticated()
        let authenticatedId = AuthenticationHelper.sharedInstance.userInSession?.userID
        
        if (contacts.isEmpty && isAuthenticated && authenticatedId != user?.userID) {
            var facebookID = user?.facebookID
            var phonetype = (facebookID != nil) ? facebookID : ""
            
            var contact = contactDataSource.createOrUpdateContactWith(user!.firstName, lastName: user!.lastName, phoneNumber: user!.phoneNumber, phoneType: phonetype!)
            contactDataSource.setContactUserAndUpdateContact(user, contact: contact)
        }
        
        for contact in contacts {
            contactDataSource.setContactUserAndUpdateContact(user, contact: contact)
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
            println("\nsyncUserData")
            let roomService = RoomService()
            let builderService = BuilderService()
            let userService = UserService()
            
            var error: FlipError?
            
            let group = dispatch_group_create()

            dispatch_group_enter(group)
            roomService.getMyRooms({ (rooms) -> Void in
                for room in rooms {
                    println("   - subscribing to room: \(room.roomID)")
                    PubNubService.sharedInstance.subscribeToChannelID(room.pubnubID)
                }
                dispatch_group_leave(group)
            }, failCompletion: { (flipError) -> Void in
                error = flipError
                dispatch_group_leave(group)
            })
            
            dispatch_group_enter(group)
            let builderWordDataSource = BuilderWordDataSource()
            builderService.getSuggestedWords({ (words) -> Void in
                let builderWordDataSource = BuilderWordDataSource()
                builderWordDataSource.addWords(words, fromServer: true)
                dispatch_group_leave(group)
            }, failCompletion: { (flipError) -> Void in
                error = flipError
                dispatch_group_leave(group)
            })
            
            dispatch_group_enter(group)
            let flipDataSource = FlipDataSource()
            userService.getMyFlips({ (jsonResponse) -> Void in
                let myFlipsAsJSON = jsonResponse.array
                
                self.flipsDownloadCount.value = countElements(myFlipsAsJSON!)
                self.flipsDownloadCounter.value = 1
                
                for myFlip in myFlipsAsJSON! {
                    let flip = flipDataSource.createOrUpdateFlipWithJson(myFlip)
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
                dispatch_group_leave(group)
            }, failCompletion: { (flipError) -> Void in
                error = flipError
                dispatch_group_leave(group)
            })
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            if (error != nil) {
                println("sync fail\n")
                callback(false, error)
                return
            }
            
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