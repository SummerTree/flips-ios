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

private let _ID = "id"
private let USER = "user"
private let PHONE_NUMBER = "phoneNumber"
private let PLATFORM = "platform"
private let UUID = "uuid"
private let IS_VERIFIED = "isVerified"
private let RETRY_COUNT = "retryCount"


extension Device {
   
    class func createEntityWithObject(object : AnyObject) -> Device {
        var entity: Device! = self.createEntity() as Device
        
        var json = JSON(object)
        entity.objectId = json[_ID].string!
        entity.user = User.createEntityWithId(json[USER].string!) // TODO: it seems to be wrong
        entity.phoneNumber = json[PHONE_NUMBER].string!
        entity.platform = json[PLATFORM].string!
        entity.uuid = json[UUID].string!
        entity.isVerified = json[IS_VERIFIED].intValue == 0 ? false : true
        entity.retryCount = json[RETRY_COUNT].intValue
        
        return entity
    }
    
    class func save() {
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
}
