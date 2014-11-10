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

import Foundation

extension UIFont {
    
    class func avenirNextUltraLight(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-UltraLight", size: size)!
    }
    
    class func avenirNextRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
    
    class func avenirNextMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    
    class func avenirNextDemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-DemiBold", size: size)!
    }
    
    class func avenirNextBold(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size)!
    }
    
    class func flipLabelFont() -> UIFont {
        return UIFont.avenirNextBold(UIFont.HeadingSize.h1)
    }
    
    struct HeadingSize {
        static var h1:CGFloat = 32.0
        static var h2:CGFloat = 18.0
        static var h3:CGFloat = 17.0
        static var h4:CGFloat = 16.0
        static var h5:CGFloat = 14.0
        static var h6:CGFloat = 12.0
        static var h7:CGFloat = 10.0
    }
    
    class func headingSize1() -> CGFloat {
        return HeadingSize.h1
    }
}