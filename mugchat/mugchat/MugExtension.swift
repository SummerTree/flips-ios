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

private let NO_BACKGROUND_IMAGE_NAME = "no_background_image.jpg"

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
    
    func isBlankMug() -> Bool {
        let hasBackgroundUrlDefined = (self.backgroundURL != nil) && (!self.backgroundURL.isEmpty)
        let hasSoundUrlDefine = (self.soundURL != nil) && (!self.soundURL.isEmpty)
        
        return (!hasBackgroundUrlDefined) && (!hasSoundUrlDefine)
    }
    
    func hasAllContentDownloaded() -> Bool {
        let cacheHandler = CacheHandler.sharedInstance
        var allContentReceived = true
        
        if ((self.backgroundURL != nil) && (!self.backgroundURL.isEmpty)) {
            var result = cacheHandler.hasCachedFileForUrl(self.backgroundURL)
            if (!result.hasCache) {
                allContentReceived = false
            }
        }
        
        if ((self.soundURL != nil) && (!self.soundURL.isEmpty)) {
            var result = cacheHandler.hasCachedFileForUrl(self.soundURL)
            if (!result.hasCache) {
                allContentReceived = false
            }
        }
        
        return allContentReceived
    }
    
    func backgroundContentLocalPath() -> String {
        let cacheHandler = CacheHandler.sharedInstance
        
        let result = cacheHandler.hasCachedFileForUrl(self.backgroundURL)
        if (result.hasCache) {
            return result.filePath!
        }
        
        let noBackgroundImageResult = cacheHandler.hasCachedFileForUrl(NO_BACKGROUND_IMAGE_NAME)
        if (noBackgroundImageResult.hasCache) {
            return noBackgroundImageResult.filePath!
        }
        
        let noBackgroundImage = UIImage.imageWithColor(UIColor.avacado())
        return cacheHandler.saveImage(noBackgroundImage, withUrl: NO_BACKGROUND_IMAGE_NAME, isTemporary: false)
    }
    
    func soundContentLocalPath() -> String? {
        let cacheHandler = CacheHandler.sharedInstance
        
        let result = cacheHandler.hasCachedFileForUrl(self.soundURL)
        return result.filePath
    }
    
//    func imagePlaceholder() -> UIImage {
//        let path = self.backgroundContentLocalPath()
//        // TODO:
//    }
}










