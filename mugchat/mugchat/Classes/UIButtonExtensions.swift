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

extension UIButton {
    
    class func avatarA1(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A1_AVATAR_SIZE, A1_AVATAR_SIZE), borderWidth: A1_BORDER_WIDTH, image: image)
    }
    
    class func avatarA2(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE), borderWidth: A2_BORDER_WIDTH, image: image)
    }
    
    class func avatarA3(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A3_AVATAR_SIZE, A3_AVATAR_SIZE), borderWidth: A3_BORDER_WIDTH, image: image)
    }
    
    class func avatarA4(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A4_AVATAR_SIZE, A4_AVATAR_SIZE), borderWidth: A4_BORDER_WIDTH, image: image)
    }
    
    convenience init(frame: CGRect, borderWidth: CGFloat, image: UIImage) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.greenColor()
        self.setBackgroundImage(image, forState: UIControlState.Normal)

        self.contentMode = UIViewContentMode.ScaleToFill
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = borderWidth
    }    
}
