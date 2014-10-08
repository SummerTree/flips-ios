//
//  UIImageExtensions.swift
//  mugchat
//
//  Created by Bruno Bruggemann on 10/8/14.
//
//

extension UIImage {

    func squareImageWithSize(newSize: CGFloat) -> UIImage {
        var scaleTransform: CGAffineTransform!
        var origin: CGPoint!
        
        if (self.size.width > self.size.height) {
            var scaleRatio = newSize / self.size.height
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
            origin = CGPointMake(-(self.size.width - self.size.height) / 2.0, 0)
        } else {
            var scaleRatio = newSize / self.size.width
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
            origin = CGPointMake(0, -(self.size.height - self.size.width) / 2.0)
        }
        
        var size = CGSizeMake(newSize, newSize)
        if (UIScreen.mainScreen().respondsToSelector("scale")) {
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        
        var context = UIGraphicsGetCurrentContext()
        CGContextConcatCTM(context, scaleTransform)
        
        self.drawAtPoint(origin)
        
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
//    - (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
//    CGAffineTransform scaleTransform;
//    CGPoint origin;
//    
//    if (image.size.width > image.size.height) {
//    CGFloat scaleRatio = newSize / image.size.height;
//    scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
//    
//    origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
//    } else {
//    CGFloat scaleRatio = newSize / image.size.width;
//    scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
//    
//    origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
//    }
//    
//    CGSize size = CGSizeMake(newSize, newSize);
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
//    } else {
//    UIGraphicsBeginImageContext(size);
//    }
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextConcatCTM(context, scaleTransform);
//    
//    [image drawAtPoint:origin];
//    
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return image;
//    }}
