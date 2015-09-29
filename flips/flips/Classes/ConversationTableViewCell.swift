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

import Foundation

class ConversationTableViewCell : UITableViewCell {
    
    private let CELL_FLIP_IMAGE_VIEW_HEIGHT = 112.5
    private let CELL_INFO_VIEW_HEIGHT = 56
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    private let DRAG_ANIMATION_DURATION = 0.25
    private let DELETE_BUTTON_WIDTH = 110.0
    
    private var roomId: String!
    
    private var flipImageView : UIImageView!
    private var userImageView : RoundImageView!
    private var infoView : UIView!
    private var participantsNamesLabel : UILabel!
    private var flipMessageLabel : UILabel!
    private var flipTimeLabel : UILabel!
    private var badgeView : CustomBadgeView!
    private var highlightedView : UIView!
    
    
    // MARK: - Init Methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        flipImageView = UIImageView()
        flipImageView.contentMode = UIViewContentMode.ScaleAspectFill
        flipImageView.clipsToBounds = true
        flipImageView.image = UIImage(named: "Filter_Photo")
        
        userImageView = RoundImageView.avatarA3()
        
        infoView = UIView()
        
        participantsNamesLabel = UILabel()
        participantsNamesLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        participantsNamesLabel.textColor = UIColor.deepSea()
        participantsNamesLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        participantsNamesLabel.setContentHuggingPriority(249, forAxis: .Horizontal)
        participantsNamesLabel.setContentCompressionResistancePriority(250, forAxis: .Horizontal)
        
        flipMessageLabel = UILabel()
        flipMessageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        flipMessageLabel.textColor = UIColor.deepSea()
        flipMessageLabel.setContentHuggingPriority(251, forAxis: .Vertical)
        
        flipTimeLabel = UILabel()
        flipTimeLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        flipTimeLabel.textColor = UIColor.deepSea()
        flipTimeLabel.textAlignment = .Right
        flipTimeLabel.setContentHuggingPriority(999, forAxis: .Horizontal)
        
        badgeView = CustomBadgeView()
        badgeView.hidden = true
        
        highlightedView = UIView()
        highlightedView.userInteractionEnabled = false
        highlightedView.backgroundColor = UIColor.lightGreyD8()
        highlightedView.alpha = 0.4
        highlightedView.hidden = true
        
        self.addSubviews()
        self.initConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(flipImageView)
        
        contentView.addSubview(infoView)
        contentView.addSubview(userImageView)
        contentView.addSubview(badgeView)
        contentView.addSubview(highlightedView)
        
        infoView.addSubview(flipMessageLabel)
        infoView.addSubview(participantsNamesLabel)
        infoView.addSubview(flipTimeLabel)
    }
    
    
    // MARK: - Overridden methods
    
    private func initConstraints() {
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.height.equalTo()(self.CELL_FLIP_IMAGE_VIEW_HEIGHT)
            make.leading.equalTo()(self.contentView)
            make.trailing.equalTo()(self.contentView).with().offset()(0.5)
        }
        
        userImageView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.contentView).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.flipImageView.mas_bottom)
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
            make.top.equalTo()(self.flipImageView.mas_bottom)
            make.height.equalTo()(self.CELL_INFO_VIEW_HEIGHT)
        }
        
        flipTimeLabel.mas_makeConstraints { (make) -> Void in
            make.trailing.equalTo()(self.infoView).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        participantsNamesLabel.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.infoView)
            make.trailing.equalTo()(self.flipTimeLabel.mas_leading).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.bottom.equalTo()(self.infoView.mas_centerY)
        }
        
        flipMessageLabel.mas_makeConstraints { (make) -> Void in
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
    
    func setRoomId(roomID: String) {
        self.roomId = roomID
        self.refreshCell()
    }
    
    func refreshCell(shouldSetThumbnailAnimated: Bool = true) {
        let currentRoomId: String = self.roomId

        QueueHelper.dispatchAsyncWithNewContext { (newContext) -> Void in
            if (self.roomId == currentRoomId) {
                let roomDataSource = RoomDataSource(context: newContext)
                let room = roomDataSource.retrieveRoomWithId(self.roomId)
                self.layoutCell(room, shouldSetThumbnailAnimated: shouldSetThumbnailAnimated)
            }
        }
    }


    // MARK: - Cell Layout Methods
    
    private func layoutCell(room: Room, shouldSetThumbnailAnimated: Bool = true) {
        // All conversations should be sorted in the inbox by time stamp, with most recent at the top, and oldest at the bottom.
        var lastMessage: FlipMessage? = nil

        
        let flipMessages: [FlipMessage] = room.notRemovedFlipMessagesOrderedByReceivedAt()
        if (flipMessages.count > 0) {
            lastMessage = flipMessages.last!
        } else {
            print("\n\nCoreData problem: flipMessages is empty for room(\(room.roomID))\n\n")
        }
        
        // The preview still photo should reflect the first frame of the video of the most recent message in the conversation
        if let flipMessage: FlipMessage = lastMessage {
            let isMessageNotRead = flipMessage.notRead.boolValue
            let messagePhrase = flipMessage.messagePhrase()
            let photoURL = NSURL(string: flipMessage.from.photoURL)
            let createdAtDate = flipMessage.createdAt
            let roomName = room.roomName()
            
            // The time stamp should reflect the time sent of the most recent message in the conversation
            let formatedDate = DateHelper.formatDateToApresentationFormat(createdAtDate)
            
            // The unread badge count over the avatar should reflect the count of the total number of unread messages in the conversation
            let numberOfNotReadMessages = room.numberOfUnreadMessages()
            
            // Thumbnail is retrieved asynchronously.
            // We gotta check if the retrieved thumbnail is the correct one for the current room Id
            let originalRoomId: String = self.roomId
            
            flipMessage.messageThumbnail { (thumbnail: UIImage?) in
                if ((originalRoomId == self.roomId) && (thumbnail != nil)) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if (originalRoomId != self.roomId) {
                            return
                        }
                        
                        self.flipImageView.image = thumbnail!
                        if (shouldSetThumbnailAnimated) {
                            self.flipImageView.alpha = 0
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                self.flipImageView.alpha = 1
                            })
                        }
                    })
                } else {
                    print("Retrieved thumbnail error: Thumbnail(\(thumbnail)) - Initial RoomId (\(originalRoomId)) - Current RoomId (\(self.roomId))")
                }
            }

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (originalRoomId == self.roomId) {
                    // The avatar to the left should reflect the sender (other than the current user) of the most recent message in the conversation
                    self.userImageView.setAvatarWithURL(photoURL)
                    
                    self.participantsNamesLabel.text = roomName
                    
                    // Display "tap to play" when unread; display beginning of most recent message text once all messages have been played
                    if (isMessageNotRead) {
                        self.flipMessageLabel.text = NSLocalizedString("tap to play", comment: "tap to play")
                    } else {
                        self.flipMessageLabel.text = messagePhrase
                    }
                    
                    self.flipTimeLabel.text = formatedDate
                    self.flipTimeLabel.sizeToFit()
                    
                    if (numberOfNotReadMessages == 0) {
                        self.badgeView.hidden = true
                    } else {
                        self.badgeView.hidden = false
                        self.badgeView.setBagdeValue("\(numberOfNotReadMessages)")
                    }
                }
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.flipImageView.image = UIImage(named: "Filter_Photo")
    }
}