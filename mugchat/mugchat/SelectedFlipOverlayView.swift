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

class SelectedFlipOverlayView : UIView {
    
    var checkImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        
        self.backgroundColor = UIColor.darkGray().colorWithAlphaComponent(0.8)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        var checkImage : UIImage = UIImage(named: "Check")!
        checkImageView = UIImageView(image: checkImage)
        self.addSubview(checkImageView)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        checkImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.width.equalTo()(self.checkImageView.frame.size.width/2)
            make.height.equalTo()(self.checkImageView.frame.size.height/2)
        }
    }
    
}
