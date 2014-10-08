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

public class User {
    
    private let ID = "id"
    private let USERNAME = "username"
    private let FIRST_NAME = "firstName"
    private let LAST_NAME = "lastName"
    private let BIRTHDAY = "birthday"
    private let NICKNAME = "nickname"
    private let FACEBOOK_ID = "facebookID"
    private let PHOTO_URL = "photoUrl"
    private let PUBNUB_ID = "pubnubId"
    
    var id: String?
    var username: String?
    var firstName: String?
    var lastName: String?
    var birthday: NSDate?
    var nickname: String?
    var facebookID: String?
    var photoUrl: String?
    var pubnubId: String?
    var mugs: [Mug]?
    var devices: [Device]?
    var rooms: [Room]?
    var contacts: [User]?
    
    convenience init(object : AnyObject) {
        self.init()
        let json = JSON(object: object)
        self.id = json[ID].stringValue
        self.username = json[USERNAME].stringValue
        self.firstName = json[FIRST_NAME].stringValue
        self.lastName = json[LAST_NAME].stringValue
        self.birthday = NSDate(dateTimeString: json[BIRTHDAY].stringValue!)
        self.nickname = json[NICKNAME].stringValue
        self.facebookID = json[FACEBOOK_ID].stringValue
        self.photoUrl = json[PHOTO_URL].stringValue
        self.pubnubId = json[PUBNUB_ID].stringValue
    }
    
    convenience init(id: String) {
        self.init()
        self.id = id
    }
    
    convenience init(json: JSON) {
        self.init()
        self.id = json[ID].stringValue
        self.username = json[USERNAME].stringValue
        self.firstName = json[FIRST_NAME].stringValue
        self.lastName = json[LAST_NAME].stringValue
        self.birthday = NSDate(dateTimeString: json[BIRTHDAY].stringValue!)
        self.nickname = json[NICKNAME].stringValue
        self.facebookID = json[FACEBOOK_ID].stringValue
        self.photoUrl = json[PHOTO_URL].stringValue
        self.pubnubId = json[PUBNUB_ID].stringValue
    }
    
    init() {
    }
    
}