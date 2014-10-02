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

public class Device {
    
    var id: String?
    var user: User?
    var phoneNumber: String?
    var platform: String?
    var uuid: String?
    var isVerified: Bool?
    
    convenience init(object : AnyObject) {
        self.init()
        let json = JSON(object: object)
        self.id = json["id"].stringValue
        var newUser = User()
        newUser.id = json["user"].stringValue
        self.user = newUser
        self.phoneNumber = json["phoneNumber"].stringValue
        self.platform = json["platform"].stringValue
        self.uuid = json["uuid"].stringValue
        self.isVerified = json["isVerified"].integerValue == 0 ? false : true
    }
    
}