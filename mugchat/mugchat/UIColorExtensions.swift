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
import UIKit

extension UIColor {
    
    convenience init(RRGGBB: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((RRGGBB & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((RRGGBB & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(RRGGBB & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    convenience init(RRGGBB: UInt) {
        self.init(
            red: CGFloat((RRGGBB & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((RRGGBB & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(RRGGBB & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    // MARK: Primary Colors
    class func mugOrange() -> UIColor {
        return UIColor(RRGGBB: UInt(0xEC7061))
    }
    
    class func plum() -> UIColor {
        return UIColor(RRGGBB: UInt(0x713454))
    }
    
    class func banana() -> UIColor {
        return UIColor(RRGGBB: UInt(0xFFD458))
    }
    
    class func deepSea() -> UIColor {
        return UIColor(RRGGBB: UInt(0x3F5666))
    }
    
    class func avacado() -> UIColor {
        return UIColor(RRGGBB: UInt(0x88BF4C))
    }
    
    // MARK: Secondary Colors
    
    class func sand() -> UIColor {
        return UIColor(RRGGBB: UInt(0xF8F8F6))
    }
    
    class func lightGreyF2() -> UIColor {
        return UIColor(RRGGBB: UInt(0xF2F2F2))
    }
    
    class func lightGreyD8() -> UIColor {
        return UIColor(RRGGBB: UInt(0xD8D8D8))
    }
    
    class func mediumGray() -> UIColor {
        return UIColor(RRGGBB: UInt(0x9B9B9B))
    }
    
    class func darkGray() -> UIColor {
        return UIColor(RRGGBB: UInt(0x4A4A4A))
    }
    
    // MARK: Components
    class func darkBackground() -> UIColor {
        return deepSea()
    }
    
    class func mugOrangeBackground() -> UIColor {
        return mugOrange()
    }
    
    class func lightBackground() -> UIColor {
        return UIColor.whiteColor()
    }
}