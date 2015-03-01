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

import UIKit
import MediaPlayer

class FlipViewer: UIView {
    
    private let ANIMATION_TRANSITION_DURATION = 0.3
    
    private let IPHONE_4S_VIEW_WIDTH: CGFloat = 240.0
    
    private var flipImageView: UIImageView!
    private var flipFilterImageView: UIImageView!
    private var flipWordLabel: UILabel!
    private var playButtonView: UIImageView!    
    private var flipMoviePlayer: MPMoviePlayerController!
    
    private var flipImage: UIImage!
    private var flipVideoURL: NSURL!
    
    private var isShowingVideo: Bool = false
    
    weak var delegate: FlipViewerDelegate?
    
    // MARK: - Initialization Methods
    
    override init() {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        self.addConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        flipImageView = UIImageView()
        flipImageView.contentMode = UIViewContentMode.ScaleAspectFill
        flipImageView.clipsToBounds = true
        flipImageView.alpha = 0
        self.addSubview(flipImageView)
        
        flipMoviePlayer = MPMoviePlayerController()
        flipMoviePlayer.controlStyle = MPMovieControlStyle.None
        flipMoviePlayer.scalingMode = MPMovieScalingMode.AspectFill
        flipMoviePlayer.view.alpha = 0
        self.addSubview(flipMoviePlayer.view)
        
        flipFilterImageView = UIImageView(image: UIImage(named: "Filter_Photo"))
        flipFilterImageView.alpha = 1.0
        flipFilterImageView.userInteractionEnabled = true
        flipFilterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "flipFilterImageViewTapped"))
        flipFilterImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(flipFilterImageView)
        
        flipWordLabel = UILabel.flipWordLabel()
        self.addSubview(flipWordLabel)
        
        self.playButtonView = UIImageView()
        self.playButtonView.alpha = 0.6
        self.playButtonView.contentMode = UIViewContentMode.Center
        self.playButtonView.image = UIImage(named: "PlayButton")
        self.addSubview(self.playButtonView)
    }
    
    func flipFilterImageViewTapped() {
        self.viewTapped()
    }
    
    private func addConstraints() {
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self)
                make.width.equalTo()(self.IPHONE_4S_VIEW_WIDTH)
            } else {
                make.left.equalTo()(self)
                make.right.equalTo()(self)
            }
            
            make.height.equalTo()(self.flipImageView.mas_width)
        }
        
        flipMoviePlayer.view.mas_makeConstraints({ (make) -> Void in
            make.top.equalTo()(self)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self)
                make.width.equalTo()(self.IPHONE_4S_VIEW_WIDTH)
            } else {
                make.left.equalTo()(self)
                make.right.equalTo()(self)
            }
            
            make.height.equalTo()(self.flipMoviePlayer.view.mas_width)
        })
        
        flipFilterImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipImageView)
            make.left.equalTo()(self.flipImageView)
            make.bottom.equalTo()(self.flipImageView)
            make.right.equalTo()(self.flipImageView)
        }
        
        flipWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self)
        }
        
        playButtonView.mas_makeConstraints({ (make) -> Void in
            make.width.equalTo()(self.flipImageView)
            make.height.equalTo()(self.flipImageView)
            make.center.equalTo()(self.flipImageView)
        })
    }
    
    
    // MARK: - View State Methods
    
    func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackFinished:", name: MPMoviePlayerPlaybackDidFinishNotification, object: flipMoviePlayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerLoadStateChanged:", name: MPMoviePlayerLoadStateDidChangeNotification, object: flipMoviePlayer)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: flipMoviePlayer)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerLoadStateDidChangeNotification, object: flipMoviePlayer)
    }
    
    
    // MARK: - Gesture Recognizer Methods
    
    func viewTapped() {
        self.playButtonView.hidden = true
        self.flipMoviePlayer.currentPlaybackTime = 0
        self.delegate?.flipViewerStartedPlayingContent()
        self.flipMoviePlayer.play()
    }
    
    
    // MARK: - Setter Methods
    
    func setWord(word: String) {
        flipWordLabel.text = word
    }
    
    func setImage(image: UIImage) {
        isShowingVideo = false
        flipImageView.image = image
        
        UIView.animateWithDuration(ANIMATION_TRANSITION_DURATION, animations: { () -> Void in
            self.flipImageView.alpha = 1
            self.flipMoviePlayer.view.alpha = 0
        })
    }
    
    func setVideoURL(videoURL: NSURL) {
        isShowingVideo = true
        self.flipMoviePlayer.contentURL = videoURL
        
        UIView.animateWithDuration(ANIMATION_TRANSITION_DURATION, animations: { () -> Void in
            self.flipImageView.alpha = 0
            self.flipMoviePlayer.view.alpha = 1
        }) { (finished) -> Void in
            self.playButtonView.hidden = true
            self.delegate?.flipViewerStartedPlayingContent()
            self.flipMoviePlayer.play()
        }
    }
    
    
    // MARK: - Notification Handlers
    
    func playbackFinished(notification: NSNotification) {
        playButtonView.hidden = false
        flipMoviePlayer.currentPlaybackTime = 0
        println("playbackFinished")
        self.delegate?.flipViewerFinishedPlayingContent()
    }
    
    func moviePlayerLoadStateChanged(notification: NSNotification) {
        println("moviePlayerLoadStateChangedWithNotification: \(notification)")
    }

}

protocol FlipViewerDelegate: class {
    
    func flipViewerStartedPlayingContent()
    
    func flipViewerFinishedPlayingContent()
    
}
