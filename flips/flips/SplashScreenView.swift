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

import UIKit

class SplashScreenView: UIView {
    
    private let MARGIN_RIGHT:CGFloat = 40.0
    private let MARGIN_LEFT:CGFloat = 40.0
    private let FLIPS_WORD_LOGO_MARGIN_TOP: CGFloat = 15.0
    
    private var logoView: UIView!
    private var bubbleChatImageView: UIImageView!
    private var flipsWordImageView: UIImageView!
    
    // MARK: - Required inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.flipOrangeBackground()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func addSubviews() {
        
        logoView = UIView()
        self.addSubview(logoView)
        
        bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        bubbleChatImageView.sizeToFit()
        bubbleChatImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(bubbleChatImageView)
        
        flipsWordImageView = UIImageView(image: UIImage(named: "FlipWord"))
        flipsWordImageView.sizeToFit()
        flipsWordImageView.contentMode = UIViewContentMode.Center
        logoView.addSubview(flipsWordImageView)
    }
    
    func makeConstraints() {
        
        logoView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.left.equalTo()(self).with().offset()(self.MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MARGIN_RIGHT)
            make.top.equalTo()(self.bubbleChatImageView)
            make.bottom.equalTo()(self.flipsWordImageView)
        }
        
        bubbleChatImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.logoView)
            make.height.equalTo()(self.bubbleChatImageView.frame.size.height)
            make.left.equalTo()(self.logoView)
            make.right.equalTo()(self.logoView)
        }
        
        flipsWordImageView.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.logoView)
            make.top.equalTo()(self.bubbleChatImageView.mas_bottom).with().offset()(self.FLIPS_WORD_LOGO_MARGIN_TOP)
            make.left.equalTo()(self.logoView)
            make.right.equalTo()(self.logoView)
            make.bottom.equalTo()(self.logoView)
            make.height.equalTo()(self.flipsWordImageView.frame.height)
        }

    }

}
