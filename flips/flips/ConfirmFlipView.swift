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

import UIKit
import MediaPlayer

public class ConfirmFlipView : UIView, UIGestureRecognizerDelegate {
    
    weak var delegate: ConfirmFlipViewDelegate?
    
    private let LOW_RES_VIDEO_WIDTH: CGFloat = 240.0
    private let LOW_RES_VIDEO_MARGIN: CGFloat = 15.0
    private let ACTIVITY_INDICATOR_SIZE: CGFloat = 100
    private let ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION = 0.25
    
    private var videoPlayerView: PlayerView!
    private var rejectButton: UIButton!
    private var acceptButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!

    convenience init() {
        self.init()
        self.addSubviews()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayerWithWord(word: String, videoURL: NSURL) {
        self.videoPlayerView.setupPlayerWithWord(word, videoURL: videoURL, thumbnailURL: nil)
    }
    
    func play() {
        self.videoPlayerView.play()
    }
    
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        self.makeConstraints()
        self.layoutIfNeeded()
    }
    
    func viewWillDisappear() {
        self.videoPlayerView.releaseResources()
    }
    
    func addSubviews() {
        self.videoPlayerView = PlayerView()
        self.videoPlayerView.loadPlayerOnInit = true
        self.addSubview(self.videoPlayerView)
        
        self.rejectButton = UIButton()
        self.rejectButton.setImage(UIImage(named: "Deny"), forState: UIControlState.Normal)
        self.rejectButton.backgroundColor = UIColor.flipOrange()
        self.rejectButton.addTarget(self, action: "rejectButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.rejectButton)
        
        self.acceptButton = UIButton()
        self.acceptButton.setImage(UIImage(named: "Approve"), forState: UIControlState.Normal)
        self.acceptButton.backgroundColor = UIColor.avacado()
        self.acceptButton.addTarget(self, action: "acceptButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.acceptButton)
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.activityIndicator.backgroundColor = UIColor.blackColor()
        self.activityIndicator.alpha = 0
        self.activityIndicator.layer.cornerRadius = 8
        self.activityIndicator.layer.masksToBounds = true
        self.addSubview(self.activityIndicator)
    }

    func makeConstraints() {
        self.videoPlayerView.mas_remakeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)

            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.height.equalTo()(self.LOW_RES_VIDEO_WIDTH + (2 * self.LOW_RES_VIDEO_MARGIN))
            } else {
                make.height.equalTo()(self.mas_width)
            }
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.confirmFlipViewMakeConstraintToNavigationBarBottom(videoPlayerView)

        self.rejectButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self.mas_centerX)
            make.bottom.equalTo()(self)
        }

        self.acceptButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerView.mas_bottom)
            make.left.equalTo()(self.mas_centerX)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }

        self.activityIndicator.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self)
            make.width.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
            make.height.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
        }

    }

    
    // MARK: - Action buttons
    
    func rejectButtonTapped() {
        self.delegate?.confirmFlipViewDidTapRejectButton(self)
    }
    
    func acceptButtonTapped() {
        self.delegate?.confirmFlipViewDidTapAcceptButton(self)
    }
    
    
    // MARK: - Activity Indicator
    
    func showActivityIndicator() {
        self.userInteractionEnabled = false
        self.acceptButton.userInteractionEnabled = false
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
                self.acceptButton.userInteractionEnabled = true
        })
    }
}

protocol ConfirmFlipViewDelegate: class {
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!)
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!)
}