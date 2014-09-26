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

private let CELL_MUG_IMAGE_VIEW_HEIGHT = 112.5
private let CELL_INFO_VIEW_HEIGHT = 56
private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5

// TODO: will be removed - just for test
struct InboxItem {
    var userName : String
    var mugMessage : String
    var notReadMessages : Int
    var mugTime : String
}

class ConversationTableViewCell : UITableViewCell {
    
    // TODO: will be removed - just for test
    var item : InboxItem!
    
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
        
        self.selectionStyle = .Gray
        
        mugImageView = UIImageView()
        userImageView = UIImageView.avatarA3()
        
        infoView = UIView()
        
        userNameLabel = UILabel()
        userNameLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        userNameLabel.textColor = UIColor.deepSea()
        userNameLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        userNameLabel.setContentHuggingPriority(252, forAxis: .Horizontal)
        
        mugMessageLabel = UILabel()
        mugMessageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        mugMessageLabel.textColor = UIColor.deepSea()
        mugMessageLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        
        mugTimeLabel = UILabel()
        mugTimeLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        mugTimeLabel.textColor = UIColor.deepSea()
        mugTimeLabel.textAlignment = .Right
        mugTimeLabel.setContentHuggingPriority(251, forAxis: .Horizontal)
        
        badgeView = CustomBadgeView()
        
        highlightedView = UIView()
        highlightedView.userInteractionEnabled = false
        highlightedView.backgroundColor = UIColor.lightGreyD8()
        highlightedView.alpha = 0.4
        highlightedView.hidden = true
        
        self.addSubviews()
        
        self.updateConstraintsIfNeeded()
    }
    
    func addSubviews() {
        self.addSubview(mugImageView)
        self.addSubview(infoView)
        self.addSubview(userImageView)
        self.addSubview(badgeView)
        self.addSubview(highlightedView)
        
        infoView.addSubview(mugMessageLabel)
        infoView.addSubview(userNameLabel)
        infoView.addSubview(mugTimeLabel)
    }
    
    
    // MARK: - Overridden methods
    
    override func updateConstraints() {
        mugImageView.mas_updateConstraints { (make) -> Void in
            make.width.equalTo()(self)
            make.height.equalTo()(CELL_MUG_IMAGE_VIEW_HEIGHT)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        mugImageView.backgroundColor = UIColor.greenColor()
        
        userImageView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.mugImageView.mas_bottom)
            make.width.equalTo()(self.userImageView.frame.size.width)
            make.height.equalTo()(self.userImageView.frame.size.height)
        }
        userImageView.backgroundColor = UIColor.blueColor()
        
        badgeView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.userImageView).with().offset()(4)
            make.leading.equalTo()(self.userImageView.mas_trailing).with().offset()(-12)
            make.width.equalTo()(self.badgeView.frame.size.width)
            make.height.equalTo()(self.badgeView.frame.size.height)
        }
        
        infoView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.userImageView.mas_trailing).with().offset()(CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.trailing.equalTo()(self)
            make.top.equalTo()(self.mugImageView.mas_bottom)
            make.height.equalTo()(CELL_INFO_VIEW_HEIGHT)
        }
        
        mugTimeLabel.mas_updateConstraints { (make) -> Void in
            make.trailing.equalTo()(self.infoView).with().offset()(-CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.top.equalTo()(self.infoView)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        userNameLabel.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.infoView)
            make.trailing.equalTo()(self.mugTimeLabel.mas_leading).with().offset()(-CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        mugMessageLabel.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self.userNameLabel)
            make.trailing.equalTo()(self.infoView).with().offset()(-CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.top.equalTo()(self.userNameLabel.mas_bottom)
        }
        
        highlightedView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        mugImageView.image = UIImage(named: "mugboys_tmp")
        userImageView.image = UIImage(named: "tmp_homer")
        userNameLabel.text = item.userName
        mugMessageLabel.text = item.mugMessage
        mugTimeLabel.text = item.mugTime
        
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
    
    
    // MARK: - Private Methods
    
    private func setCellBackgroundColorForState(selected: Bool) {
        highlightedView.hidden = !selected
    }
}