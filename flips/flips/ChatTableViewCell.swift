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
    
    private var videoPlayerContainerView : UIView!
    private var videoPlayerView: PlayerView!
    private var avatarView : RoundImageView!
    private var messageDateLabel : ChatLabel!
    private var messageTextLabel : ChatLabel!
    private var messageContainerView : UIView!
    
    private var isPlaying = false
    
    weak var delegate: ChatTableViewCellDelegate?


    // MARK: - Required initializers
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addSubviews()
        self.addConstraints()
    }
    
    
    // MARK: - View Initializers
    
    func addSubviews() {
        videoPlayerContainerView = UIView()
        videoPlayerContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(videoPlayerContainerView)

        videoPlayerView = PlayerView()
        videoPlayerView.delegate = self
        videoPlayerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        videoPlayerContainerView.addSubview(videoPlayerView)
        
        avatarView = RoundImageView.avatarA3()
        avatarView.hidden = true
        self.contentView.addSubview(avatarView)

        messageContainerView = UIView()
        messageContainerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(messageContainerView)
        
        messageDateLabel = ChatLabel()
        messageDateLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        messageDateLabel.textColor = UIColor.deepSea()
        messageDateLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageContainerView.addSubview(messageDateLabel)
        
        messageTextLabel = ChatLabel()
        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageTextLabel.alpha = 0
        messageTextLabel.textAlignment = NSTextAlignment.Center
        messageTextLabel.lineBreakMode = .ByWordWrapping
        messageTextLabel.numberOfLines = 0
        messageTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        messageTextLabel.setContentCompressionResistancePriority(751, forAxis: UILayoutConstraintAxis.Vertical)
        messageContainerView.addSubview(messageTextLabel)
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
        
        messageContainerView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.bottom.equalTo()(self.messageTextLabel.mas_bottom).with().offset()(self.MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN)
            make.leading.equalTo()(self.contentView.mas_leading)
            make.trailing.equalTo()(self.contentView.mas_trailing)
        }
        
        messageDateLabel.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.messageContainerView.mas_top).with().offset()(self.MESSAGE_DATE_LABEL_TOP_MARGIN)
            make.centerX.equalTo()(self.messageContainerView.mas_centerX)
            make.height.equalTo()(self.messageDateLabel.font.lineHeight)
        }
        
        messageTextLabel.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.messageDateLabel.mas_bottom)
            make.centerX.equalTo()(self.messageContainerView.mas_centerX)
            make.width.equalTo()(self.contentView.mas_width).with().offset()(-self.MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN)
        }
        
        self.contentView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_top)
            make.leading.equalTo()(self.mas_leading)
            make.trailing.equalTo()(self.mas_trailing)
            make.bottom.equalTo()(self.messageContainerView.mas_bottom)
        }
    }
    
    
    // MARK: - Getter/Setter
    
    func setBounds(bounds: CGRect) {
        self.contentView.frame = self.bounds
    }
    
    
    // MARK: - Set FlipMessage
    
    func setFlipMessage(flipMessage: FlipMessage) {
        self.flipMessageID = flipMessage.flipMessageID

        let loggedUserID: String? = User.loggedUser()?.userID
        let flipMessageSenderID: String = flipMessage.from.userID
        let formattedDate: String = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        let messagePhrase: String = flipMessage.messagePhrase()
        let avatarURL: NSURL? = NSURL(string: flipMessage.from.photoURL)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var flips: Array<Flip> = Array<Flip>()
            var formattedWords: Array<String> = Array<String>()
            
            for flipEntry: FlipEntry in flipMessage.flipsEntries {
                flips.append(flipEntry.flip)
                formattedWords.append(flipEntry.formattedWord)
            }
            
            self.videoPlayerView.setupPlayerWithFlips(flips, andFormattedWords: formattedWords)
        })
        
        self.messageDateLabel.text = formattedDate
        
        if (flipMessage.notRead.boolValue) {
            self.messageTextLabel.alpha = 0
        } else {
            self.messageTextLabel.alpha = 1
        }
        self.messageTextLabel.text = messagePhrase
        
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
    }
    
    func heightForFlipMessage(flipMessage: FlipMessage) -> CGFloat {
        var videoPlayerPadding: CGFloat = 0.0
        if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
            videoPlayerPadding = CELL_PADDING_FOR_IPHONE_4S * 2.0
        }

        let videoPlayerHeight = self.frame.size.width - videoPlayerPadding
        
        self.flipMessageID = flipMessage.flipMessageID

        self.messageTextLabel.text = flipMessage.messagePhrase()
        self.messageTextLabel.sizeToFit()
        
        let formattedDate: String = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        self.messageDateLabel.text = formattedDate
        self.messageDateLabel.sizeToFit()
        
        self.contentView.layoutIfNeeded()
        self.contentView.updateConstraintsIfNeeded()
        
        let bottomPartHeight = messageTextLabel.frame.size.height + messageDateLabel.frame.size.height + MESSAGE_DATE_LABEL_TOP_MARGIN + MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN
        return videoPlayerHeight + bottomPartHeight
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
   
        self.contentView.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
        
        self.messageTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.messageTextLabel.frame)
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