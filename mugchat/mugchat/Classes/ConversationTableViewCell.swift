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

// TODO: will be removed - just for test
struct InboxItem {
    var userName : String
    var mugMessage : String
    var notReadMessages : Int
    var mugTime : String
}

class ConversationTableViewCell : UITableViewCell {
    
    private let CELL_MUG_IMAGE_VIEW_HEIGHT = 112.5
    private let CELL_INFO_VIEW_HEIGHT = 56
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    private let DRAG_ANIMATION_DURATION = 0.25
    private let DELETE_BUTTON_WIDTH = 110.0
    
    // TODO: will be removed - just for test
    var item : InboxItem!
    
    // private var deleteButton : UIButton! // TODO: probably, it will be removed. But I want to keep track of it, because the client didn't decide if we need to do it or no. So I need to commit it at least one time :P
    private var mugImageView : UIImageView!
    private var userImageView : UIImageView!
    private var infoView : UIView!
    private var userNameLabel : UILabel!
    private var mugMessageLabel : UILabel!
    private var mugTimeLabel : UILabel!
    private var badgeView : CustomBadgeView!
    private var highlightedView : UIView!
    
    
    // MARK: - Init Methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // TODO: probably will be remove with the deleteButton declaration
        //        deleteButton = UIButton()
        //        deleteButton.setImage(UIImage(named: "Delete"), forState: .Normal)
        //        deleteButton.backgroundColor = UIColor.deepSea()
        //        deleteButton.addTarget(self, action: "deleteButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        mugImageView = UIImageView()
        userImageView = UIImageView.avatarA3()
        
        infoView = UIView()
        
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        userNameLabel.textColor = UIColor.deepSea()
        userNameLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        userNameLabel.setContentHuggingPriority(249, forAxis: .Horizontal)
        userNameLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
        
        mugMessageLabel = UILabel()
        mugMessageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        mugMessageLabel.textColor = UIColor.deepSea()
        mugMessageLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        
        mugTimeLabel = UILabel()
        mugTimeLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        mugTimeLabel.textColor = UIColor.deepSea()
        mugTimeLabel.textAlignment = .Right
        mugTimeLabel.setContentHuggingPriority(999, forAxis: .Horizontal)
        
        badgeView = CustomBadgeView()
        
        highlightedView = UIView()
        highlightedView.userInteractionEnabled = false
        highlightedView.backgroundColor = UIColor.lightGreyD8()
        highlightedView.alpha = 0.4
        highlightedView.hidden = true
        
        self.addSubviews()
        
        self.updateConstraintsIfNeeded()
        
        // TODO: probably will be remove with the deleteButton
        // var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        // self.cellContainerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    func addSubviews() {
        // TODO: probably will be remove with the deleteButton
        // self.addSubview(deleteButton)
        
        contentView.addSubview(mugImageView)
        contentView.addSubview(infoView)
        contentView.addSubview(userImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(highlightedView)
        
        infoView.addSubview(mugMessageLabel)
        infoView.addSubview(userNameLabel)
        infoView.addSubview(mugTimeLabel)
    }
    
    
    // MARK: - Overridden methods
    
    override func updateConstraints() {
        
        // TODO: probably will be remove with the deleteButton
        //        deleteButton.mas_updateConstraints { (make) -> Void in
        //            make.top.equalTo()(self)
        //            make.bottom.equalTo()(self)
        //            make.trailing.equalTo()(self)
        //            make.width.equalTo()(self.DELETE_BUTTON_WIDTH)
        //        }
        
        mugImageView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.height.equalTo()(self.CELL_MUG_IMAGE_VIEW_HEIGHT)
            make.leading.equalTo()(self.contentView)
            make.trailing.equalTo()(self.contentView)
        }
        mugImageView.backgroundColor = UIColor.greenColor()
        
