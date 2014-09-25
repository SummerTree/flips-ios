//
//  User.swift
//  mugchat
//
//  Created by Ecil Teodoro on 9/23/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
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