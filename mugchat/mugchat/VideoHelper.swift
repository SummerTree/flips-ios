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
import AVFoundation

class VideoHelper {

    class func generateThumbImageForFile(filePath: String) -> UIImage {
        let url = NSURL(fileURLWithPath: filePath)
        
        let asset: AVAsset! = AVAsset.assetWithURL(url) as AVAsset
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        var time: CMTime = asset.duration
        time.value = 0
        
        let imageRef = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: nil)
        return UIImage(CGImage: imageRef)!
    }
}