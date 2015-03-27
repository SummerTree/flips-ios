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

class ComposeTopViewContainer: UIView, CameraViewDelegate, PlayerViewDelegate {
    
    private let ANIMATION_TRANSITON_DURATION: NSTimeInterval = 0.3
    private let AUDIO_RECORDING_PROGRESS_BAR_HEIGHT: CGFloat = 5.0
    
    private var filterImageView: UIImageView!
    private var cameraPreview: CameraView!
    private var captureProgressBar: UIView!
    
    private var flipWordLabel: UILabel!
    private var flipImageView: UIImageView!
    private var flipPlayerView: PlayerView!
    
    private enum PreviewType {
        case None
        case Camera
        case Image
        case Flip
    }
    
    private var previewType: PreviewType = PreviewType.None
    
    weak var delegate: ComposeTopViewContainerDelegate?
    
    
    // MARK: - Initialization Methods
    
    override init() {
        super.init(frame: CGRect.zeroRect)
        
        self.addSubviews()
        self.addConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        cameraPreview = CameraView(interfaceOrientation: AVCaptureVideoOrientation.Portrait, showAvatarCropArea: false, showMicrophoneButton: true)
        cameraPreview.delegate = self
        self.addSubview(cameraPreview)
        
        captureProgressBar = UIView()
        captureProgressBar.backgroundColor = UIColor.avacado()
        self.addSubview(captureProgressBar)
        
        filterImageView = UIImageView(image: UIImage(named: "Filter_Photo"))
        filterImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(filterImageView)
        
        flipWordLabel = UILabel.flipWordLabel()
        flipWordLabel.sizeToFit()
        self.addSubview(flipWordLabel)
        
        flipImageView = UIImageView()
        flipImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(flipImageView)
    }
    