        userImageView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.contentView).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.mugImageView.mas_bottom)
            make.width.equalTo()(self.userImageView.frame.size.width)
            make.height.equalTo()(self.userImageView.frame.size.height)
        }
        
        badgeView.mas_updateConstraints { (make) -> Void in
            make.bottom.equalTo()(self.userImageView.mas_centerY)
            make.leading.equalTo()(self.userImageView.mas_centerX)
            make.width.equalTo()(self.badgeView.frame.size.width)
            make.height.equalTo()(self.badgeView.frame.size.height)
        }
        
        infoView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.userImageView.mas_trailing).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.trailing.equalTo()(self.contentView)
            make.top.equalTo()(self.mugImageView.mas_bottom)
            make.height.equalTo()(self.CELL_INFO_VIEW_HEIGHT)
        }
        
        mugTimeLabel.mas_updateConstraints { (make) -> Void in
            make.trailing.equalTo()(self.infoView).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.top.equalTo()(self.infoView)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        userNameLabel.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.infoView)
            make.trailing.equalTo()(self.mugTimeLabel.mas_leading).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        mugMessageLabel.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.userNameLabel)
            make.trailing.equalTo()(self.infoView).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.top.equalTo()(self.userNameLabel.mas_bottom)
        }
        
        highlightedView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.bottom.equalTo()(self.contentView)
            make.leading.equalTo()(self.contentView)
            make.trailing.equalTo()(self.contentView)
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        mugImageView.image = UIImage(named: "mugboys_tmp")
        userImageView.image = UIImage(named: "tmp_homer")
        userNameLabel.text = item.userName
        mugMessageLabel.text = item.mugMessage
        mugTimeLabel.text = item.mugTime
        mugTimeLabel.sizeToFit()
        
        if (item.notReadMessages == 0) {
            badgeView.hidden = true
        } else {
            badgeView.hidden = false
            badgeView.setBagdeValue("\(item.notReadMessages)")
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.setCellBackgroundColorForState(highlighted)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        self.setCellBackgroundColorForState(selected)
    }
    
    
    // MARK: - Actions Handlers
    
    private func setCellBackgroundColorForState(selected: Bool) {
        highlightedView.hidden = !selected
    }
    
    // TODO: probably will be remove with the deleteButton
    //    func handlePan(recognizer:UIPanGestureRecognizer) {
    //
    //        let translation = recognizer.translationInView(self.cellContainerView)
    //        if (recognizer.view!.center.x <= self.center.x) {
    //            // Don't move to right
    //            recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x, y:recognizer.view!.center.y)
    //        }
    //        recognizer.setTranslation(CGPointZero, inView: self.cellContainerView)
    //
    //        if (recognizer.state == UIGestureRecognizerState.Ended) {
    //            var newCenterX = self.center.x
    //            var positionLimitToAutomaticallyShowDeleteButton = CGRectGetMinX(self.deleteButton.frame) + CGRectGetWidth(self.deleteButton.frame) / 2
    //            if ((CGRectGetMaxX(recognizer.view!.frame) + translation.x) < positionLimitToAutomaticallyShowDeleteButton) {
    //                newCenterX = self.center.x - self.deleteButton.frame.size.width
    //            }
    //
    //            UIView.animateWithDuration(DRAG_ANIMATION_DURATION, animations: { () -> Void in
    //                recognizer.view!.center = CGPoint(x:newCenterX, y:recognizer.view!.center.y)
    //                recognizer.setTranslation(CGPointZero, inView: self.cellContainerView)
    //            })
    //        }
    //    }
    
    // TODO: probably will be remove with the deleteButton
    // override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //     return true
    // }
    
    // TODO: probably will be remove with the deleteButton
    //    func deleteButtonTapped() {
    //        println("deleteButtonTapped")
    //        if (self.cellContainerView.center.x != self.center.x) {
    //            UIView.animateWithDuration(DRAG_ANIMATION_DURATION, animations: { () -> Void in
    //                self.cellContainerView.center.x = self.center.x
    //            })
    //        }
    //        
    //    }
}