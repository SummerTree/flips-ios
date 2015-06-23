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

class NextButton: UIButton {

    convenience init() {
        self.init()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        titleLabel?.font = .avenirNextDemiBold(UIFont.HeadingSize.h4)
        setTitle(NSLocalizedString("Next", comment: "Next"), forState: .Normal)
        setTitleColor(UIColor.darkGray(), forState: .Normal)
        setTitleColor(UIColor.mediumGray(), forState: .Disabled)
    }
}
