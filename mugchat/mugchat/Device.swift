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
    
    private let ID = "id"
    private let USER = "user"
    private let PHONE_NUMBER = "phoneNumber"
    private let PLATFORM = "platform"
    private let UUID = "uuid"
    private let IS_VERIFIED = "isVerified"
    private let RETRY_COUNT = "retryCount"
    private let VERIFICATION_CODE = "verificationCode"
    
    var id: String?
    var user: User?
    var phoneNumber: String?
    var platform: String?
    var uuid: String?
    var isVerified: Bool?
    var retryCount: Int?
    var verificationCode: String?
    
    convenience init(object : AnyObject) {
        self.init()
        let json = JSON(object)
        self.id = json[ID].string
        self.user = User(id: json[USER].string!)
        self.phoneNumber = json[PHONE_NUMBER].string
        self.platform = json[PLATFORM].string
        self.uuid = json[UUID].string
        self.isVerified = json[IS_VERIFIED].intValue == 0 ? false : true
        self.retryCount = json[RETRY_COUNT].intValue
        self.verificationCode = json[VERIFICATION_CODE].string
    }
    
}