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

import Foundation

class CustomBadgeView : UIView {

    let CUSTOM_BADGE_VIEW_TAG = 222

    private let BADGE_SIZE : CGFloat = 25

    var badgeLabel : UILabel!
    
    
    //MARK: - Initialization Methods
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let badgeBackgroundImage = UIImage(named: "Notification")
        
        self.frame = CGRectMake(0, 0, badgeBackgroundImage!.size.width, badgeBackgroundImage!.size.height)

        let backgroundImageView = UIImageView(image: badgeBackgroundImage)
        backgroundImageView.sizeToFit()
        self.addSubview(backgroundImageView)

        badgeLabel = UILabel()
        badgeLabel.textAlignment = .Center
        badgeLabel.textColor = UIColor.whiteColor()
        badgeLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h5)
        self.addSubview(badgeLabel)
        
        badgeLabel.mas_updateConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
    }

    
    //MARK: - Setters Methods
    
    func setBagdeValue(value: String) {
        badgeLabel.text = value
    }
}