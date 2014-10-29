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


enum BackgroundContentType {
    case Undefined
    case Image
    case Video
}

private struct BackgroundContentTypeValue {
    static let Undefined: Int = 0
    static let Image: Int = 1
    static let Video: Int = 2
}

extension Mug {
 
    func setBackgroundContentType(type: BackgroundContentType) {
        if (type == BackgroundContentType.Undefined) {
            println("Error: trying to set background content type to undefined for mug \(self.mugID).")
        }
        
        var typeValue: Int!
        switch(type) {
        case BackgroundContentType.Undefined:
            typeValue = BackgroundContentTypeValue.Undefined
        case BackgroundContentType.Image:
            typeValue = BackgroundContentTypeValue.Image
        case BackgroundContentType.Video:
            typeValue = BackgroundContentTypeValue.Video
        }
        
        self.backgroundContentType = typeValue
        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
    }
    
    func isBackgroundContentTypeDefined() -> Bool {
        return (self.backgroundContentType != BackgroundContentTypeValue.Undefined)
    }
    
    func isBackgroundContentTypeImage() -> Bool {
        return (self.backgroundContentType == BackgroundContentTypeValue.Image)
    }
    
    func isBackgroundContentTypeVideo() -> Bool {
        return (self.backgroundContentType == BackgroundContentTypeValue.Video)
    }
}