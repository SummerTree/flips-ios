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

class MugText : UIView {
    
    private var mugText : String!
    private var status : String? //TODO: create enum
    
    var mugButton: UIButton!
    var extrasView: UIView? // "(...)"
    
    
    // MARK: - Initialization Methods
    
    convenience init(mugText : String, status : String) {
        self.init(frame: CGRect.zeroRect)
        
        self.mugText = mugText
        self.status = status
        
        self.initSubviews()
        
        //self.updateConstraintsIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        //self.innerView = UIView()
        //self.innerView.sizeToFit()
        
        mugButton = UIButton()
        //mugButton.addTarget(self, action: "mugButtonTapped:", forControlEvents: .TouchUpInside)
        mugButton.layer.borderWidth = 1.0
        mugButton.layer.borderColor = UIColor.avacado().CGColor
        mugButton.layer.cornerRadius = 14.0
        mugButton.setTitle(self.mugText, forState: UIControlState.Normal)
        mugButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        mugButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)

        mugButton.sizeToFit()
        
        //self.backgroundColor = UIColor.yellowColor()
        self.sizeToFit()
        
        self.addSubview(self.mugButton)
        
        mugButton?.mas_makeConstraints { (make) -> Void in
//            make.centerX.equalTo()(self)
//            make.centerY.equalTo()(self)
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)

        }
    }
    
}