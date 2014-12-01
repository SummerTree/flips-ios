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

class NotificationMessageView : UIView {
    
    private let LABEL_AREA_HEIGHT: CGFloat = 75
    
    private var messageContainerView: UIView!
    private var messageLabel: UILabel!
    private var message: String!
    
    var delegate: NotificationMessageViewDelegate?
    
    // MARK: - Initialization Methods
    
    init(message: String) {
        super.init(frame: CGRect.zeroRect)
        self.message = message
        self.initSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        
        messageContainerView = UIView()
        messageContainerView.backgroundColor = UIColor.whiteColor()
        self.addSubview(messageContainerView)
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        messageLabel.textColor = UIColor.flipOrange()
        messageLabel.textAlignment = NSTextAlignment.Center
        messageLabel.text = self.message
        messageLabel.sizeToFit()
        messageContainerView.addSubview(messageLabel)
    }
    
    
    // MARK: - Overridden Method
    
    override func updateConstraints() {
        super.updateConstraints()
        
        messageContainerView.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.top.equalTo()(self)
            update.leading.equalTo()(self)
            update.trailing.equalTo()(self)
            update.height.equalTo()(self.LABEL_AREA_HEIGHT)
        }
        
        messageLabel.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.center.equalTo()(self.messageContainerView)
            update.size.equalTo()(self.messageLabel)
        }
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        // Passing all touches to the next view (if any), in the view stack.
        delegate?.notificationMessageViewShouldBeDismissed(self)
        return false
    }
    
    
    // MARK: - Getters
    
    func getMessageAreaHeight() -> CGFloat {
        return LABEL_AREA_HEIGHT
    }
}