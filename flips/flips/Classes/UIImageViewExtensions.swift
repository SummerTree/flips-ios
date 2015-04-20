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

extension UIImageView {
        
    class func imageViewWithColor(color: UIColor) -> UIImageView {
        return UIImageView(image: UIImage.imageWithColor(color))
    }
    
    convenience init(frame: CGRect, borderWidth : CGFloat) {
        self.init(frame: frame)
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        self.clipsToBounds = true
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = borderWidth
    }
    
}
