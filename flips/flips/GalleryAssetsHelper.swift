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

import AssetsLibrary

public class GalleryAssetsHelper {
    
    private let GALLERY_BUTTON_IMAGE_SIZE : CGFloat = 100.0
    private let FILTER_PHOTO_IMAGE : UIImage = UIImage(named: "Filter_Photo")!

    private let assetLib = ALAssetsLibrary()
    
    public class var sharedInstance : GalleryAssetsHelper {
        struct Static {
            static let instance : GalleryAssetsHelper = GalleryAssetsHelper()
        }
        return Static.instance
    }
    
    func addThumbnailToButton(button: UIButton) {
        
        var lastImage = UIImage?()
        
        assetLib.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                group!.setAssetsFilter(ALAssetsFilter.allPhotos())
                if group!.numberOfAssets() > 0 {
                    group!.enumerateAssetsAtIndexes(NSIndexSet(index: group!.numberOfAssets()-1), options: NSEnumerationOptions.Concurrent, usingBlock: { (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                        if result != nil {
                            var assetRep: ALAssetRepresentation = result.defaultRepresentation()
       
                            var iref = assetRep.fullScreenImage().takeUnretainedValue()
                            lastImage = UIImage(CGImage: iref)?.cropSquareImage(self.GALLERY_BUTTON_IMAGE_SIZE)
                            button.setImage(lastImage, forState: .Normal)
                        } else {
                            if lastImage == nil {
                                button.setImage(self.FILTER_PHOTO_IMAGE, forState: .Normal)
                            }
                        }
                    })
                } else {
                    button.setImage(self.FILTER_PHOTO_IMAGE, forState: .Normal)
                }
            } else {
                if lastImage == nil {
                    button.setImage(self.FILTER_PHOTO_IMAGE, forState: .Normal)
                }            }
            }, failureBlock: { (error: NSError!) -> Void in
                if lastImage == nil {
                    button.setImage(self.FILTER_PHOTO_IMAGE, forState: .Normal)
                }
                println(error)
        })
    }
}