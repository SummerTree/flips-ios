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

private let kThumbnailImageSize: CGFloat = 480

extension UIImage {
    
    func cropSquareImage(squareSize: CGFloat) -> UIImage {
        var transform:CGAffineTransform = CGAffineTransformIdentity

        let width = CGFloat(CGImageGetWidth(self.CGImage))
        let height = CGFloat(CGImageGetHeight(self.CGImage))
        let size = min(width, height)
        let scale = squareSize / size
        
        let cropX = (width - size) / 2
        let cropY = (height - size) / 2
        
        if (self.imageOrientation == UIImageOrientation.Up
            || self.imageOrientation == UIImageOrientation.UpMirrored) {
            
                transform = CGAffineTransformTranslate(transform, -cropX, -cropY)
        }

        if (self.imageOrientation == UIImageOrientation.Down
            || self.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, -cropX, -cropY)
                transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
        }
        
        if (self.imageOrientation == UIImageOrientation.Left
            || self.imageOrientation == UIImageOrientation.LeftMirrored) {
                
                transform = CGAffineTransformTranslate(transform, -cropY, -cropX)
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
        }
        
        if (self.imageOrientation == UIImageOrientation.Right
            || self.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, -cropY, -cropX)
                transform = CGAffineTransformTranslate(transform, 0, self.size.height)
                transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2))
        }
        
        if (self.imageOrientation == UIImageOrientation.UpMirrored
            || self.imageOrientation == UIImageOrientation.DownMirrored) {
                
                transform = CGAffineTransformTranslate(transform, self.size.width, 0)
                transform = CGAffineTransformScale(transform, -1, 1)
        }
        
        if (self.imageOrientation == UIImageOrientation.LeftMirrored
            || self.imageOrientation == UIImageOrientation.RightMirrored) {
                
                transform = CGAffineTransformTranslate(transform, self.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
        }
        
        let bitmapInfo = self.normalizeBitmapInfo(CGImageGetBitmapInfo(self.CGImage))
        
        let ctx:CGContextRef = CGBitmapContextCreate(nil, Int(squareSize), Int(squareSize),
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            bitmapInfo.rawValue)!
        
        CGContextScaleCTM(ctx, scale, scale)
        CGContextConcatCTM(ctx, transform)
        CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), self.CGImage)

        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg!, scale: 1.0, orientation: UIImageOrientation.Up)
        
        return img
    }

    func cropSquareThumbnail() -> UIImage {
        return self.cropSquareImage(kThumbnailImageSize)
    }
    
    // Used by the take a picture
    func avatarA1Image(cropRectFrameInView: CGRect) -> UIImage {
        let avatarImageSize = A1_AVATAR_SIZE - A1_BORDER_WIDTH
        return self.cropSquareImage(avatarImageSize)
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        return UIImage.imageWithColor(color, size: CGSizeMake(1.0, 1.0))
    }

    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    class func emptyFlipImage() -> UIImage {
//        return UIImage.imageWithColor(UIColor.avacado())
        return UIImage(named: "Empty_Flip_Thumbnail")!
    }
}

