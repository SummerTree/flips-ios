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

let CUSTOM_BADGE_VIEW_TAG = 222
private let BADGE_SIZE = 25 + THUMBNAIL_BORDER_WIDTH

class CustomBadgeView : UIView {
    
    var badgeLabel : UILabel!
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.frame = CGRectMake(0, 0, BADGE_SIZE, BADGE_SIZE)
        self.backgroundColor = UIColor.redColor()
        self.tag = CUSTOM_BADGE_VIEW_TAG;
        self.layer.cornerRadius = BADGE_SIZE / 2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = THUMBNAIL_BORDER_WIDTH
        self.clipsToBounds = true

        badgeLabel = UILabel()
        badgeLabel.textAlignment = .Center
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h5)
        self.addSubview(badgeLabel)
        
        badgeLabel.mas_updateConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.leading.equalTo()(self).with().offset()(THUMBNAIL_BORDER_WIDTH)
            make.trailing.equalTo()(self).with().offset()(-THUMBNAIL_BORDER_WIDTH)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBagdeValue(value : String) {
        badgeLabel.text = value
        self.layoutIfNeeded()
    }
}