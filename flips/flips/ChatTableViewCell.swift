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
    
    private let flipMessageDataSource = FlipMessageDataSource()
    
    // MARK: - Instance variables
    
    private var flipMessageId: String!
    @IBOutlet weak var videoPlayerView: PlayerView!
    @IBOutlet weak var videoPlayerContainerView : UIView!
    @IBOutlet weak var videoPlayerContainerViewWidthConstraint: NSLayoutConstraint!
    var avatarView : RoundImageView!
    @IBOutlet weak var timestampLabel : ChatLabel!
    @IBOutlet weak var messageTextLabel : ChatLabel!
    @IBOutlet weak var messageView : UIView!
    
    private var isPlaying = false
    
    weak var delegate: ChatTableViewCellDelegate?


    // MARK: - Required initializers
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        videoPlayerView.delegate = self

        timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        timestampLabel.textColor = UIColor.deepSea()

        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageTextLabel.alpha = 0
        messageTextLabel.lineBreakMode = .ByWordWrapping
        messageTextLabel.numberOfLines = 0

        self.addSubviews()
        self.addConstraints()
    }
    
    func addSubviews() {
        avatarView = RoundImageView.avatarA3()
        contentView.addSubview(avatarView)
    }
    
    func addConstraints() {
        avatarView.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoPlayerContainerView.mas_bottom)
            make.width.equalTo()(self.avatarView.frame.size.width)
            make.height.equalTo()(self.avatarView.frame.size.height)
        }
    }
    
    
    // MARK: - Set FlipMessage
    
    func setFlipMessageId(flipMessageId: String) {
        self.flipMessageId = flipMessageId
        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageId)

        self.videoPlayerView.setupPlayerWithFlips(flipMessage.flips)

        let formattedDate = DateHelper.formatDateToApresentationFormat(flipMessage.createdAt)
        timestampLabel.text = formattedDate
        
        if (flipMessage.notRead.boolValue) {
            messageTextLabel.alpha = 0
        } else {
            messageTextLabel.alpha = 1
        }
        self.messageTextLabel.text = flipMessage.messagePhrase()
        
        avatarView.setImageWithURL(NSURL(string: flipMessage.from.photoURL))
        
        let loggedUser = User.loggedUser()
        if (flipMessage.from.userID == loggedUser?.userID) {
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


    // MARK: - Overridden Methods
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.videoPlayerView.releaseResources()
        messageTextLabel.text = nil
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
                PersistentManager.sharedInstance.markFlipMessageAsRead(self.flipMessageId)
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