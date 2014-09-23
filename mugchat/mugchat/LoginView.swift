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

let BACKGROUND_COLOR = UInt(0xED625F)

class LoginView : UIView {
    
    var bubbleChat: UIImageView!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor(RRGGBB: BACKGROUND_COLOR)
        addSubviews()
        makeContraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func addSubviews() {
        bubbleChat = UIImageView(image: UIImage(named: "ChatBubble"))
        self.addSubview(bubbleChat)
    }
    
    func makeContraints() {
        bubbleChat.mas_makeConstraints { (maker) -> Void in
            maker.centerX.equalTo()(self)
            maker.top.equalTo()(self).with().offset()(22)
            return ()
        }
    }
}