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

class BubbleView: UIView {
    
    private let BUBBLE_VERTICAL_MARGIN_WITH_ARROW: CGFloat = 24
    private let BUBBLE_VERTICAL_MARGIN_WITHOUT_ARROW: CGFloat = 16
    private let BUBBLE_HORIZONTAL_MARGIN: CGFloat = 16
    
    private var bubbleImageView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!
   
    private var title: String!
    private var message: String!
    private var isBubbleUpsideDown: Bool = false
    
    // MARK: - Initialization Methods
    
    init(title: String, message: String, isUpsideDown: Bool) {
        super.init(frame: CGRectZero)
        self.title = title
        self.message = message
        self.isBubbleUpsideDown = isUpsideDown
        
        self.addSubviews()
        self.backgroundColor = UIColor.greenColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View methods
    
    private func addSubviews() {
        bubbleImageView = UIImageView(image: UIImage(named: "tutorial_bubble"))
        bubbleImageView.sizeToFit()
        
        if (self.isBubbleUpsideDown) {
            let fullRotation = CGFloat(M_PI)
            bubbleImageView.transform = CGAffineTransformMakeRotation(fullRotation)
        }
        
        self.addSubview(bubbleImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h4)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.title
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 2
        self.addSubview(titleLabel)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.text = self.message
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.numberOfLines = 4
        self.addSubview(messageLabel)
    }
    
    
    // MARK: - Overridden Methods
    
    override func updateConstraints() {
        titleLabel.sizeToFit()
        messageLabel.sizeToFit()

        bubbleImageView.mas_updateConstraints { (update) -> Void in
            update.top.equalTo()(self)
            update.centerX.equalTo()(self)
            update.width.equalTo()(self.bubbleImageView.frame.size.width)
            update.height.equalTo()(self.bubbleImageView.frame.size.height)
        }

        var topMargin, bottomMargin: CGFloat!
        if (isBubbleUpsideDown) {
            topMargin = BUBBLE_VERTICAL_MARGIN_WITH_ARROW
            bottomMargin = BUBBLE_VERTICAL_MARGIN_WITHOUT_ARROW
        } else {
            topMargin = BUBBLE_VERTICAL_MARGIN_WITHOUT_ARROW
            bottomMargin = BUBBLE_VERTICAL_MARGIN_WITH_ARROW
        }
        
        titleLabel.mas_makeConstraints { (update) -> Void in
            update.top.equalTo()(self).with().offset()(topMargin)
            update.height.equalTo()(self.titleLabel.frame.size.height)
            update.left.equalTo()(self.bubbleImageView).with().offset()(self.BUBBLE_HORIZONTAL_MARGIN)
            update.right.equalTo()(self.bubbleImageView).with().offset()(-self.BUBBLE_HORIZONTAL_MARGIN)
        }
        
        messageLabel.mas_makeConstraints { (update) -> Void in
            update.top.equalTo()(self.titleLabel.mas_bottom)
            update.height.equalTo()(self).with().offset()(bottomMargin)
            update.left.equalTo()(self.bubbleImageView).with().offset()(self.BUBBLE_HORIZONTAL_MARGIN)
            update.right.equalTo()(self.bubbleImageView).with().offset()(-self.BUBBLE_HORIZONTAL_MARGIN)
        }
        
        super.updateConstraints()
    }
}