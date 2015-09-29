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
import MediaPlayer

public class ChatTableViewCell: UITableViewCell, PlayerViewDelegate {
    
    // MARK: - Constants
    
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    private let CELL_PADDING_FOR_IPHONE_4S : CGFloat = 40.0
    
    private let MESSAGE_DATE_LABEL_TOP_MARGIN: CGFloat = 14.0
    private let MESSAGE_TEXT_LABEL_MINIMUM_BOTTOM_MARGIN: CGFloat = 8
    private let MESSAGE_TEXT_LABEL_HORIZONTAL_MARGIN: CGFloat = 75
    
    private let SHARE_BUTTON_HORIZONTAL_MARGIN: CGFloat = 15
    private let SHARE_BUTTON_VERTICAL_MARGIN: CGFloat = 15
    private let SHARE_BUTTON_WIDTH: CGFloat = 20
    private let SHARE_BUTTON_HEIGHT: CGFloat = 30

    // MARK: - Instance variables
    
    private var flipMessageID: String!
    
    private var videoPlayerContainerView : UIView!
    private var videoPlayerView: PlayerView!
    private var avatarView : RoundImageView!
    private var messageDateLabel : ChatLabel!
    private var messageTextLabel : ChatLabel!
    private var messageContainerView : UIView!
    private var shareButton : UIButton!
    private var shareImageButton : RoundImageView!
    private var shareActivityIndicator : UIActivityIndicatorView!
    
    private var isPlaying = false
    
    weak var delegate: ChatTableViewCellDelegate?
    
    var parentViewController : UIViewController?
    var messageComposer : MessageComposerExternal?


