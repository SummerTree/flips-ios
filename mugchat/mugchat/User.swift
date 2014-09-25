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
    
    convenience init(json : NSDictionary) {
        self.init()
        self.id = String(json.valueForKeyPath("id") as Int!)
        self.username = json.valueForKeyPath("username") as String!
        self.firstName = json.valueForKeyPath("firstName") as String!
        self.lastName = json.valueForKeyPath("lastName") as String!
        self.birthday = NSDate(dateTimeString: (json.valueForKeyPath("birthday") as String!))
        self.nickname = json.valueForKeyPath("nickname") as String!
        self.facebookID = json.valueForKeyPath("facebookID") as String!
        self.photoUrl = json.valueForKeyPath("photoUrl") as String!
        self.pubnubId = json.valueForKeyPath("pubnubId") as String!
    }
    
}