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

class ConversationTableViewCell : UITableViewCell {
    
    private let CELL_MUG_IMAGE_VIEW_HEIGHT = 112.5
    private let CELL_INFO_VIEW_HEIGHT = 56
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    private let DRAG_ANIMATION_DURATION = 0.25
    private let DELETE_BUTTON_WIDTH = 110.0
    
    private var room: Room!
    
    private var mugImageView : UIImageView!
    private var userImageView : UIImageView!
    private var infoView : UIView!
    private var participantsNamesLabel : UILabel!
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
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        mugImageView = UIImageView()
        mugImageView.contentMode = UIViewContentMode.ScaleAspectFill
        mugImageView.clipsToBounds = true
        
        userImageView = UIImageView.avatarA3()
        
        infoView = UIView()
        
        participantsNamesLabel = UILabel()
        participantsNamesLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        participantsNamesLabel.textColor = UIColor.deepSea()
        participantsNamesLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        participantsNamesLabel.setContentHuggingPriority(249, forAxis: .Horizontal)
        participantsNamesLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
        
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
        self.initConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(mugImageView)
        
        contentView.addSubview(infoView)
        contentView.addSubview(userImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(highlightedView)
        
        infoView.addSubview(mugMessageLabel)
        infoView.addSubview(participantsNamesLabel)
        infoView.addSubview(mugTimeLabel)
    }
    
    
    // MARK: - Overridden methods
    
    private func initConstraints() {
        mugImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.height.equalTo()(self.CELL_MUG_IMAGE_VIEW_HEIGHT)
            make.leading.equalTo()(self.contentView)
            make.trailing.equalTo()(self.contentView).with().offset()(0.5)
        }
        
        userImageView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.contentView).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.mugImageView.mas_bottom)
            make.width.equalTo()(self.userImageView.frame.size.width)
            make.height.equalTo()(self.userImageView.frame.size.height)
        }
        
        badgeView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.userImageView.mas_centerY)
            make.leading.equalTo()(self.userImageView.mas_centerX)
            make.width.equalTo()(self.badgeView.frame.size.width)
            make.height.equalTo()(self.badgeView.frame.size.height)
        }
        
        infoView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.userImageView.mas_trailing).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.trailing.equalTo()(self.contentView)
            make.top.equalTo()(self.mugImageView.mas_bottom)
            make.height.equalTo()(self.CELL_INFO_VIEW_HEIGHT)
        }
        
        mugTimeLabel.mas_makeConstraints { (make) -> Void in
            make.trailing.equalTo()(self.infoView).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        participantsNamesLabel.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.infoView)
            make.trailing.equalTo()(self.mugTimeLabel.mas_leading).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        mugMessageLabel.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.participantsNamesLabel)
            make.trailing.equalTo()(self.infoView).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.top.equalTo()(self.participantsNamesLabel.mas_bottom)
        }
        
        highlightedView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.bottom.equalTo()(self.contentView)
            make.leading.equalTo()(self.contentView)
            make.trailing.equalTo()(self.contentView)
        }
    }
    
    func setRoom(room: Room) {
        self.room = room
        self.layoutMessageInfo()
        self.layoutParticipantsNames()
        self.layoutNumberOfNotReadMessages()
    }
    
    
    // MARK: - Cell Layout Methods
    
    private func layoutParticipantsNames() {
        participantsNamesLabel.text = room.roomName()
    }
    
    private func layoutMessageInfo() {
        // All conversations should be sorted in the inbox by the above time stamp, with most recent at the top, and oldest at the bottom.
        
        let mugMessageDataSource = MugMessageDataSource()

        // The preview still photo should reflect the first frame of the video of the oldest unread message in the conversation
        var mugMessage = mugMessageDataSource.oldestNotReadMugMessageForRoomId(room.roomID)
        if (mugMessage == nil) {
            mugMessage = room.mugMessagesNotRemoved().lastObject as? MugMessage
        }
        
        if (mugMessage != nil) {
            mugImageView.image = mugMessage!.messageThumbnail()?
            
            // The avatar to the left should reflect the sender (other than the current user) of the oldest unread message in the conversation
            var photoURL = NSURL(string: mugMessage!.from.photoURL)
            userImageView.setImageWithURL(photoURL)
            
            if (mugMessage!.notRead.boolValue) {
                // Display "tap to play" when unread; display beginning of most recently received message text once all messages played
                mugMessageLabel.text = NSLocalizedString("tap to play", comment: "tap to play")
            } else {
                mugMessageLabel.text = mugMessage!.messagePhrase()
            }
            
            // The time stamp should reflect the time sent of the oldest unread message in the conversation
            let formatedDate = DateHelper.formatDateToApresentationFormat(mugMessage!.createdAt)
            mugTimeLabel.text = formatedDate
            mugTimeLabel.sizeToFit()
        }
    }
    
    private func layoutNumberOfNotReadMessages() {
        // The unread badge count over the avatar should reflect the count of the total number of unread messages in the conversation
        let numberOfNotReadMessages = room.numberOfUnreadMessages()
        if (numberOfNotReadMessages == 0) {
            badgeView.hidden = true
        } else {
            badgeView.hidden = false
            badgeView.setBagdeValue("\(numberOfNotReadMessages)")
        }
    }
}