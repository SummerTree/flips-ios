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

class TopBorderedView: UIView {
    
    var topBorderLayer = CALayer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        borderSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        borderSetup()
    }
    
    func borderSetup() {
        topBorderLayer.backgroundColor = UIColor.lightGreyF2().CGColor
        layer.addSublayer(topBorderLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBorderLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame), 1.0)
    }
}