//
// Copyright 2015 ArcTouch, Inc.
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
        super.init(frame: CGRect.zero)
        
        holeSize = cropHoleSize
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, UIColor(RRGGBB: UInt(0x4A4A4A)).CGColor)
        CGContextSetAlpha(context, 0.9)
        CGContextFillRect(context, rect)
        
        let positionX = (rect.width / 2) - (holeSize.width / 2)
        let positionY = (rect.height / 2) - (holeSize.height / 2)
        
        let holeRect = CGRectMake(positionX, positionY, holeSize.width, holeSize.height)
        
        var holeRectIntersection = CGRectIntersection(holeRect, rect)
        
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        CGContextSetBlendMode(context, CGBlendMode.Clear)
        
        CGContextFillEllipseInRect(context, holeRect)
    }
}