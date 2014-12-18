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

public class PreviewView: UIView, CustomNavigationBarDelegate, UIGestureRecognizerDelegate {
    
    private let LOW_RES_VIDEO_WIDTH: CGFloat = 240.0
    private let LOW_RES_VIDEO_MARGIN: CGFloat = 15.0
    private let SEND_BUTTON_SUBVIEWS_CENTER_MARGIN: CGFloat = 10.0

    var delegate: PreviewViewDelegate?
    
    private var flipContainerView: UIView!
    
    private var videoPlayerView: PlayerView!
    private var sendContainerView: UIView!
    private var sendContainerButtonView: UIView!
    private var sendLabel: UILabel!
    private var sendImage: UIImage!
    private var sendImageButton: UIButton!
    
    override init() {
        super.init()
        
        self.addSubviews()
    }
    
    func viewDidLoad() {
        makeConstraints()
    }

    func viewWillDisappear() {
        if (self.videoPlayerView.hasPlayer()) {
            self.videoPlayerView.player().removeObserver(self, forKeyPath: "status")
            self.stopMovie()
        }

        let videoComposer = VideoComposer()
        videoComposer.clearTempCache()
    }

    func showVideoCreationError() {
        var alertView = UIAlertView(title: "",
            message: NSLocalizedString("Preview couldn't be created. Please try again later.", comment: "Preview couldn't be created. Please try again later."),
            delegate: nil,
            cancelButtonTitle: LocalizedString.OK)
        alertView.show()
    }

    func setupVideoPlayerWithFlips(flips: Array<Flip>) {
        self.videoPlayerView.setupPlayerWithFlips(flips, completion: { (player) -> Void in
            if (player!.status == AVPlayerStatus.ReadyToPlay) {
                self.playMovie()
            }

            player!.addObserver(self, forKeyPath: "status", options:NSKeyValueObservingOptions.New, context:nil);
        })
    }

    func addSubviews() {
        flipContainerView = UIView()
        flipContainerView.backgroundColor = UIColor.deepSea()
        self.addSubview(flipContainerView)
        
        self.addVideoPlayerView()
        
        self.sendContainerView = UIView()
        self.sendContainerView.backgroundColor = UIColor.avacado()
        self.sendContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "sendButtonTapped:"))
        self.addSubview(sendContainerView)
        
        
        self.sendLabel = UILabel()
        self.sendLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h1)
        self.sendLabel.text = "Send"
        self.sendLabel.textColor = UIColor.whiteColor()
        self.sendContainerView.addSubview(sendLabel)
        
        self.sendImage = UIImage(named: "Send")
        self.sendImageButton = UIButton()
        self.sendImageButton.setImage(self.sendImage, forState: UIControlState.Normal)
        
        self.sendContainerView.addSubview(sendImageButton)
    }

    func addVideoPlayerView() {
        self.videoPlayerView = PlayerView()
        self.videoPlayerView.useCache = false
        self.videoPlayerView.loadPlayerOnInit = true
        self.flipContainerView.addSubview(self.videoPlayerView)
    }

    func makeConstraints() {
        self.flipContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)

            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.height.equalTo()(self.LOW_RES_VIDEO_WIDTH + (2 * self.LOW_RES_VIDEO_MARGIN))
            } else {
                make.height.equalTo()(self.mas_width)
            }
        }

        // asking help to delegate to align the container with navigation bar
        self.delegate?.previewViewMakeConstraintToNavigationBarBottom(self.flipContainerView)
        
        self.videoPlayerView.mas_makeConstraints({ (make) -> Void in
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.flipContainerView)
                make.centerY.equalTo()(self.flipContainerView)
                make.width.equalTo()(self.LOW_RES_VIDEO_WIDTH)
            } else {
                make.top.equalTo()(self.flipContainerView)
                make.left.equalTo()(self.flipContainerView)
                make.right.equalTo()(self.flipContainerView)
            }
            
            make.height.equalTo()(self.videoPlayerView.mas_width)
        })
        
        self.sendContainerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipContainerView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }
        
        self.sendLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.sendContainerView)
            make.bottom.equalTo()(self.sendContainerView.mas_centerY).with().offset()(-self.SEND_BUTTON_SUBVIEWS_CENTER_MARGIN)
        }
        
        self.sendImageButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.sendContainerView)
            make.top.equalTo()(self.sendLabel.mas_bottom).with().offset()(self.SEND_BUTTON_SUBVIEWS_CENTER_MARGIN)
        }
        
    }
    
    func sendButtonTapped(sendButton: UIButton!) {
        self.sendImageButton.highlighted = true
        self.delegate?.previewButtonDidTapSendButton(self)
    }
    
    
    // MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: - Movie player controls

    private func playMovie() {
        self.videoPlayerView.play()
    }
    
    private func pauseMovie() {
        self.videoPlayerView.pause()
    }
    
    func stopMovie() {
        self.pauseMovie()
    }


    // MARK: - KVO

    override public func observeValueForKeyPath(keyPath: String, ofObject: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "status" && ofObject is AVQueuePlayer) {
            let player: AVQueuePlayer = ofObject as AVQueuePlayer

            if (player.status == AVPlayerStatus.ReadyToPlay && !self.videoPlayerView.isPlaying) {
                self.playMovie()
            } else {
                self.showVideoCreationError()
            }
        }
    }


    // MARK: - Nav Bar Delegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.delegate?.previewViewDidTapBackButton(self)
    }
    
    
    // MARK: - Required inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol PreviewViewDelegate {
    func previewViewDidTapBackButton(previewView: PreviewView!)
    func previewButtonDidTapSendButton(previewView: PreviewView!)
    func previewViewMakeConstraintToNavigationBarBottom(container: UIView!)
}