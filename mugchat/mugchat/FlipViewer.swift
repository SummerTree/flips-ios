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
    
    private var flipMoviePlayer: MPMoviePlayerController!
    
    private var flipImage: UIImage!
    private var flipAudioURL: NSURL!
    private var flipVideoURL: NSURL!
    
    private var isShowingVideo: Bool = false
    
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
        
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped")
        flipImageView.addGestureRecognizer(tapGestureRecognizer)
        
        flipMoviePlayer = MPMoviePlayerController()
        flipMoviePlayer.view.alpha = 0
        flipMoviePlayer.view.addGestureRecognizer(tapGestureRecognizer)
        self.addSubview(flipMoviePlayer.view)
        
        flipFilterImageView = UIImageView(image: UIImage(named: "Filter_Photo"))
        flipFilterImageView.alpha = 1.0
        flipFilterImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(flipFilterImageView)
        
        flipWordLabel = UILabel.flipWordLabel()
//        flipWordLabel.alpha = 0
        self.addSubview(flipWordLabel)
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
    }
    
    
    // MARK: - View State Methods
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playbackFinished:", name: MPMoviePlayerPlaybackDidFinishNotification, object: flipMoviePlayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerLoadStateChanged:", name: MPMoviePlayerLoadStateDidChangeNotification, object: flipMoviePlayer)
    }
    
    func viewWillDisapear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: flipMoviePlayer)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerLoadStateDidChangeNotification, object: flipMoviePlayer)
    }
    
    
    // MARK: - Gesture Recognizer Methods
    
    private func viewTapped() {
        if (isShowingVideo) {
            if (flipMoviePlayer.playbackState == MPMoviePlaybackState.Playing) {
                flipMoviePlayer.stop()
                flipMoviePlayer.currentPlaybackTime = 0
            } else {
                flipMoviePlayer.currentPlaybackTime = 0
                flipMoviePlayer.play()
            }
        } else {
            let audioService = AudioRecorderService.sharedInstance
            if (audioService.isPlaying()) {
                audioService.stopAudio()
            } else {
                audioService.playAudio(flipAudioURL)
            }
        }
    }
    
    
    // MARK: - Setter Methods
    
    func setWord(word: String) {
        flipWordLabel.text = word
    }
    
    func setImage(image: UIImage) {
        if (isShowingVideo) {
            flipMoviePlayer.stop()
        }
        
        isShowingVideo = false
        flipImageView.image = image
        
        UIView.animateWithDuration(ANIMATION_TRANSITION_DURATION, animations: { () -> Void in
            self.flipImageView.alpha = 1
            self.flipMoviePlayer.view.alpha = 0
        })
    }
    
    func setAudioURL(audioURL: NSURL) {
        isShowingVideo = false
        self.flipAudioURL = audioURL
        
        let oneSecond = 1 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
        dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            AudioRecorderService.sharedInstance.playAudio(self.flipAudioURL)
        })
    }
    
    func setVideoURL(videoURL: NSURL) {
        isShowingVideo = true
        flipMoviePlayer.contentURL = videoURL
        
        UIView.animateWithDuration(ANIMATION_TRANSITION_DURATION, animations: { () -> Void in
            self.flipImageView.alpha = 0
            self.flipMoviePlayer.view.alpha = 1
        })
    }
    
    
    // MARK: - Notification Handlers
    
    private func playbackFinished(notification: NSNotification) {
        flipMoviePlayer.currentPlaybackTime = 0
        println("playbackFinished")
    }
    
    private func moviePlayerLoadStateChanged(notification: NSNotification) {
        println("moviePlayerLoadStateChanged")
    }
    
    
    // MARK: - Audio Playback Controls
    
    private func playAudio() {
        if (flipAudioURL != nil) {
            AudioRecorderService.sharedInstance.playAudio(flipAudioURL)
        }
    }
}
