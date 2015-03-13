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
import MediaPlayer

public class ChatTableViewCell: UITableViewCell, PlayerViewDelegate {
    
    // MARK: - Constants
    
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    private let CELL_PADDING_FOR_IPHONE_4S : CGFloat = 40.0
    
    private let MESSAGE_DATE_LABEL_TOP_MARGIN: CGFloat = 14.0
    private let MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN: CGFloat = 8
    private let MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN: CGFloat = 20

    // MARK: - Instance variables
    
    private var flipMessageID: String!
    
    private var videoPlayerView: PlayerView!
    private var videoPlayerContainerView : UIView!
    private var avatarView : RoundImageView!
    private var timestampLabel : ChatLabel! // TODO: rename to dateLabel
    private var messageTextLabel : ChatLabel! // TODO: rename to messageLabel
    private var messageView : UIView! // TODO: rename to messageContainerView
    
    private var isPlaying = false
    
    weak var delegate: ChatTableViewCellDelegate?


    // MARK: - Required initializers
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        println("cell style: \(style.hashValue)")
        self.contentView.backgroundColor = UIColor.orangeColor()
        
//        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubviews()
        self.addConstraints()
    }
    
    
    // MARK: - View Initializers
    
    func addSubviews() {
        videoPlayerContainerView = UIView()
        videoPlayerContainerView.backgroundColor = UIColor.redColor()
        videoPlayerContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(videoPlayerContainerView)
//        println("videoPlayerContainerView: \(videoPlayerContainerView)")

        videoPlayerView = PlayerView()
        videoPlayerView.backgroundColor = UIColor.banana()
        videoPlayerView.delegate = self
        videoPlayerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoPlayerContainerView.addSubview(videoPlayerView)
//        println("videoPlayerView: \(videoPlayerView)")
        
        avatarView = RoundImageView.avatarA3()
        avatarView.hidden = true
        self.contentView.addSubview(avatarView)
//        println("avatarView: \(avatarView)")

        messageView = UIView()
        messageView.backgroundColor = UIColor.greenColor()
        messageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(messageView)
//        println("messageView: \(messageView)")
        
        timestampLabel = ChatLabel()
        timestampLabel.backgroundColor = UIColor.purpleColor()
        timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        timestampLabel.textColor = UIColor.deepSea()
        timestampLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageView.addSubview(timestampLabel)
//        println("timestampLabel: \(timestampLabel)")
        
        messageTextLabel = ChatLabel()
        messageTextLabel.backgroundColor = UIColor.blueColor()
        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageTextLabel.alpha = 0
        messageTextLabel.textAlignment = NSTextAlignment.Center
        messageTextLabel.lineBreakMode = .ByWordWrapping
        messageTextLabel.numberOfLines = 0
        messageTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageTextLabel.setContentCompressionResistancePriority(751, forAxis: UILayoutConstraintAxis.Vertical)
        messageView.addSubview(messageTextLabel)
//        println("messageTextLabel: \(messageTextLabel)")
    }
    
    func addConstraints() {
        var videoPlayerPadding: CGFloat = 0.0
        if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
            videoPlayerPadding = -CELL_PADDING_FOR_IPHONE_4S * 2.0
        }
        
        videoPlayerContainerView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView.mas_top)
            make.centerX.equalTo()(self.contentView.mas_centerX)
            make.width.equalTo()(self.contentView.mas_width)
            make.height.equalTo()(self.contentView.mas_width).with().offset()(videoPlayerPadding)
        }
        
        videoPlayerView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerContainerView.mas_top)
            make.width.equalTo()(self.videoPlayerContainerView.mas_height)
            make.height.equalTo()(self.videoPlayerContainerView.mas_height)
            make.centerX.equalTo()(self.videoPlayerContainerView.mas_centerX)
        }
        
        avatarView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.width.equalTo()(self.avatarView.frame.size.width)
            make.height.equalTo()(self.avatarView.frame.size.height)
        }
        
        let messageDateLineHeight: CGFloat = self.timestampLabel.font.lineHeight
        let messageTextLineHeight: CGFloat = self.messageTextLabel.font.lineHeight
        
        messageView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.bottom.equalTo()(self.messageTextLabel.mas_bottom)
//            make.height.greaterThanOrEqualTo()(messageDateLineHeight + messageTextLineHeight)
            make.leading.equalTo()(self.contentView.mas_leading)
            make.trailing.equalTo()(self.contentView.mas_trailing)
        }
        
        timestampLabel.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.messageView.mas_top).with().offset()(self.MESSAGE_DATE_LABEL_TOP_MARGIN)
            make.centerX.equalTo()(self.messageView.mas_centerX)
            make.height.equalTo()(self.timestampLabel.font.lineHeight)
        }
        
        messageTextLabel.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.timestampLabel.mas_bottom)
            make.centerX.equalTo()(self.messageView.mas_centerX)
            make.width.equalTo()(self.contentView.mas_width).with().offset()(-self.MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN)
