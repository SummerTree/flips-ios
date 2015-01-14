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

class ConfirmFlipViewController: UIViewController, ConfirmFlipViewDelegate {
    
    var delegate: ConfirmFlipViewControllerDelegate?
    
    private var confirmFlipView: ConfirmFlipView!
    private var previewFlipTimer: NSTimer!
    private var isPlaying = true
    
    var showPreviewButton = true
    
    private var flipWord: String!
    private var flipImage: UIImage?
    private var flipAudioURL: NSURL?
    private var flipVideoURL: NSURL?
    
    convenience init(flipWord: String!, flipPicture: UIImage?, flipAudio: NSURL?) {
        self.init()

        self.flipWord = flipWord
        self.flipImage = flipPicture
        self.flipAudioURL = flipAudio
        
        var image = flipPicture
        if (image == nil) {
            image = UIImage.imageWithColor(UIColor.avacado())
        }
        
        self.confirmFlipView = ConfirmFlipView(word: flipWord, background: image, audio: flipAudio)
    }
    
    convenience init(flipWord: String!, flipVideo: NSURL?) {
        self.init()

        self.flipWord = flipWord
        self.flipVideoURL = flipVideo
        
        self.confirmFlipView = ConfirmFlipView(word: flipWord, video: flipVideo)
    }
    
    override func loadView() {
        self.view = self.confirmFlipView
        self.view.backgroundColor = UIColor.whiteColor()
        self.confirmFlipView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWhiteNavBarWithoutButtons(self.title!)
        
        if (showPreviewButton) {
            var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
            previewBarButton.enabled = false
            previewBarButton.tintColor = UIColor.orangeColor()
            self.navigationItem.rightBarButtonItem = previewBarButton
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        confirmFlipView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.startPreview()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.previewFlipTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "startPreview", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.previewFlipTimer.invalidate()
        self.confirmFlipView.viewWillDisappear()
    }
    
    func startPreview() {
        self.isPlaying = true
        if (self.flipAudioURL != nil) {
            self.confirmFlipView.playAudio()
        }
        
        if (self.flipVideoURL != nil) {
            self.confirmFlipView.playVideo()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    
    // MARK: - ConfirmFlipViewDelegate
    
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        pictureContainerView.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
    
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!) {
        let flipDataSource = FlipDataSource()
        self.confirmFlipView.showActivityIndicator()
        self.previewFlipTimer.invalidate()
        
        var createFlipSuccessBlock : CreateFlipSuccess = { (flip) -> Void in
            self.navigationController?.popViewControllerAnimated(false)
            self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: true, flip: flip)
            self.confirmFlipView.hideActivityIndicator()
        }
        var createFlipFailBlock : CreateFlipFail = { (flipError) -> Void in
            let errorTitle = flipError.error?
            let errorMessage = flipError.details?
            self.confirmFlipView.hideActivityIndicator()
            self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: false, flip: nil)
            var alertView = UIAlertView(title: errorTitle, message: errorMessage, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        }
        
        if (flipVideoURL == nil) {
            flipDataSource.createFlipWithWord(flipView.getWord(),
                backgroundImage: self.flipImage,
                soundURL: self.flipAudioURL,
                createFlipSuccess: createFlipSuccessBlock,
                createFlipFail: createFlipFailBlock)
        } else {
            flipDataSource.createFlipWithWord(self.flipWord,
                videoURL: self.flipVideoURL!,
                createFlipSuccess: createFlipSuccessBlock,
                createFlipFail: createFlipFailBlock)
        }
    }
    
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!) {
        self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: false, flip: nil)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func confirmFlipViewDidTapPlayOrPausePreviewButton(flipView: ConfirmFlipView!) {
        if (isPlaying) {
            self.previewFlipTimer.invalidate()
        } else {
            self.startPreview()
            self.previewFlipTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "startPreview", userInfo: nil, repeats: true)
        }

        self.isPlaying = !self.isPlaying
    }
}

protocol ConfirmFlipViewControllerDelegate {
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success:Bool, flip: Flip?)
}