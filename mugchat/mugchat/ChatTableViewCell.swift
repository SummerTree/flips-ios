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

struct MugVideo {
    var message : String
    var videoPath : String
    var timestamp : String
    var avatarPath : String
    var thumbnailPath : String
    var received : Bool
}

class ChatTableViewCell: UITableViewCell {
    
    
    // MARK: - Constants
    
    private let MESSAGE_TOP_MARGIN: CGFloat = 18.0
    private let MESSAGE_BOTTOM_MARGIN: CGFloat = 18.0
    private let CELL_INFO_VIEW_HORIZONTAL_SPACING : CGFloat = 7.5
    
    // MARK: - Instance variables
    
    var message : MugVideo! {
        didSet {
            messageView = UIView()
            messageView.backgroundColor = UIColor.whiteColor()
            self.addSubview(messageView)
            
            let bundle = NSBundle.mainBundle()
            let moviePath = bundle.pathForResource(message.videoPath, ofType: "mov")
            player = MPMoviePlayerController(contentURL: NSURL.fileURLWithPath(moviePath!))
            player.view.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.width)
            player.controlStyle = MPMovieControlStyle.None
            videoView = player.view
            messageView.addSubview(videoView)
            
            thumbnail = UIImage(named: message.thumbnailPath)
            thumbnailView = UIImageView(image: thumbnail)
            thumbnailView.userInteractionEnabled = true
            thumbnailView.frame = videoView.frame
            messageView.addSubview(thumbnailView)
            
            let tap = UITapGestureRecognizer(target: self, action: "didTapOnMug:")
            tap.numberOfTapsRequired = 1
            thumbnailView.addGestureRecognizer(tap)
            
            timestampLabel = UILabel()
            timestampLabel.text = message.timestamp
            timestampLabel.contentMode = .Center
            timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
            timestampLabel.textColor = UIColor.deepSea()
            messageView.addSubview(timestampLabel)
            
            messageTextLabel = UILabel()
            messageTextLabel.contentMode = .Center
            messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
            messageTextLabel.textColor = UIColor.deepSea()
            messageView.addSubview(messageTextLabel)

            avatarView = UIImageView.avatarA3()
            avatarView.image = UIImage(named: message.avatarPath)
            messageView.addSubview(avatarView)
            
            self.updateConstraints()
        }
    }
    
    var messageView : UIView!
    var videoView : UIView!
    var avatarView : UIImageView!
    var timestampLabel : UILabel!
    var messageTextLabel : UILabel!
    var player : MPMoviePlayerController!
    var thumbnail : UIImage!
    var thumbnailView : UIImageView!
    
    
    // MARK: - Required initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackStateDidChange:", name: "MPMoviePlayerPlaybackStateDidChangeNotification", object: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Auto layout
    
    override func updateConstraints() {
        
        messageView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self).with().offset()(self.MESSAGE_TOP_MARGIN)
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        })
        
        videoView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.messageView.mas_top)
            make.width.equalTo()(self.frame.width)
            make.height.equalTo()(self.frame.width)
            make.left.equalTo()(self)
        })
        
        avatarView.mas_updateConstraints { (make) -> Void in
            make.leading.equalTo()(self).with().offset()(self.CELL_INFO_VIEW_HORIZONTAL_SPACING)
            make.centerY.equalTo()(self.videoView.mas_bottom)
            make.width.equalTo()(self.avatarView.frame.size.width)
            make.height.equalTo()(self.avatarView.frame.size.height)
        }
        
        timestampLabel.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.videoView.mas_bottom).with().offset()(self.MESSAGE_TOP_MARGIN)
            make.centerX.equalTo()(self.messageView)
        })
        
        messageTextLabel.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.timestampLabel.mas_bottom)
            make.centerX.equalTo()(self.messageView)
        })
        
        super.updateConstraints()
    }
    
    
    // MARK: - Mug interaction handlers
    
    func didTapOnMug(sender: AnyObject?) {
        switch player.playbackState {
        case MPMoviePlaybackState.Stopped:
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            thumbnailView.alpha = 0.0
            UIView.commitAnimations()
            player.play()
        case MPMoviePlaybackState.Playing:
            player.pause()
        case MPMoviePlaybackState.Paused:
            player.play()
        default:
            ()
        }
    }
    
    func playbackStateDidChange(sender: AnyObject?) {
        switch player.playbackState {
        case MPMoviePlaybackState.Stopped:
            thumbnailView.alpha = 1.0
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.5)
            messageTextLabel.text = message.message
            self.updateConstraints()
            UIView.commitAnimations()
        default:
            ()
        }
    }
    
}