//            make.height.greaterThanOrEqualTo()(self.messageTextLabel.font.lineHeight).offset()(self.MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN)
//            make.bottom.greaterThanOrEqualTo()(self.contentView.mas_bottom).with().offset()(-self.MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN)
        }
        
        self.contentView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_top)
            make.leading.equalTo()(self.mas_leading)
            make.trailing.equalTo()(self.mas_trailing)
            make.bottom.equalTo()(self.messageView.mas_bottom)
        }
        
//        self.mas_makeConstraints { (make) -> Void in
//            make.top.equalTo()(self.contentView)
//            make.leading.equalTo()(self.contentView)
//            make.trailing.equalTo()(self.contentView)
//            make.bottom.equalTo()(self.contentView)
//        }
    }
    
    
    // MARK: - Getter/Setter
    
    func setBounds(bounds: CGRect) {
        self.contentView.frame = self.bounds
    }
    
    
    // MARK: - Set FlipMessage
    
    func setFlipMessage(flipMessage: FlipMessage) {
        self.flipMessageID = flipMessage.flipMessageID

//        let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource()
//        let flipMessage: FlipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageId)
        let loggedUserID: String? = User.loggedUser()?.userID
        let flipMessageSenderID: String = flipMessage.from.userID
        let formattedDate: String = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        let messagePhrase: String = flipMessage.messagePhrase()
        let avatarURL: NSURL? = NSURL(string: flipMessage.from.photoURL)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.videoPlayerView.setupPlayerWithFlips(flipMessage.flips)
        })
        
        self.timestampLabel.text = formattedDate
//        self.timestampLabel.sizeToFit()
        
            if (flipMessage.notRead.boolValue) {
                self.messageTextLabel.alpha = 0
            } else {
                self.messageTextLabel.alpha = 1
            }
            self.messageTextLabel.text = messagePhrase
//            self.messageTextLabel.sizeToFit()
//            self.messageTextLabel.mas_updateConstraints { (update) -> Void in
//                update.removeExisting = true
//                update.top.equalTo()(self.timestampLabel.mas_bottom)
//                update.centerX.equalTo()(self.messageView.mas_centerX)
//                update.width.equalTo()(self.messageView.mas_width).with().offset()(-self.MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN)
//                update.height.equalTo()(self.messageTextLabel.frame.size.height)
//            }
        
            self.avatarView.setImageWithURL(avatarURL)
            
            if (flipMessageSenderID == loggedUserID) {
                // Sent by the user
                self.avatarView.mas_updateConstraints({ (update) -> Void in
                    update.removeExisting = true
                    update.trailing.equalTo()(self).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                    update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                    update.width.equalTo()(self.avatarView.frame.size.width)
                    update.height.equalTo()(self.avatarView.frame.size.height)
                })
            } else {
                // Received by the user
                self.avatarView.mas_updateConstraints({ (update) -> Void in
                    update.removeExisting = true
                    update.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                    update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                    update.width.equalTo()(self.avatarView.frame.size.width)
                    update.height.equalTo()(self.avatarView.frame.size.height)
                })
            }
            self.avatarView.hidden = false
        
//        self.layoutSubviews()
        
//        let cellHeight: CGFloat = self.videoPlayerContainerView.frame.size.height + self.messageView.frame.size.height
//        self.contentView.mas_updateConstraints { (update) -> Void in
//            update.removeExisting = true
//            update.top.equalTo()(self.mas_top)
//            update.leading.equalTo()(self.mas_leading)
//            update.trailing.equalTo()(self.mas_trailing)
//            //            update.bottom.equalTo()(self.messageView.mas_bottom)
//            update.height.equalTo()(cellHeight)
//        }
        
//        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), cellHeight)
//        self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), cellHeight)
        

        println("   ")
        println("setFlipMessage: \(self.contentView.frame)")
        println("   videoPlayerView.   : \(self.videoPlayerView.frame)")
        println("   playerContainerView: \(self.videoPlayerContainerView.frame)")
        println("   messageView        : \(self.messageView.frame)")
        println("   timestampLabel     : \(self.timestampLabel.frame)")
        println("   messageTextLabel   : \(self.messageTextLabel.frame)")
        println("   ")

    }
    
    func heightForFlipMessage(flipMessage: FlipMessage) -> CGFloat {
        
        var videoPlayerPadding: CGFloat = 0.0
        if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
            videoPlayerPadding = CELL_PADDING_FOR_IPHONE_4S * 2.0
        }

        let videoPlayerHeight = self.frame.size.width - videoPlayerPadding
        
        self.flipMessageID = flipMessage.flipMessageID
        
//        let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource()
//        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageId)
        
//        self.videoPlayerView.setupPlayerWithFlips(flipMessage.flips)
        
        self.messageTextLabel.text = flipMessage.messagePhrase()
        self.messageTextLabel.sizeToFit()
