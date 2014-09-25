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

public struct User {
    
    var id: String? = nil
    var username: String? = nil
    var password: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var birthday: NSDate? = nil
    var nickname: String? = nil
    var facebookID: String? = nil
    var photoUrl: String? = nil
    var pubnubId: String? = nil
    var mugs: [Mug]? = nil
    var devices: [Device]? = nil
    var rooms: [Room]? = nil
    var contacts: [User]? = nil
    var hasMeAsContact: [User]? = nil
    var updatedAt: NSDate? = nil
    var createdAt: NSDate? = nil
    
}