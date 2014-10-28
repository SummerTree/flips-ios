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

public class ConfirmFlipView : UIView, UIGestureRecognizerDelegate {
    
    var delegate: ConfirmFlipViewDelegate?
    
    private let MUG_IMAGE_WIDTH: CGFloat = 240.0
    private let MUG_VIDEO_WIDTH: CGFloat = 240.0
    private let MUG_WORD_LABEL_MARGIN_BOTTOM: CGFloat = 40.0
    
    private var mugContainerView: UIView!
    private var flipImageView: UIImageView!
    private var moviePlayer: MPMoviePlayerController!
    private var flipWordLabel: UILabel!
    private var flipVideoURL: NSURL!
    private var flipAudioURL: NSURL!
    private var rejectButton: UIButton!
    private var acceptButton: UIButton!
    
    convenience init(word: String!, background: UIImage!, audio: NSURL?) {
        self.init()
        
        self.flipWordLabel = UILabel()
        self.flipWordLabel.text = word
        
        self.flipImageView = UIImageView(image: background)
        
        if (audio != nil) {
            self.flipAudioURL = audio!
        }
        
        self.addSubviews()
    }
    
    convenience init(word: String!, video: NSURL!) {
        self.init()
        
        self.flipWordLabel = UILabel()
        self.flipWordLabel.text = word
        
        self.flipImageView = UIImageView.imageWithColor(UIColor.avacado())
        
        if (video != nil) {
            self.flipVideoURL = video!
            self.moviePlayer = MPMoviePlayerController(contentURL: self.flipVideoURL)
        }
        
        self.addSubviews()
    }
    
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        self.makeConstraints()
        self.layoutIfNeeded()
    }
    
    func addSubviews() {
        mugContainerView = UIView()
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "playOrPausePreview")
        tapGestureRecognizer.delegate = self
        mugContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        self.addSubview(mugContainerView)
        
        if (self.flipImageView != nil) {
            flipImageView.contentMode = UIViewContentMode.ScaleAspectFit
            mugContainerView.addSubview(self.flipImageView)
        }
        
        if (self.moviePlayer != nil) {
            self.moviePlayer.controlStyle = MPMovieControlStyle.None
            self.moviePlayer.shouldAutoplay = false
            self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
            mugContainerView.addSubview(moviePlayer.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
        }
        
        flipWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        flipWordLabel.textColor = UIColor.whiteColor()
        
        mugContainerView.addSubview(self.flipWordLabel)
        
        rejectButton = UIButton()
        rejectButton.setImage(UIImage(named: "Deny"), forState: UIControlState.Normal)
        rejectButton.backgroundColor = UIColor.mugOrange()
        rejectButton.addTarget(self, action: "rejectButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(rejectButton)
        
        acceptButton = UIButton()
        acceptButton.setImage(UIImage(named: "Approve"), forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.avacado()
        acceptButton.addTarget(self, action: "acceptButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(acceptButton)
    }
    
    func moviePlayerDidFinish(notification: NSNotification) {
        let player = notification.object as MPMoviePlayerController
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
    }
    
    func playOrPausePreview() {
        self.delegate?.confirmFlipViewDidTapPlayOrPausePreviewButton(self)
    }
    
    func makeConstraints() {
        mugContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.flipImageView)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.confirmFlipViewMakeConstraintToNavigationBarBottom(mugContainerView)
        
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.mugContainerView)
                make.width.equalTo()(self.MUG_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.mugContainerView)
                make.right.equalTo()(self.mugContainerView)
            }

            make.height.equalTo()(self.flipImageView.mas_width)
        }
        
        if (self.moviePlayer != nil) {
            self.moviePlayer.view.mas_makeConstraints({ (make) -> Void in
                make.top.equalTo()(self.mugContainerView)
                
                if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                    make.centerX.equalTo()(self.mugContainerView)
                    make.width.equalTo()(self.MUG_VIDEO_WIDTH)
                } else {
                    make.left.equalTo()(self.mugContainerView)
                    make.right.equalTo()(self.mugContainerView)
                }
                
                make.height.equalTo()(self.moviePlayer.view.mas_width)
            })
        }
        
        flipWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.mugContainerView).with().offset()(-self.MUG_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self.mugContainerView)
        }
        
        rejectButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self.mas_centerX)
            make.bottom.equalTo()(self)
        }
        
        acceptButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.rejectButton)
            make.left.equalTo()(self.rejectButton.mas_right)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    
    // MARK: - Action buttons
    
    func rejectButtonTapped() {
        self.delegate?.confirmFlipViewDidTapRejectButton(self)
    }
    
    func acceptButtonTapped() {
        self.delegate?.confirmFlipViewDidTapAcceptButton(self)
    }
    
    func playVideo() {
        self.moviePlayer.play()
    }
    
    func playAudio() {
        AudioRecorderService.sharedInstance.playAudio(flipAudioURL)
    }
    
    
    // MARK: - Gesture Recognizer Delegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol ConfirmFlipViewDelegate {
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!)
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapPlayOrPausePreviewButton(flipView: ConfirmFlipView!)
}