//        self.contentView.setNeedsLayout()
//        self.contentView.setNeedsUpdateConstraints()
        
//        if (flipMessage.notRead.boolValue) {
//            self.messageTextLabel.alpha = 0
//        } else {
            self.messageTextLabel.alpha = 1
//        }
        
        let formattedDate: String = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        self.timestampLabel.text = formattedDate
        self.timestampLabel.sizeToFit()
        
//        println("before self.timestampLabel: \(self.timestampLabel.frame)")
//        println("before self.messageTextLabel: \(self.messageTextLabel.frame)")
        self.contentView.layoutIfNeeded()
//        self.contentView.updateConstraintsIfNeeded()
        
//        self.messageTextLabel.mas_updateConstraints { (update) -> Void in
//            update.removeExisting = true
//            update.top.equalTo()(self.timestampLabel.mas_bottom)
//            update.centerX.equalTo()(self.messageView.mas_centerX)
//            update.width.equalTo()(self.messageView.mas_width).with().offset()(-self.MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN)
//            update.height.equalTo()(self.messageTextLabel.frame.size.height)
//        }
        self.contentView.updateConstraintsIfNeeded()
        
        println("after  self.timestampLabel: \(self.timestampLabel.frame)")
        println("after  self.messageTextLabel: \(self.messageTextLabel.frame)")

        
        return videoPlayerHeight + messageTextLabel.frame.size.height + timestampLabel.frame.size.height + MESSAGE_DATE_LABEL_TOP_MARGIN + MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN
    }


    // MARK: - Overridden Methods
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.videoPlayerView.releaseResources()
        self.messageTextLabel.text = " "
        self.avatarView.hidden = true
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.contentView.mas_updateConstraints { (update) -> Void in
//            update.removeExisting = true
//            update.top.equalTo()(self.mas_top)
//            update.leading.equalTo()(self.mas_leading)
//            update.trailing.equalTo()(self.mas_trailing)
////            update.bottom.equalTo()(self.messageView.mas_bottom)
//            update.height.equalTo()(cellHeight)
//        }
//        self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), cellHeight)
//        self.setNeedsUpdateConstraints()

//        self.contentView.updateConstraintsIfNeeded()
        
//        let cellHeight: CGFloat = self.videoPlayerContainerView.frame.size.height + self.messageView.frame.size.height
//        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), cellHeight)
//        self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame), CGRectGetWidth(self.contentView.frame), cellHeight)
        
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        
        println("   ")
        println("layoutSubviews: \(self.contentView.frame)")
        println("   videoPlayerView.   : \(self.videoPlayerView.frame)")
        println("   playerContainerView: \(self.videoPlayerContainerView.frame)")
        println("   messageView        : \(self.messageView.frame)")
        println("   timestampLabel     : \(self.timestampLabel.frame)")
        println("   messageTextLabel   : \(self.messageTextLabel.frame)")
        println("   ")


        self.messageTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.messageTextLabel.frame)
    }
    
    public override func updateConstraints() {
//        println("updateConstraints")

//        self.messageTextLabel.sizeToFit()
//        self.messageTextLabel.mas_updateConstraints { (update) -> Void in
//            update.removeExisting = true
//            update.top.equalTo()(self.timestampLabel.mas_bottom)
//            update.centerX.equalTo()(self.messageView.mas_centerX)
//            update.width.equalTo()(self.messageView.mas_width).with().offset()(-self.MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN)
//            update.height.equalTo()(self.messageTextLabel.frame.size.height)
//        }
        
        super.updateConstraints()
    }
    

    // MARK: - Movie player controls
    
    func playMovie() {
        self.videoPlayerView.play()
    }
    
    func pauseMovie() {
        self.videoPlayerView.pause(fadeOutVolume: true)
    }
    
    func stopMovie() {
        self.pauseMovie()
    }

    func isPlayingFlip() -> Bool {
        return self.videoPlayerView.isPlaying
    }
    
    
    // MARK: - PlayerViewDelegate
    
    func playerViewDidFinishPlayback(playerView: PlayerView) {
        if (self.messageTextLabel.alpha == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                PersistentManager.sharedInstance.markFlipMessageAsRead(self.flipMessageID)
            })
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.messageTextLabel.alpha = 1
            })
        }
    }
    
    func playerViewIsVisible(playerView: PlayerView) -> Bool {
        var isVisible = false
        if (delegate != nil) {
            isVisible = delegate!.chatTableViewCellIsVisible(self)
        }
        return isVisible
    }
    
    
    // MARK: - Memory Management
    
    func releaseResources() {
        self.videoPlayerView.releaseResources()
    }
}

protocol ChatTableViewCellDelegate: class {
    
    func chatTableViewCellIsVisible(chatTableViewCell: ChatTableViewCell) -> Bool

}