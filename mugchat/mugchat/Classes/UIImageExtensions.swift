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

private let REFERENCE_SCREEN_WIDTH: CGFloat = 320

enum UIImageSource : Int {
    case Unknown
    case FrontCamera
    case BackCamera
}

extension UIImage {
    
    private func rad(deg: Double) -> CGFloat {
        var result = deg / 180.0 * M_PI
        return CGFloat(result)
    }

    private func cropImageToRect(rect: CGRect) -> UIImage {
        var rectTransform: CGAffineTransform

        switch (self.imageOrientation) {
        case UIImageOrientation.Left:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(self.rad(90)), 0, -self.size.height)
            break
        case UIImageOrientation.Right:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(self.rad(-90)), -self.size.width, 0)
            break
        case UIImageOrientation.Down:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(self.rad(-180)), -self.size.width, -self.size.height)
            break
        default:
            rectTransform = CGAffineTransformIdentity
            break
        }

        rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale)

        var imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectApplyAffineTransform(rect, rectTransform));
        var croppedImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        return croppedImage!
    }

    private func cropFromFrontCamera() -> UIImage {
        let rect = self.cropRectangle()

        let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        let center = CGAffineTransformMakeTranslation(0, -self.size.width)
        let mirror = CGAffineTransformMakeScale(0.0, -1.0)

        let width = self.size.height
        let height = self.size.width

        UIGraphicsBeginImageContext(rect.size)

        let context = UIGraphicsGetCurrentContext()

        CGContextConcatCTM(context, rotate)
        CGContextConcatCTM(context, center)

        var xOffset = (rect.size.width - width) / 2
        var yOffset = (rect.size.height - height) / 2

        CGContextDrawImage(context, CGRectMake(xOffset, yOffset, width, height), self.CGImage)

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return croppedImage!

    }

    private func cropFromBackCamera() -> UIImage {
        let croppedMirroredImage = self.cropFromFrontCamera()

        UIGraphicsBeginImageContext(croppedMirroredImage.size)

        let context = UIGraphicsGetCurrentContext()

        let center = CGAffineTransformMakeTranslation(-croppedMirroredImage.size.width, -croppedMirroredImage.size.height)
        let mirror = CGAffineTransformMakeScale(-1.0, -1.0)

        CGContextConcatCTM(context, mirror)
        CGContextConcatCTM(context, center)

        CGContextDrawImage(context, CGRectMake(0, 0, croppedMirroredImage.size.width, croppedMirroredImage.size.height), croppedMirroredImage.CGImage)

        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        
        return croppedImage!
    }

    func squareCrop(imageSource: UIImageSource) -> UIImage {
        switch imageSource {
        case UIImageSource.FrontCamera:
            return cropFromFrontCamera()
        case UIImageSource.BackCamera:
            return cropFromBackCamera()
        case UIImageSource.Unknown:
            return self.cropImageInCenter()
        }
    }

    private func cropRectangle() -> CGRect {
        var squaredRect : CGRect
        if (self.size.width > self.size.height) {
            var cropX = (self.size.width / 2) - (self.size.height / 2)
            squaredRect = CGRectMake(cropX, 0, self.size.height, self.size.height)
        } else {
            var cropY = (self.size.height / 2) - (self.size.width / 2)
            squaredRect = CGRectMake(0, cropY, self.size.width, self.size.width)
        }

        return squaredRect
    }

    private func cropImageInCenter() -> UIImage {
        return self.cropImageToRect(self.cropRectangle())
    }
    
    func resizedImageWithWidth(width: CGFloat, andHeight height: CGFloat) -> UIImage {
        var newSize = CGSizeMake(width, height)
        var widthRatio = newSize.width / self.size.width
        var heightRatio = newSize.height / self.size.height
        
        newSize = CGSizeMake(self.size.width * widthRatio, self.size.height * widthRatio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // Used by the take a picture
    func avatarA1Image(cropRectFrameInView: CGRect) -> UIImage {
        // Resize to device size. So we are sure that we will crop correctly
        var screenWidth = UIScreen.mainScreen().bounds.width
        var screenHeight = UIScreen.mainScreen().bounds.height
        var resizedImage = self.resizedImageWithWidth(screenWidth, andHeight: screenHeight)

        var avatarImageSize = A1_AVATAR_SIZE - A1_BORDER_WIDTH
        if ((resizedImage.size.width > avatarImageSize) || (resizedImage.size.height > avatarImageSize)) {
            var cropX = (resizedImage.size.width / 2) - (avatarImageSize / 2)
            var cropY = (resizedImage.size.height / 2) - (avatarImageSize / 2)
            var cropRect = CGRectMake(cropX, cropY, avatarImageSize, avatarImageSize)
            var croppedImage = resizedImage.cropImageToRect(cropRect)
            
            return croppedImage
        } else {
            var squaredImage = resizedImage.cropImageToRect(cropRectFrameInView)

            return squaredImage
        }
    }
    
    func avatarProportional() -> UIImage {
        var expectedImageWidth = REFERENCE_SCREEN_WIDTH
        if (self.size.width > expectedImageWidth) {
            var expectedCropSize = A1_AVATAR_SIZE - A1_BORDER_WIDTH
            
            var proportionalCropSize = expectedCropSize * self.size.width / expectedImageWidth
            
            var cropX : CGFloat = (self.size.width / 2) - (proportionalCropSize / 2)
            var cropY : CGFloat = (self.size.height / 2) - (proportionalCropSize / 2)
            var cropRect = CGRectMake( ceil(cropX), ceil(cropY), proportionalCropSize, proportionalCropSize)
            
            return self.cropImageToRect(cropRect)
        } else {
            return self
        }
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
        return UIImage.imageWithColor(UIColor.avacado())
    }
}

