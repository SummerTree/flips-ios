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
    
    private let KVO_STATUS_KEY = "status"
    
    // MARK: - Instance variables
    
    private var videoPlayerView: PlayerView!
    private var videoPlayerContainerView : UIView!
    private var messageView : UIView!
    private var avatarView : UIImageView!
    private var timestampLabel : UILabel!
    private var messageTextLabel : UILabel!
    //    private var thumbnailView : UIImageView!
    
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
        
        //        player = MPMoviePlayerController()
        //        player.controlStyle = MPMovieControlStyle.None
        //        player.scalingMode = MPMovieScalingMode.AspectFill
        //        videoPlayerContainerView.addSubview(player.view)
        
        //        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackFinished:", name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
        
        messageView = UIView()
        contentView.addSubview(messageView)
        
        //        thumbnailView = UIImageView()
        //        thumbnailView.userInteractionEnabled = true
        //        thumbnailView.frame = videoPlayerContainerView.frame
        //        messageView.addSubview(thumbnailView)
        
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
        
        avatarView = UIImageView.avatarA3()
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
        
        //        thumbnailView.mas_makeConstraints { (make) -> Void in
        //            make.top.equalTo()(self.videoPlayerContainerView)
        //            make.centerX.equalTo()(self.videoPlayerContainerView)
        //            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
        //                make.width.equalTo()(self.contentView.mas_width).with().offset()(-self.CELL_PADDING_FOR_IPHONE_4S * 2.0)
        //                make.height.equalTo()(self.contentView.mas_width).with().offset()(-self.CELL_PADDING_FOR_IPHONE_4S * 2.0)
        //            } else {
        //                make.width.equalTo()(self.contentView.mas_width)
        //                make.height.equalTo()(self.contentView.mas_width)
        //            }
        //        }
        
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
        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageId)
        
        self.setupVideoPlayerWithFlips(flipMessage.mugs.array as [Mug])
        
        let formattedDate = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        timestampLabel.text = formattedDate
        
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
        self.videoPlayerView.setupPlayerWithFlips(flips, completion: { (player) -> Void in
            if (player.status == AVPlayerStatus.ReadyToPlay) {
                self.playMovie()
            }
            
            player.addObserver(self, forKeyPath: self.KVO_STATUS_KEY, options:NSKeyValueObservingOptions.New, context:nil);
        })
    }
    
    
    // MARK: - Overridden Methods
    
    public override func prepareForReuse() {
        self.videoPlayerView.player().removeObserver(self, forKeyPath: self.KVO_STATUS_KEY)
        self.videoPlayerView.releaseResources()
        
        super.prepareForReuse()
    }
    
    // MARK: - KVO
    
    override public func observeValueForKeyPath(keyPath: String, ofObject: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == self.KVO_STATUS_KEY && ofObject is AVQueuePlayer) {
            let player: AVQueuePlayer = ofObject as AVQueuePlayer
            
            if (player.status == AVPlayerStatus.ReadyToPlay && !self.isPlaying) {
                self.playMovie()
            } else {
                // TODO: maybe we should show a error icon... to be defined
            }
        }
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
    
    
    // MARK: - PlayerViewDelegate
    
    func playerViewDidFinishPlayback(playerView: PlayerView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.messageTextLabel.alpha = 1
        })
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