    private func addConstraints() {
        cameraPreview.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.height.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.mas_height)
        }
        
        captureProgressBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.height.equalTo()(self.AUDIO_RECORDING_PROGRESS_BAR_HEIGHT)
            make.width.equalTo()(0)
        }
        
        filterImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.cameraPreview)
            make.left.equalTo()(self.cameraPreview)
            make.bottom.equalTo()(self.cameraPreview)
            make.right.equalTo()(self.cameraPreview)
        }
        
        flipWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self)
        }
        
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.height.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.mas_height)
        }
    }
    
    private func createFlipPlayerView() {
        if (self.flipPlayerView != nil) {
            self.flipPlayerView.removeFromSuperview()
            self.flipPlayerView.releaseResources()
        }

        self.flipPlayerView = PlayerView()
        self.flipPlayerView.loadPlayerOnInit = true
        self.flipPlayerView.delegate = self
        self.addSubview(flipPlayerView)
        
        flipPlayerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.cameraPreview.mas_width)
        }
    }
    
    private func switchToPreviewType(type: PreviewType) {
        if (self.previewType == type && type != PreviewType.Flip) {
            return
        }
        
        self.flipWordLabel.text = nil
        self.flipImageView.image = nil
        
        if (self.previewType == PreviewType.Camera) {
            self.cameraPreview.removeObservers()
            self.cameraPreview.alpha = 0
        } else if (self.previewType == PreviewType.Flip) {
            self.flipPlayerView.removeFromSuperview()
            self.flipPlayerView.releaseResources()
        }
        
        if (type == PreviewType.Camera) {
            self.cameraPreview.registerObservers()
            self.cameraPreview.alpha = 1.0
            self.bringSubviewToFront(self.cameraPreview)
            self.bringSubviewToFront(self.filterImageView)
            self.bringSubviewToFront(self.flipWordLabel)
        } else if (type == PreviewType.Flip) {
            self.createFlipPlayerView()
        } else if (type == PreviewType.Image) {
            self.bringSubviewToFront(self.flipImageView)
            self.bringSubviewToFront(self.filterImageView)
            self.bringSubviewToFront(self.flipWordLabel)
        } else if (type == PreviewType.None) {
            // Show "disabled" camera
            self.cameraPreview.alpha = 1.0
            self.bringSubviewToFront(self.cameraPreview)
            self.bringSubviewToFront(self.filterImageView)
        }
        
        self.previewType = type
    }
    
    // MARK: - Life Cycle
    
    func viewWillAppear() {
        if (self.previewType == PreviewType.Camera) {
            self.cameraPreview.registerObservers()
        }
    }
    
    func viewWillDisappear() {
        if (self.previewType == PreviewType.Camera) {
            self.cameraPreview.removeObservers()
        } else if (self.previewType == PreviewType.Flip) {
            self.flipPlayerView.pause()
        }
    }
    
    
    // MARK: - Container State Setter Methods

    func showEmptyState() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.switchToPreviewType(PreviewType.None)
        })
    }

    func showCameraWithWord(word: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.switchToPreviewType(PreviewType.Camera)
            self.flipWordLabel.text = word
        })
    }
    
    func showFlip(flipId: String, withWord word: String) {
        let flipDataSource = FlipDataSource()
        if let flip = flipDataSource.retrieveFlipWithId(flipId) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.switchToPreviewType(PreviewType.Flip)
                self.flipPlayerView.setupPlayerWithFlips([flip], andFormattedWords: [word])
            })
        } else {
            UIAlertView.showUnableToLoadFlip()
        }
    }
    
    func showImage(image: UIImage, andText text: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.switchToPreviewType(PreviewType.Image)
            self.flipWordLabel.text = text
            self.flipImageView.image = image
        })
    }
    
    
    // MARK: - ProgressBar Handler
    
    func startRecordingProgressBar() {
        self.captureProgressBar.hidden = false
        self.bringSubviewToFront(self.captureProgressBar)

        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.captureProgressBar.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self)
                update.left.equalTo()(self)
                update.height.equalTo()(self.AUDIO_RECORDING_PROGRESS_BAR_HEIGHT)
                update.width.equalTo()(self)
            })
            
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                self.captureProgressBar.hidden = true

                self.captureProgressBar.mas_updateConstraints({ (update) -> Void in
                    update.removeExisting = true
                    update.top.equalTo()(self)
                    update.left.equalTo()(self)
                    update.height.equalTo()(self.AUDIO_RECORDING_PROGRESS_BAR_HEIGHT)
                    update.width.equalTo()(0)
                })
                
                self.layoutIfNeeded()
        }
    }
    
    
    // MARK: - Camera Controls Methods
    
    func captureVideo() {
        cameraPreview.captureVideo()
    }
    
    func capturePictureWithCompletion(success: CapturePictureSuccess, fail: CapturePictureFail) {
        cameraPreview.capturePictureWithCompletion(success, fail)
    }
    
    
    // MARK: - CameraViewDelegate
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool)  {
        delegate?.composeTopViewContainer(self, cameraAvailable: available)
    }
    
    func cameraView(cameraView: CameraView, didFinishRecordingVideoAtURL videoURL: NSURL?, withSuccess success: Bool) {
        if (!success) {
            self.captureProgressBar.hidden = true
        }
        delegate?.composeTopViewContainer(self, didFinishRecordingVideoAtUrl: videoURL, withSuccess: success)
    }
    
    func cameraViewDidTapMicrophoneButton(cameraView: CameraView) {
        delegate?.composeTopViewContainerDidTapMicrophoneButton(self)
    }
    
    
    // MARK: - FlipViewerDelegate
    
    func playerViewDidFinishPlayback(playerView: PlayerView) {
        delegate?.enableUserInteractionWithComposeView(true)
    }
    
    func playerViewIsVisible(playerView: PlayerView) -> Bool {
        return true
    }

}


protocol ComposeTopViewContainerDelegate: class {
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, withSuccess success: Bool)
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, cameraAvailable available: Bool)
    
    func composeTopViewContainerDidTapMicrophoneButton(composeTopViewContainer: ComposeTopViewContainer)
    
    func enableUserInteractionWithComposeView(enable: Bool)
    
}

