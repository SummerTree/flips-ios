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


private struct DeviceJsonParams {
    static let ID = "id"
    static let USER = "user"
    static let PLATFORM = "platform"
    static let UUID = "uuid"
    static let IS_VERIFIED = "isVerified"
    static let RETRY_COUNT = "retryCount"
}


class DeviceDataSource : BaseDataSource {
    
    func createEntityWithObject(object : AnyObject) -> Device {
        let userDataSource = UserDataSource()
        
        var entity: Device! = Device.createEntity() as Device
        
        var json = JSON(object)
        self.fillDevice(entity, withJson: json)
        entity.user = userDataSource.retrieveUserWithId(json[DeviceJsonParams.USER].stringValue)

        self.save()
        
        return entity
    }
    
    private func fillDevice(device: Device, withJson json : JSON) {
        device.deviceID = json[DeviceJsonParams.ID].stringValue
        device.platform = json[DeviceJsonParams.PLATFORM].stringValue
        device.uuid = json[DeviceJsonParams.UUID].stringValue
        device.isVerified = json[DeviceJsonParams.IS_VERIFIED].intValue == 0 ? false : true
        device.retryCount = json[DeviceJsonParams.RETRY_COUNT].intValue
    }
}