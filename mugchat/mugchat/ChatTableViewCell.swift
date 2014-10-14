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
    var received : Bool
}

class ChatTableViewCell: UITableViewCell {
    
    
    // MARK: - Constants
    
    private let MESSAGE_TOP_MARGIN: CGFloat = 18.0
    private let MESSAGE_BOTTOM_MARGIN: CGFloat = 18.0
    
    
    // MARK: - Instance variables
    
    var message : MugVideo!
    
    var messageView : UIView!
    var videoView : UIView!
    var avatarView : UIImageView!
    var timestampLabel : UILabel!
    var messageTextLabel : UILabel!
    var player : MPMoviePlayerController!
    
    
    // MARK: - Required initializers
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        messageView = UIView()
        self.addSubview(messageView)
        
        let bundle = NSBundle.mainBundle()
        let moviePath = bundle.pathForResource(message.videoPath, ofType: "mov")
        player = MPMoviePlayerController(contentURL: NSURL.fileURLWithPath(moviePath!))
        player.view.frame = CGRect(x: messageView.frame.origin.x, y: messageView.frame.origin.y, width: messageView.frame.width, height: messageView.frame.width)
        videoView = player.view
        messageView.addSubview(videoView)
        
        avatarView = UIImageView.avatarA3()
        messageView.addSubview(avatarView)
        
        timestampLabel = UILabel()
        timestampLabel.contentMode = .Center
        timestampLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        timestampLabel.textColor = UIColor.deepSea()
        messageView.addSubview(timestampLabel)
        
        messageTextLabel = UILabel()
        messageTextLabel.contentMode = .Center
        messageTextLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        messageTextLabel.textColor = UIColor.deepSea()
        messageView.addSubview(messageTextLabel)
        
        self.updateConstraintsIfNeeded()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Auto layout
    
    override func updateConstraints() {
        
        messageView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self).with().offset()(self.MESSAGE_TOP_MARGIN)
            make.bottom.equalTo()(self).with().offset()(-self.MESSAGE_BOTTOM_MARGIN)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        })
        
        videoView.mas_updateConstraints({ (make) in
            make.top.equalTo()(self.messageView.mas_top)
            make.width.equalTo()(self.player.view.frame.width)
        })
        
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
}