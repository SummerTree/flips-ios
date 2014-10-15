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
            if (player != nil) {
                player.view.removeFromSuperview()
                player = nil
            }
            
            let bundle = NSBundle.mainBundle()
            let moviePath = bundle.pathForResource(message.videoPath, ofType: "mov")
            player = MPMoviePlayerController(contentURL: NSURL.fileURLWithPath(moviePath!))
            player.view.backgroundColor = UIColor.greenColor()
            
            //        player.view.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.width)
            player.controlStyle = MPMovieControlStyle.None
            
            videoView.addSubview(player.view)
            player.view.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self.videoView)
                make.bottom.equalTo()(self.videoView)
                make.leading.equalTo()(self.videoView)
                make.trailing.equalTo()(self.videoView)
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackStateDidChange:", name: "MPMoviePlayerPlaybackStateDidChangeNotification", object: player)

//            videoView = player.view
//            contentView.addSubview(videoView)


            
            thumbnailView.image = UIImage(named: message.thumbnailPath)
//            thumbnailView.frame = videoView.frame
//            thumbnail = UIImage(named: message.thumbnailPath)
//            thumbnailView = UIImageView(image: thumbnail)
//            thumbnailView.userInteractionEnabled = true
//            thumbnailView.frame = videoView.frame
//            messageView.addSubview(thumbnailView)
            
//            let tap = UITapGestureRecognizer(target: self, action: "didTapOnMug:")
//            tap.numberOfTapsRequired = 1
//            thumbnailView.addGestureRecognizer(tap)
            
//            timestampLabel = UILabel()
            timestampLabel.text = message.timestamp
//            timestampLabel.contentMode = .Center
//            timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
//            timestampLabel.textColor = UIColor.deepSea()
//            messageView.addSubview(timestampLabel)
            
//            messageTextLabel = UILabel()
//            messageTextLabel.contentMode = .Center
//            messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
//            messageTextLabel.textColor = UIColor.deepSea()
//            messageView.addSubview(messageTextLabel)

//            avatarView = UIImageView.avatarA3()
            avatarView.image = UIImage(named: message.avatarPath)
//            messageView.addSubview(avatarView)
            
//            self.updateConstraints()
        }
    }
    
    var videoView : UIView!
    var messageView : UIView!
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
        
        self.initSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
//        player = MPMoviePlayerController(contentURL: NSURL.fileURLWithPath(moviePath!))
//        player = MPMoviePlayerController()
//        player.view.backgroundColor = UIColor.greenColor()
//        player.view.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.width)
//        player.controlStyle = MPMovieControlStyle.None
//        videoView = player.view
        videoView = UIView()
        contentView.addSubview(videoView)
        
        messageView = UIView()
        contentView.addSubview(messageView)
        
//        thumbnail = UIImage(named: message.thumbnailPath)
        thumbnailView = UIImageView()
        thumbnailView.userInteractionEnabled = true
        thumbnailView.frame = videoView.frame
        messageView.addSubview(thumbnailView)
        
        let tap = UITapGestureRecognizer(target: self, action: "didTapOnMug:")
        tap.numberOfTapsRequired = 1
        contentView.addGestureRecognizer(tap)
        
        timestampLabel = UILabel()
//        timestampLabel.text = message.timestamp
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
//        avatarView.image = UIImage(named: message.avatarPath)
        messageView.addSubview(avatarView)
        
        self.updateConstraintsIfNeeded()
    }
    
    
    // MARK: - Overridden Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()

        NSNotificationCenter.defaultCenter().removeObserver(self, name: "MPMoviePlayerPlaybackStateDidChangeNotification", object: player)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        videoView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.contentView)
            make.left.equalTo()(self.contentView)
            make.width.equalTo()(self.contentView.frame.size.width)
            make.height.equalTo()(self.contentView.frame.size.width)
        })
        
        thumbnailView.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self.videoView)
            make.left.equalTo()(self.videoView)
            make.width.equalTo()(self.contentView.frame.size.width)
            make.height.equalTo()(self.contentView.frame.size.width)
        }
        
        messageView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.videoView.mas_bottom)
            make.bottom.equalTo()(self.contentView)
            make.left.equalTo()(self.contentView)
            make.right.equalTo()(self.contentView)
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
    }
    
    
    // MARK: - Mug interaction handlers
    
    func didTapOnMug(sender: AnyObject?) {
        switch player.playbackState {
        case MPMoviePlaybackState.Stopped:
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            UIView.beginAnimations(nil, context: nil)
//            UIView.setAnimationDuration(0.2)
                self.thumbnailView.alpha = 0.0
//            UIView.commitAnimations()
            })
            player.play() // NOT SURE IF IT CAN BE EXECUTED OUTSIDE OF THE MAIN QUEUE. Please confirm it.
        case MPMoviePlaybackState.Playing:
            player.pause() // NOT SURE IF IT CAN BE EXECUTED OUTSIDE OF THE MAIN QUEUE. Please confirm it.
        case MPMoviePlaybackState.Paused:
            player.play() // NOT SURE IF IT CAN BE EXECUTED OUTSIDE OF THE MAIN QUEUE. Please confirm it.
        default:
            ()
        }
    }
    
    func playbackStateDidChange(sender: AnyObject?) {
        println("player.playbackState: \(player.playbackState)")
        switch player.playbackState {
        case MPMoviePlaybackState.Stopped:
            //            thumbnailView.alpha = 1.0
            // DO NOT USE IT. FOR ANIMATIONS, ALWAYS USE BLOCKS. ANYWAYS, I DIDN'T GET THE REASON OF THE ANIMATION.
            // IN THE BLOCK BELOW I WILL MAKE IT FADE IN. TO DO IT, THE TEXTVIEW WILL INIT WITH ALPHA = 0
        
            //            UIView.beginAnimations(nil, context: nil)
            //            UIView.setAnimationDuration(0.5)
            //            messageTextLabel.text = message.message
            //            self.updateConstraints()
            //            UIView.commitAnimations()

            // ALSO, EVERY TIME THAT YOU ARE GONNA CHANGE SOMETHING IN THE UI, YOU NEED TO MAKE SURE THAT YOU
            // ARE IN THE MAIN QUEUE. YOU CANNOT CHANGE UI IN A BACKGROUND QUEUE. AND NORMALY, CALLBACKS ARE IN BACKGROUND
            // QUEUES.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                println("showing message")
                self.thumbnailView.alpha = 1.0
                self.messageTextLabel.text = self.message.message
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.messageTextLabel.alpha = 1
                })
            })
            
        default:
            ()
        }
    }
    
}