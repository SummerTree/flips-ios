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

class CropOverlayView : UIView {
    
    private var holeSize: CGSize!
    
    init(cropHoleSize: CGSize) {
        super.init(frame: CGRect.zeroRect)
        
        holeSize = cropHoleSize
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor(RRGGBB: UInt(0x4A4A4A)).CGColor)
        CGContextSetAlpha(context, 0.9)
        CGContextFillRect(context, rect)
        
        var positionX = (rect.width / 2) - (holeSize.width / 2)
        var positionY = (rect.height / 2) - (holeSize.height / 2)
        
        var holeRect = CGRectMake(positionX, positionY, holeSize.width, holeSize.height)
        
        var holeRectIntersection = CGRectIntersection(holeRect, rect)
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetBlendMode(context, kCGBlendModeClear)
        
        CGContextFillEllipseInRect(context, holeRect)
    }
}