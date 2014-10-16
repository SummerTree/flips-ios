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

import Foundation

private let _ID = "id"
private let USER = "user"
private let PHONE_NUMBER = "phoneNumber"
private let PLATFORM = "platform"
private let UUID = "uuid"
private let IS_VERIFIED = "isVerified"
private let RETRY_COUNT = "retryCount"

class DeviceDataSource : BaseDataSource {
    
    func createEntityWithObject(object : AnyObject) -> Device {
        let userDataSource = UserDataSource()
        
        var entity: Device! = Device.createEntity() as Device
        
        var json = JSON(object)
        self.fillDevice(entity, withJson: json)
        entity.user = userDataSource.createOrUpdateUserWithJson(json[USER])

        self.save()
        
        return entity
    }
    
    private func fillDevice(device: Device, withJson json : JSON) {
        device.deviceID = json[_ID].stringValue
        device.phoneNumber = json[PHONE_NUMBER].stringValue
        device.platform = json[PLATFORM].stringValue
        device.uuid = json[UUID].stringValue
        device.isVerified = json[IS_VERIFIED].intValue == 0 ? false : true
        device.retryCount = json[RETRY_COUNT].intValue
    }
}