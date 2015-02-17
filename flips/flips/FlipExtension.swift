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

private let NO_BACKGROUND_IMAGE_NAME = "no_background_image.jpg"

extension Flip {

    func isBlankFlip() -> Bool {
        return (self.backgroundURL != nil) && (!self.backgroundURL.isEmpty)
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
        
        if ((self.thumbnailURL != nil) && (!self.thumbnailURL.isEmpty)) {
            var result = cacheHandler.hasCachedFileForUrl(self.thumbnailURL)
            if (!result.hasCache) {
                allContentReceived = false
            }
        }
        
        return allContentReceived
    }
    
    func backgroundContentLocalPath() -> String {
        let cacheHandler = CacheHandler.sharedInstance
        
        if ((self.backgroundURL != nil) && (!self.backgroundURL.isEmpty)) {
            let result = cacheHandler.hasCachedFileForUrl(self.backgroundURL)
            if (result.hasCache) {
                return result.filePath!
            }
        }
        
        let noBackgroundImageResult = cacheHandler.hasCachedFileForUrl(NO_BACKGROUND_IMAGE_NAME)
        if (noBackgroundImageResult.hasCache) {
            return noBackgroundImageResult.filePath!
        }
        
        let imageWidth = UIScreen.mainScreen().bounds.size.width
        let imageSize = CGSizeMake(imageWidth, imageWidth)
        let noBackgroundImage = UIImage.imageWithColor(UIColor.avacado(), size:imageSize);

        return cacheHandler.saveImage(noBackgroundImage, withUrl: NO_BACKGROUND_IMAGE_NAME, isTemporary: false)
    }
    
    func soundContentLocalPath() -> String? {
        let cacheHandler = CacheHandler.sharedInstance
        
        if ((self.soundURL == nil) || countElements(self.soundURL) == 0) {
            return ""
        }
        
        let result = cacheHandler.hasCachedFileForUrl(self.soundURL)
        return result.filePath
    }
}