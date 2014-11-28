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
    
    private let FLIP_IMAGE_WIDTH: CGFloat = 240.0
    private let FLIP_VIDEO_WIDTH: CGFloat = 240.0
    private let FLIP_WORD_LABEL_MARGIN_BOTTOM: CGFloat = 40.0
    private let ACTIVITY_INDICATOR_SIZE: CGFloat = 100
    private let ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION = 0.25
    
    private var flipContainerView: UIView!
    private var flipImageView: UIImageView!
    private var moviePlayer: MPMoviePlayerController!
    private var flipWordLabel: UILabel!
    private var flipVideoURL: NSURL!
    private var flipAudioURL: NSURL?
    private var rejectButton: UIButton!
    private var acceptButton: UIButton!
    
    private var activityIndicator: UIActivityIndicatorView!
    
    convenience init(word: String!, background: UIImage!, audio: NSURL?) {
        self.init()
        
        self.flipWordLabel = UILabel()
        self.flipWordLabel.text = word
        
        self.flipImageView = UIImageView(image: background)
        
        if (audio != nil) {
            self.flipAudioURL = audio
        }
        
        self.addSubviews()
    }
    
    convenience init(word: String!, video: NSURL!) {
        self.init()
        
        self.flipWordLabel = UILabel()
        self.flipWordLabel.text = word
        
        self.flipImageView = UIImageView.imageViewWithColor(UIColor.avacado())
        
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
    
    func viewWillDisappear() {
        if (self.moviePlayer != nil) {
            self.moviePlayer.stop()
        }
    }
    
    func addSubviews() {
        flipContainerView = UIView()
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "playOrPausePreview")
        tapGestureRecognizer.delegate = self
        flipContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        self.addSubview(flipContainerView)
        
        if (self.flipImageView != nil) {
            flipImageView.contentMode = UIViewContentMode.ScaleAspectFit
            flipContainerView.addSubview(self.flipImageView)
        }
        
        if (self.moviePlayer != nil) {
            self.moviePlayer.controlStyle = MPMovieControlStyle.None
            self.moviePlayer.scalingMode = MPMovieScalingMode.AspectFill
            self.moviePlayer.shouldAutoplay = false
            
            flipContainerView.addSubview(moviePlayer.view)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerDidFinish:", name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
        }
        
        flipWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        flipWordLabel.textColor = UIColor.whiteColor()
        
        flipContainerView.addSubview(self.flipWordLabel)
        
        rejectButton = UIButton()
        rejectButton.setImage(UIImage(named: "Deny"), forState: UIControlState.Normal)
        rejectButton.backgroundColor = UIColor.flipOrange()
        rejectButton.addTarget(self, action: "rejectButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(rejectButton)
        
        acceptButton = UIButton()
        acceptButton.setImage(UIImage(named: "Approve"), forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.avacado()
        acceptButton.addTarget(self, action: "acceptButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(acceptButton)
        
        self.setupActivityIndicator()
    }
    
    func moviePlayerDidFinish(notification: NSNotification) {
        let player = notification.object as MPMoviePlayerController
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
    }
    
    func playOrPausePreview() {
        self.delegate?.confirmFlipViewDidTapPlayOrPausePreviewButton(self)
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.backgroundColor = UIColor.blackColor()
        activityIndicator.alpha = 0
        activityIndicator.layer.cornerRadius = 8
        activityIndicator.layer.masksToBounds = true
        self.addSubview(activityIndicator)
        
        activityIndicator.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self)
            make.width.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
            make.height.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
        }
    }
    
    func makeConstraints() {
        flipContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.flipImageView)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.confirmFlipViewMakeConstraintToNavigationBarBottom(flipContainerView)
        
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.flipContainerView)
                make.width.equalTo()(self.FLIP_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.flipContainerView)
                make.right.equalTo()(self.flipContainerView)
            }

            make.height.equalTo()(self.flipImageView.mas_width)
        }
        
        if (self.moviePlayer != nil) {
            self.moviePlayer.view.mas_makeConstraints({ (make) -> Void in
                make.top.equalTo()(self.flipContainerView)
                
                if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                    make.centerX.equalTo()(self.flipContainerView)
                    make.width.equalTo()(self.FLIP_VIDEO_WIDTH)
                } else {
                    make.left.equalTo()(self.flipContainerView)
                    make.right.equalTo()(self.flipContainerView)
                }
                
                make.height.equalTo()(self.moviePlayer.view.mas_width)
            })
        }
        
        flipWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.flipContainerView).with().offset()(-self.FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self.flipContainerView)
        }
        
        rejectButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipContainerView.mas_bottom)
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
        if (flipAudioURL != nil) {
            AudioRecorderService.sharedInstance.playAudio(flipAudioURL)
        }
    }
    
    
    // MARK: - Gesture Recognizer Delegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: - Activity Indicator
    
    func showActivityIndicator() {
        self.userInteractionEnabled = false
        self.activityIndicator.startAnimating()
        UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
            self.activityIndicator.alpha = 0.8
        })
    }
    
    func hideActivityIndicator() {
        self.userInteractionEnabled = true
        self.activityIndicator.startAnimating()
        UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
            self.activityIndicator.alpha = 0
            }, completion: { (finished) -> Void in
                self.activityIndicator.stopAnimating()
        })
    }
    
    
    // MARK: - Getters
    
    func getWord() -> String! {
        return self.flipWordLabel.text
    }
    
    func getImage() -> UIImage! {
        return self.flipImageView.image
    }
}

protocol ConfirmFlipViewDelegate {
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!)
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapPlayOrPausePreviewButton(flipView: ConfirmFlipView!)
}