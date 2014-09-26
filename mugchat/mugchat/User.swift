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
    
    convenience init(object : AnyObject) {
        self.init()
        let json = JSON(object: object)
        self.id = json["id"].stringValue
        self.username = json["username"].stringValue
        self.firstName = json["firstName"].stringValue
        self.lastName = json["lastName"].stringValue
        self.birthday = NSDate(dateTimeString: json["birthday"].stringValue!)
        self.nickname = json["nickname"].stringValue
        self.facebookID = json["facebookID"].stringValue
        self.photoUrl = json["photoUrl"].stringValue
        self.pubnubId = json["pubnubId"].stringValue
    }
    
}