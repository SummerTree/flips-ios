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
    
    private let MESSAGE_TOP_MARGIN: CGFloat = 18.0
    private let MESSAGE_BOTTOM_MARGIN: CGFloat = 18.0
    private let CELL_PADDING_FOR_IPHONE_4S : CGFloat = 40.0
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    
    private let flipMessageDataSource = MugMessageDataSource()
    
    // MARK: - Instance variables
    
    private var flipMessageId: String!
    private var videoPlayerView: PlayerView!
    private var videoPlayerContainerView : UIView!
    private var messageView : UIView!
    private var avatarView : RoundImageView!
    private var timestampLabel : UILabel!
    private var messageTextLabel : UILabel!
    
    private var isPlaying = false
    
    var delegate: ChatTableViewCellDelegate?
    
    // MARK: - Required initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.whiteColor()
        self.addSubviews()
        self.addConstraints()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        videoPlayerContainerView = UIView()
        contentView.addSubview(videoPlayerContainerView)
        
        videoPlayerView = PlayerView()
        videoPlayerView.delegate = self
        videoPlayerContainerView.addSubview(videoPlayerView)
        
        messageView = UIView()
        contentView.addSubview(messageView)
        
        timestampLabel = UILabel()
        timestampLabel.contentMode = .Center
        timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        timestampLabel.textColor = UIColor.deepSea()
        messageView.addSubview(timestampLabel)
        
        messageTextLabel = UILabel()
        messageTextLabel.contentMode = .Center
        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageTextLabel.alpha = 0
        messageView.addSubview(messageTextLabel)
        
        avatarView = RoundImageView.avatarA3()
        messageView.addSubview(avatarView)
        
        var button = UIButton()
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: "playOrPausePreview", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(button)
        
        button.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self.contentView)
            make.size.equalTo()(self.contentView)
        }
    }
    
    func addConstraints() {
        videoPlayerContainerView.mas_makeConstraints({ (make) in
            make.top.equalTo()(self.contentView)
            make.centerX.equalTo()(self.contentView)
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.width.equalTo()(self.contentView.mas_width).with().offset()(-self.CELL_PADDING_FOR_IPHONE_4S * 2.0)
                make.height.equalTo()(self.contentView.mas_width).with().offset()(-self.CELL_PADDING_FOR_IPHONE_4S * 2.0)
            } else {
                make.width.equalTo()(self.contentView.mas_width)
                make.height.equalTo()(self.contentView.mas_width)
            }
        })

        videoPlayerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerContainerView)
            make.bottom.equalTo()(self.videoPlayerContainerView)
            make.leading.equalTo()(self.videoPlayerContainerView)
            make.trailing.equalTo()(self.videoPlayerContainerView)
        }
        
        messageView.mas_makeConstraints({ (make) in
            make.top.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.bottom.equalTo()(self.contentView)
            make.left.equalTo()(self.contentView)
            make.right.equalTo()(self.contentView)
        })
        
        avatarView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.width.equalTo()(self.avatarView.frame.size.width)
            make.height.equalTo()(self.avatarView.frame.size.height)
        }
        
        timestampLabel.mas_makeConstraints({ (make) in
            make.top.equalTo()(self.videoPlayerContainerView.mas_bottom).with().offset()(self.MESSAGE_TOP_MARGIN)
            make.centerX.equalTo()(self.messageView)
        })
        
        messageTextLabel.mas_makeConstraints({ (make) in
            make.top.equalTo()(self.timestampLabel.mas_bottom)
            make.centerX.equalTo()(self.messageView)
        })
    }
    
    
    // MARK: - Set FlipMessage
    
    func setFlipMessageId(flipMessageId: String) {
        self.flipMessageId = flipMessageId
        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageId)
        
        self.setupVideoPlayerWithFlips(flipMessage.mugs.array as [Mug])
        
        let formattedDate = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        timestampLabel.text = formattedDate
        
        if (flipMessage.notRead.boolValue) {
            messageTextLabel.alpha = 0
        } else {
            messageTextLabel.alpha = 1
        }
        self.messageTextLabel.text = flipMessage.messagePhrase()
        self.messageTextLabel.sizeToFit()
        
        avatarView.setImageWithURL(NSURL(string: flipMessage.from.photoURL))
        
        if (flipMessage.from.userID == AuthenticationHelper.sharedInstance.userInSession.userID) {
            // Sent by the user
            avatarView.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.trailing.equalTo()(self).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                update.width.equalTo()(self.avatarView.frame.size.width)
                update.height.equalTo()(self.avatarView.frame.size.height)
            })
        } else {
            // Received by the user
            avatarView.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                update.width.equalTo()(self.avatarView.frame.size.width)
                update.height.equalTo()(self.avatarView.frame.size.height)
            })
        }
    }
    
    private func setupVideoPlayerWithFlips(flips: Array<Mug>) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.videoPlayerView)
        self.videoPlayerView.setupPlayerWithFlips(flips, completion: { (player) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.videoPlayerView)
        })
    }
    
    
    // MARK: - Overridden Methods
    
    public override func prepareForReuse() {
        self.videoPlayerView.releaseResources()
        
        super.prepareForReuse()
    }


    // MARK: - Movie player controls
    
    func player() -> AVQueuePlayer {
        let layer = self.videoPlayerView.layer as AVPlayerLayer
        return layer.player as AVQueuePlayer
    }
    
    func playMovie() {
        ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
        self.isPlaying = true
        self.videoPlayerView.play()
    }
    
    func pauseMovie() {
        self.isPlaying = false
        self.videoPlayerView.pause()
    }
    
    func stopMovie() {
        self.pauseMovie()
    }
    
    func playOrPausePreview() {
        if (self.isPlaying) {
            self.pauseMovie()
        } else {
            self.playMovie()
        }
    }
    
    func isPlayingFlip() -> Bool {
        return self.isPlaying
    }
    
    // MARK: - PlayerViewDelegate
    
    func playerViewDidFinishPlayback(playerView: PlayerView) {
        if (self.messageTextLabel.alpha == 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                self.flipMessageDataSource.markFlipMessageAsRead(self.flipMessageId)
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
}

protocol ChatTableViewCellDelegate {
    
    func chatTableViewCellIsVisible(chatTableViewCell: ChatTableViewCell) -> Bool

}