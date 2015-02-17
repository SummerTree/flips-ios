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
            self.stopMovie()
        }

        let videoComposer = VideoComposer()
        videoComposer.clearTempCache()
    }

    func setupVideoPlayerWithFlips(flips: Array<Flip>) {
        self.videoPlayerView.setupPlayerWithFlips(flips)
    }

    func addSubviews() {
        self.videoPlayerView = PlayerView()
        self.videoPlayerView.loadPlayerOnInit = true
        self.videoPlayerView.backgroundColor = UIColor.deepSea()
        self.addSubview(self.videoPlayerView)
        
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
        self.sendImageButton.userInteractionEnabled = false
        self.sendImageButton.setImage(self.sendImage, forState: UIControlState.Normal)
        
        self.sendContainerView.addSubview(sendImageButton)
    }

    func makeConstraints() {
        self.videoPlayerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)

            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.height.equalTo()(self.LOW_RES_VIDEO_WIDTH + (2 * self.LOW_RES_VIDEO_MARGIN))
            } else {
                make.height.equalTo()(self.mas_width)
            }
        }

        // asking help to delegate to align the container with navigation bar
        self.delegate?.previewViewMakeConstraintToNavigationBarBottom(self.videoPlayerView)
        
        self.sendContainerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.videoPlayerView.mas_bottom)
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