    // MARK: - Required initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubviews()
        self.addConstraints()
    }
    
    
    // MARK: - View Initializers
    
    func addSubviews() {
        videoPlayerContainerView = UIView()
        videoPlayerContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(videoPlayerContainerView)

        videoPlayerView = PlayerView()
        videoPlayerView.delegate = self
        videoPlayerView.translatesAutoresizingMaskIntoConstraints = false
        videoPlayerContainerView.addSubview(videoPlayerView)
        
        avatarView = RoundImageView.avatarA3()
        avatarView.hidden = true
        self.contentView.addSubview(avatarView)

        messageContainerView = UIView()
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(messageContainerView)
        
        messageDateLabel = ChatLabel()
        messageDateLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        messageDateLabel.textColor = UIColor.deepSea()
        messageDateLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.addSubview(messageDateLabel)
        
        messageTextLabel = ChatLabel()
        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageTextLabel.alpha = 0
        messageTextLabel.textAlignment = NSTextAlignment.Center
        messageTextLabel.lineBreakMode = .ByWordWrapping
        messageTextLabel.numberOfLines = 0
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.setContentCompressionResistancePriority(751, forAxis: UILayoutConstraintAxis.Vertical)
        messageContainerView.addSubview(messageTextLabel)
        
        shareButton = UIButton(type: .Custom)
        shareButton.setImage(UIImage(named: "Share"), forState: .Normal)
        shareButton.addTarget(self, action: "shareFlip", forControlEvents: .TouchUpInside)
        shareButton.hidden = true
        messageContainerView.addSubview(shareButton)
        
        shareImageButton = RoundImageView.avatarA3()
        shareImageButton.hidden = true
        shareImageButton.setAvatarWithLocalImage("ShareFlip_White")
        shareImageButton.setTapSelector("shareFlip", targetObject: self)
        self.contentView.addSubview(shareImageButton)
        
        shareActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        shareActivityIndicator.hidden = true
        self.contentView.addSubview(shareActivityIndicator)
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
        
        shareButton.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.SHARE_BUTTON_HORIZONTAL_MARGIN)
            make.top.equalTo()(self.messageContainerView.mas_top).with().offset()(self.SHARE_BUTTON_VERTICAL_MARGIN)
            make.width.equalTo()(self.SHARE_BUTTON_WIDTH)
            make.height.equalTo()(self.SHARE_BUTTON_HEIGHT)
        }
        
        shareImageButton.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.width.equalTo()(self.shareImageButton.frame.size.width)
            make.height.equalTo()(self.shareImageButton.frame.size.height)
        }
        
        shareActivityIndicator.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.width.equalTo()(self.shareImageButton.frame.size.width)
            make.height.equalTo()(self.shareImageButton.frame.size.height)
        }
        
        self.contentView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_top)
            make.leading.equalTo()(self.mas_leading)
            make.trailing.equalTo()(self.mas_trailing)
            make.bottom.equalTo()(self.messageContainerView.mas_bottom)
        }
    }
    
    
    // MARK: - Getter/Setter
    
    override public var bounds : CGRect {
        didSet {
            self.contentView.frame = self.bounds
        }
    }
    
    // MARK: - Set FlipMessage
    
    func setFlipMessage(flipMessage: FlipMessage) {
        self.flipMessageID = flipMessage.flipMessageID

        let loggedUserID: String? = User.loggedUser()?.userID
        let flipMessageSenderID: String = flipMessage.from.userID
        let formattedDate: String = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        let messagePhrase: String = flipMessage.messagePhrase()
        let avatarURL: NSURL? = NSURL(string: flipMessage.from.photoURL)
        let isMessagedNotRead: Bool = flipMessage.notRead.boolValue
        
        var flips: Array<Flip> = Array<Flip>()
        var formattedWords: Array<String> = Array<String>()
        
        if let flipEntries = flipMessage.flipsEntries {
            for flipEntry: FlipEntry in flipEntries {
                flips.append(flipEntry.flip)
                formattedWords.append(flipEntry.formattedWord)
            }
        }

        self.videoPlayerView.setupPlayerWithFlips(flips, andFormattedWords: formattedWords, blurringThumbnail: isMessagedNotRead)
        
        self.messageDateLabel.text = formattedDate
        
        if (isMessagedNotRead) {
            self.messageTextLabel.alpha = 0
        } else {
            self.messageTextLabel.alpha = 1
        }
        self.messageTextLabel.text = messagePhrase
        
        self.avatarView.setAvatarWithURL(avatarURL)
        
        if (flipMessageSenderID == loggedUserID) {
            // Sent by the user
            self.avatarView.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.trailing.equalTo()(self).with().offset()(-self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                update.width.equalTo()(self.avatarView.frame.size.width)
                update.height.equalTo()(self.avatarView.frame.size.height)
            })
            shareImageButton.hidden = false
            self.shareImageButton.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
                update.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
                update.width.equalTo()(self.shareImageButton.frame.size.width)
                update.height.equalTo()(self.shareImageButton.frame.size.height)
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
            shareImageButton.hidden = true
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
        self.shareButton.hidden = true
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
        
        let readFlipMessageDataSource = ReadFlipMessageDataSource()
        let hasFlipMessagedMarkedAsRead = readFlipMessageDataSource.hasFlipMessageWithID(self.flipMessageID)
        
        AnalyticsService.logMessageViewed(!hasFlipMessagedMarkedAsRead)
    }
    
    func pauseMovie() {
        self.videoPlayerView.pause(true)
        
        let readFlipMessageDataSource = ReadFlipMessageDataSource()
        let hasFlipMessagedMarkedAsRead = readFlipMessageDataSource.hasFlipMessageWithID(self.flipMessageID)
        
        AnalyticsService.logMessagePaused(!hasFlipMessagedMarkedAsRead)
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

    func playerViewShouldShowPlayButtonOnInitialState(playerView: PlayerView) -> Bool {
        return true
    }
    
    
    // MARK: - Memory Management
    
    func releaseResources() {
        self.videoPlayerView.releaseResources()
    }
    
    // MARK: - Share Flip
    
    func shareFlip() {

        self.shareImageButton.setBlankWhiteImage()
        self.shareActivityIndicator.hidden = false
        self.shareActivityIndicator.startAnimating()
        
        if self.videoPlayerView.loadedPlayerItems.count == 0 {
            self.videoPlayerView.loadFlipsResourcesForPlayback({ () -> Void in
                NSThread.sleepForTimeInterval(1)
                self.shareFlip()
            })
        }
        else {
            
            let movieExport = MovieExport()
            movieExport.exportFlipForMMS(self.videoPlayerView.loadedPlayerItems, words: self.videoPlayerView.flipWordsStrings,
                completion: { (url: NSURL?, error: FlipError?) -> Void in
                    
                    if error != nil {
                        self.stopSharingFlip("Error exporting Flip. \(error?.details)")
                    }
                    else {
                        if let videoUrl = url {
                            //Attach movie to native text message
                            self.messageComposer = MessageComposerExternal()
                            self.messageComposer!.videoUrl = videoUrl
                            self.messageComposer!.containsNonFlipsUsers = false
                            
                            let messageComposerVC = self.messageComposer!.configuredMessageComposeViewController()
                            if let parentVC = self.parentViewController {
                                parentVC.presentViewController(messageComposerVC, animated: true, completion: nil)
                            }
                        }
                        else {
                            self.stopSharingFlip("Video Url is empty.")
                        }
                    }
                    
                    let oneSecond = 1 * Double(NSEC_PER_SEC)
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
                    dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                        self.shareActivityIndicator.hidden = true
                        self.shareActivityIndicator.stopAnimating()
                        self.shareImageButton.setAvatarWithLocalImage("ShareFlip_White")
                    }
                }
            )
        }

        
    }
    
    private func stopSharingFlip(message: String) {
        print(message)
        self.shareButton.hidden = false
        self.shareActivityIndicator.hidden = true
        self.shareActivityIndicator.stopAnimating()
    }
}

protocol ChatTableViewCellDelegate: class {
    
    func chatTableViewCellIsVisible(chatTableViewCell: ChatTableViewCell) -> Bool

}