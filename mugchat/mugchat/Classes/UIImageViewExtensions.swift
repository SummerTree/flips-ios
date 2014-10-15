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

let A1_BORDER_WIDTH : CGFloat = 3
let A1_AVATAR_SIZE = 200 + A1_BORDER_WIDTH
let A2_BORDER_WIDTH : CGFloat = 3
let A2_AVATAR_SIZE = 90 + A2_BORDER_WIDTH
let A3_BORDER_WIDTH : CGFloat = 2
let A3_AVATAR_SIZE = 50 + A3_BORDER_WIDTH
let A4_BORDER_WIDTH : CGFloat = 2
let A4_AVATAR_SIZE = 40 + A4_BORDER_WIDTH

extension UIImageView {
    
    class func avatarA1() -> UIImageView {
        return UIImageView(frame: CGRectMake(0, 0, A1_AVATAR_SIZE, A1_AVATAR_SIZE), borderWidth: A1_BORDER_WIDTH)
    }

    class func avatarA2() -> UIImageView {
        return UIImageView(frame: CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE), borderWidth: A2_BORDER_WIDTH)
    }
    
    class func avatarA3() -> UIImageView {
        return UIImageView(frame: CGRectMake(0, 0, A3_AVATAR_SIZE, A3_AVATAR_SIZE), borderWidth: A3_BORDER_WIDTH)
    }
    
    class func avatarA4() -> UIImageView {
        return UIImageView(frame: CGRectMake(0, 0, A4_AVATAR_SIZE, A4_AVATAR_SIZE), borderWidth: A4_BORDER_WIDTH)
    }
    
    convenience init(frame: CGRect, borderWidth : CGFloat) {
        self.init(frame: frame)
        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        self.clipsToBounds = true
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = borderWidth
    }
    
    func setAvatarImage(image: UIImage) {
        if ((image.size.width > self.frame.size.width) || (image.size.height > self.frame.size.height)) {
            var resizedImage = image.resizedImageWithWidth(self.frame.size.width, andHeight: self.frame.size.height)
            self.image = resizedImage
        } else {
            self.image = image
        }
    }
}