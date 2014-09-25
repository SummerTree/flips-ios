//
//  Room.swift
//  mugchat
//
//  Created by Ecil Teodoro on 9/23/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
//

public struct Room {
    
    var id: String? = nil
    var name: String? = nil
    var admin: User? = nil
    var participants: [User]? = nil
    var pubnubId: String? = nil
    
}