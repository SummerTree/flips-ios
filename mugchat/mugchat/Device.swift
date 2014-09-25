//
//  Device.swift
//  mugchat
//
//  Created by Ecil Teodoro on 9/23/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
//

public struct Device {
    
    var id: String? = nil
    var user: User? = nil
    var phoneNumber: String? = nil
    var platform: String? = nil
    var uuid: String? = nil
    var verificationCode: String? = nil
    var isVerified: Bool? = nil
    var retryCount: UInt8? = nil
    
}