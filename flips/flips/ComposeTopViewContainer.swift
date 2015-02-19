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

class ComposeTopViewContainer: UIView, CameraViewDelegate, FlipViewerDelegate {
    
    private let ANIMATION_TRANSITON_DURATION: NSTimeInterval = 0.3
    private let AUDIO_RECORDING_PROGRESS_BAR_HEIGHT: CGFloat = 5.0
    
    private var cameraPreview: CameraView!
    private var cameraFilterImageView: UIImageView!
    private var cameraWordLabel: UILabel!
    private var captureProgressBar: UIView!
    
    private var flipViewer: FlipViewer!
    
    var delegate: ComposeTopViewContainerDelegate?
    
    
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
        cameraPreview.alpha = 1.0
        cameraPreview.delegate = self
        self.addSubview(cameraPreview)
        
        captureProgressBar = UIView()
        captureProgressBar.backgroundColor = UIColor.avacado()
        self.addSubview(captureProgressBar)
        
        cameraFilterImageView = UIImageView(image: UIImage(named: "Filter_Photo"))
        cameraFilterImageView.alpha = 1.0
        cameraFilterImageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(cameraFilterImageView)
        
        cameraWordLabel = UILabel.flipWordLabel()
        cameraWordLabel.alpha = 1.0
        cameraWordLabel.sizeToFit()
        self.addSubview(cameraWordLabel)
        
        flipViewer = FlipViewer()
        flipViewer.addGestureRecognizer(UITapGestureRecognizer(target: flipViewer, action: "viewTapped"))
        flipViewer.delegate = self
        self.addSubview(flipViewer)
        self.sendSubviewToBack(flipViewer)
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
        
        cameraFilterImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.cameraPreview)
            make.left.equalTo()(self.cameraPreview)
            make.bottom.equalTo()(self.cameraPreview)
            make.right.equalTo()(self.cameraPreview)
        }
        
        cameraWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self)
        }
        
        flipViewer.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.cameraPreview.mas_width)
        }
    }
    
    // MARK: - Life Cycle
    
    func viewWillAppear() {
        self.flipViewer.registerObservers()
    }
    
    func viewWillDisappear() {
        self.flipViewer.removeOberservers()
    }
    
    
    // MARK: - Container State Setter Methods
    
    func showCameraWithWord(word: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraPreview.registerObservers()
            
            self.cameraWordLabel.text = word
            self.cameraWordLabel.sizeToFit()
            UIView.animateWithDuration(self.ANIMATION_TRANSITON_DURATION, animations: { () -> Void in
                self.cameraPreview.alpha = 1.0
                self.cameraWordLabel.alpha = 1.0
                
                self.flipViewer.alpha = 0.0
                self.updateConstraintsIfNeeded()
                
                self.sendSubviewToBack(self.flipViewer)
            })
        })
    }
    
    func showFlip(flipId: String, withWord word: String) {
        let flipDataSource = FlipDataSource()
        if let flip = flipDataSource.retrieveFlipWithId(flipId) {
            FlipsCache.sharedInstance.get(NSURL(string: flip.backgroundURL)!,
                success: { (localPath: String!) in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UIView.animateWithDuration(1.0, animations: { () -> Void in
                            self.flipViewer.setWord(word)
                            self.flipViewer.setVideoURL(NSURL.fileURLWithPath(localPath)!)
                            self.cameraPreview.removeObservers()
                            self.cameraPreview.alpha = 0.0
                            self.flipViewer.alpha = 1.0
                            self.bringSubviewToFront(self.flipViewer)
                        })
                    })
                },
                failure: { (error: FlipError) in
                    println("Failed to get resource from cache, error: \(error)")
                    //TODO enhance error handling
                })
        } else {
            UIAlertView.showUnableToLoadFlip()
        }
    }
    
    func showImage(image: UIImage, andText text: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraPreview.removeObservers()
            
            UIView.animateWithDuration(self.ANIMATION_TRANSITON_DURATION, animations: { () -> Void in
                self.cameraPreview.alpha = 0.0
                
                self.cameraWordLabel.alpha = 0.0
                
                self.flipViewer.alpha = 1.0
                self.flipViewer.setWord(text)
                self.flipViewer.setImage(image)
            })
        })
    }
    
    
    // MARK: - ProgressBar Handler
    
    func startRecordingProgressBar() {
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
        delegate?.composeTopViewContainer(self, didFinishRecordingVideoAtUrl: videoURL, withSuccess: success)
    }
    
    func cameraViewDidTapMicrophoneButton(cameraView: CameraView) {
        delegate?.composeTopViewContainerDidTapMicrophoneButton(self)
    }
    
    
    // MARK: - FlipViewerDelegate
    
    func flipViewerStartedPlayingContent() {
        delegate?.enableUserInteractionWithComposeView(false)
    }
    
    func flipViewerFinishedPlayingContent() {
        delegate?.enableUserInteractionWithComposeView(true)
    }
}


protocol ComposeTopViewContainerDelegate {
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, withSuccess success: Bool)
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, cameraAvailable available: Bool)
    
    func composeTopViewContainerDidTapMicrophoneButton(composeTopViewContainer: ComposeTopViewContainer)
    
    func enableUserInteractionWithComposeView(enable: Bool)
    
}

