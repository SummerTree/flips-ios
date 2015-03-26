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


extension UIButton {
    
    class func avatarA1(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A1_AVATAR_SIZE, A1_AVATAR_SIZE), borderWidth: A1_BORDER_WIDTH, image: image)
    }
    
    class func avatarA2(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE), borderWidth: A2_BORDER_WIDTH, image: image)
    }
    
    class func avatarA2WithoutBorder(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE), borderWidth: 0.0, image: image)
    }
    
    class func avatarA3(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A3_AVATAR_SIZE, A3_AVATAR_SIZE), borderWidth: A3_BORDER_WIDTH, image: image)
    }
    
    class func avatarA4(image: UIImage) -> UIButton {
        return UIButton(frame: CGRectMake(0, 0, A4_AVATAR_SIZE, A4_AVATAR_SIZE), borderWidth: A4_BORDER_WIDTH, image: image)
    }
    
    convenience init(frame: CGRect, borderWidth: CGFloat, image: UIImage) {
        self.init(frame: frame)
        self.setBackgroundImage(image, forState: UIControlState.Normal)

        self.contentMode = UIViewContentMode.ScaleAspectFit
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = borderWidth
    }
    
    func setAvatarImage(image: UIImage, forStates states: [UIControlState]) {
        var resizedImage = image.cropSquareImage(UIScreen.mainScreen().scale*self.frame.size.width)
        for state in states {
            self.setImage(resizedImage, forState: state)
        }
    }
    
    func setLastCameraPhotoAsButtonImage() {
        GalleryAssetsHelper.sharedInstance.addThumbnailToButton(self)
    }
    
    func setImage(image: UIImage, verticallyAlignedWithTitle title: String) {
        self.setTitle(title, forState: UIControlState.Normal)
        self.setImage(image, forState: UIControlState.Normal)
        
        let size: CGSize = CGSizeMake(480, 480)
        let attributes: Dictionary = [NSFontAttributeName : self.titleLabel!.font]
        var textSize: CGRect = title.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: NSStringDrawingContext())
        
        self.imageEdgeInsets.top = -(image.size.height)
        self.imageEdgeInsets.left = textSize.size.width
        self.titleEdgeInsets.top = image.size.height
        self.titleEdgeInsets.left = -(image.size.width)
    }
}
