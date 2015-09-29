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

enum BubbleType {
    case arrowUp
    case arrowDownFirstLineBold
    case arrowDownSecondLineBold
}

class BubbleView: UIView {
    
    private let BUBBLE_HORIZONTAL_MARGIN: CGFloat = 16
    
    private var bubbleImageView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!
   
    private var title: String!
    private var message: String!
    private var bubbleType: BubbleType!
    
    private let bubbleImage = UIImage(named: "tutorial_bubble")

    
    // MARK: - Initialization Methods
    
    init(title: String, message: String, bubbleType: BubbleType) {
        super.init(frame: CGRectZero)
        self.title = title
        self.message = message
        self.bubbleType = bubbleType
        
        self.addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View methods
    
    private func addSubviews() {
        bubbleImageView = UIImageView(image: bubbleImage)
        bubbleImageView.sizeToFit()
        
        if (self.bubbleType == BubbleType.arrowUp) {
            let fullRotation = CGFloat(M_PI)
            bubbleImageView.transform = CGAffineTransformMakeRotation(fullRotation)
        }
        
        self.addSubview(bubbleImageView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h4)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.title
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.numberOfLines = 1
        self.addSubview(titleLabel)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.text = self.message
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.numberOfLines = 2
        self.addSubview(messageLabel)
    }
    
    
    // MARK: - Overridden Methods
    
    override func updateConstraints() {
        titleLabel.sizeToFit()
        messageLabel.sizeToFit()
        
        bubbleImageView.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.top.equalTo()(self)
            update.centerX.equalTo()(self)
            update.width.equalTo()(self.bubbleImage!.size.width)
            update.height.equalTo()(self.bubbleImage!.size.height)
        }

        let marginFromCenter: CGFloat = 5
        
        titleLabel.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.bottom.equalTo()(self.mas_centerY).with().offset()(-marginFromCenter)
            update.height.equalTo()(self.titleLabel.frame.size.height)
            update.left.equalTo()(self.bubbleImageView).with().offset()(self.BUBBLE_HORIZONTAL_MARGIN)
            update.right.equalTo()(self.bubbleImageView).with().offset()(-self.BUBBLE_HORIZONTAL_MARGIN)
        }
        
        messageLabel.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.top.equalTo()(self.mas_centerY).with().offset()(marginFromCenter)
            update.height.equalTo()(self.messageLabel.frame.size.height)
            update.left.equalTo()(self.bubbleImageView).with().offset()(self.BUBBLE_HORIZONTAL_MARGIN)
            update.right.equalTo()(self.bubbleImageView).with().offset()(-self.BUBBLE_HORIZONTAL_MARGIN)
        }
        
        super.updateConstraints()
    }
    
    func getHeight() -> CGFloat {
        return bubbleImage!.size.height
    }
    
    func getWidth() -> CGFloat {
        return bubbleImage!.size.width
    }
 }