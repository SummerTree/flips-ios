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

extension MugMessage {

    func addMug(mug: Mug) {
        
        for (var i: Int = 0; i < self.mugs.count; i++) {
            if (mug.mugID == self.mugs.objectAtIndex(i).mugID) {
                println("Mug already added to this MugMessage")
                return
            }
        }
        
        var mutableOrderedSet = NSMutableOrderedSet(orderedSet: self.mugs)
        mutableOrderedSet.addObject(mug)
        self.mugs = mutableOrderedSet
    }
    
    func messageThumbnail() -> UIImage? {
        let firstMug = self.mugs.objectAtIndex(0) as Mug
        return CacheHandler.sharedInstance.thumbnailForUrl(firstMug.backgroundURL)
    }
    
    func createThumbnail() {
        let firstMug = self.mugs.objectAtIndex(0) as Mug
        let cacheHandler = CacheHandler.sharedInstance
        if (firstMug.isBackgroundContentTypeImage()) {
            let backgroundImageData = cacheHandler.dataForUrl(firstMug.backgroundURL)
            if (backgroundImageData != nil) {
                cacheHandler.saveThumbnail(UIImage(data: backgroundImageData!), forUrl: firstMug.backgroundURL)
            }
        } else if (firstMug.isBackgroundContentTypeVideo()) {
            // TODO:
        }
    }
}