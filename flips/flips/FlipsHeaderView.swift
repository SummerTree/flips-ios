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


class FlipsHeaderView : UICollectionReusableView {
    
    var label: UILabel!
    
    override init() {
        super.init()
        self.addSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        label = UILabel()
        label.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h3)
        label.textColor = UIColor.plum()
        self.addSubview(label)
        
        label.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
        }
    }
    
    func setTitle(title: String) {
        label.text = title
        label.sizeToFit()
    }
}