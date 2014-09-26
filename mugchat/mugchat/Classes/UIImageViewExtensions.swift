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

let THUMBNAIL_BORDER_WIDTH : CGFloat = 1
private let A1_AVATAR_SIZE = 200 + THUMBNAIL_BORDER_WIDTH
private let A2_AVATAR_SIZE = 90 + THUMBNAIL_BORDER_WIDTH
private let A3_AVATAR_SIZE = 50 + THUMBNAIL_BORDER_WIDTH
private let A4_AVATAR_SIZE = 40 + THUMBNAIL_BORDER_WIDTH

extension UIImageView {
    
    class func avatarA1() -> UIImageView {
        return createImageView(CGRectMake(0, 0, A1_AVATAR_SIZE, A1_AVATAR_SIZE))
    }

    class func avatarA2() -> UIImageView {
        return createImageView(CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE))
    }
    
    class func avatarA3() -> UIImageView {
        return createImageView(CGRectMake(0, 0, A3_AVATAR_SIZE, A3_AVATAR_SIZE))
    }
    
    class func avatarA4() -> UIImageView {
        return createImageView(CGRectMake(0, 0, A4_AVATAR_SIZE, A4_AVATAR_SIZE))
    }
    
    private class func createImageView(frame: CGRect) -> UIImageView {
        var imageView = UIImageView(frame: frame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor.whiteColor().CGColor
        imageView.layer.borderWidth = THUMBNAIL_BORDER_WIDTH

        return imageView
    }
}