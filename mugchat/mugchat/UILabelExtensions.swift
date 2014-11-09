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

let FLIP_WORD_LABEL_MARGIN_BOTTOM: CGFloat = -40

extension UILabel {
    
    class func flipWordLabel() -> UILabel {
        var flipWordLabel = UILabel()
        flipWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        flipWordLabel.textColor = UIColor.whiteColor()
        flipWordLabel.layer.shadowColor = UIColor.blackColor().CGColor
        flipWordLabel.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        return flipWordLabel
    }
}