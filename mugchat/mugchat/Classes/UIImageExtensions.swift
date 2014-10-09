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

extension UIImage {

    func cropImageToRect(rect: CGRect) -> UIImage {
        var scaledRect = CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale, rect.width * self.scale, rect.height * self.scale)
        var imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledRect)
        var croppedImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
    
    func resizedImageWithWidth(width: CGFloat, andHeight height: CGFloat) -> UIImage {
        var newSize = CGSizeMake(width, height)
        var widthRatio = newSize.width / self.size.width
        var heightRatio = newSize.height / self.size.height
        
        if (widthRatio > heightRatio) {
            newSize = CGSizeMake(self.size.width * heightRatio, self.size.height * heightRatio)
        } else {
            newSize=CGSizeMake(self.size.width * widthRatio, self.size.height * widthRatio)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func avararA1Image(cropRectFrameInView: CGRect) -> UIImage {
        // Resize to device size. So we are sure that we will crop correctly
        var screenWidth = UIScreen.mainScreen().bounds.width
        var screenHeight = UIScreen.mainScreen().bounds.height
        var resizedImage = self.resizedImageWithWidth(screenWidth, andHeight: screenHeight)

        // We need the squared image to know exactly where we should crop
        var squaredImage = resizedImage.cropImageToRect(cropRectFrameInView)

        var avatarImageSize = A1_AVATAR_SIZE - A1_BORDER_WIDTH
        if ((squaredImage.size.width > avatarImageSize) || (squaredImage.size.height > avatarImageSize)) {
            var cropX = (squaredImage.size.width / 2) - (avatarImageSize / 2)
            var cropY = (squaredImage.size.height / 2) - (avatarImageSize / 2)
            var cropRect = CGRectMake(cropX, cropY, avatarImageSize, avatarImageSize)
            var croppedImage = squaredImage.cropImageToRect(cropRect)
            
            return croppedImage
        } else {
            return squaredImage
        }
    }
}

