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

class ComposeBottomViewContainer : UIView, MyMugsViewDelegate {
    
    private let GRID_BUTTON_MARGIN_LEFT: CGFloat = 37.5
    private let GALLERY_BUTTON_MARGIN_RIGHT: CGFloat = 37.5
    
    private var cameraButtonsView: UIView!
    private var takePictureButton: UIButton!
    private var captureAudioButton: UIButton!
    private var cancelCaptureAudioButton: UIButton!

    private var gridButton: UIButton!
    private var galleryButton: UIButton!

    private var myMugsView: MyMugsView!
    
    var delegate: ComposeBottomViewContainerDelegate?
    var dataSource: ComposeBottomViewContainerDataSource?
    
    
    override init() {
        super.init(frame: CGRect.zeroRect)
        
        self.addSubviews()
        self.addConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        self.backgroundColor = UIColor.sand()

        self.addCameraButtons()
        
        myMugsView = MyMugsView()
        myMugsView.delegate = self
        myMugsView.alpha = 0.0
        self.addSubview(myMugsView)
    }
    
    private func addConstraints() {
        self.addCameraButtonsViewConstraints()
        
        myMugsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.cameraButtonsView.mas_right)
            make.top.equalTo()(self)
            make.width.equalTo()(self.cameraButtonsView)
            make.height.equalTo()(self)
        }
    }
    
    private func addCameraButtons() {
        cameraButtonsView = UIView()
        self.addSubview(cameraButtonsView)
        
        captureAudioButton = UIButton()
        captureAudioButton.hidden = true
        captureAudioButton.setImage(UIImage(named: "Capture_Audio"), forState: .Normal)
        captureAudioButton.sizeToFit()
        captureAudioButton.addTarget(self, action: "captureAudioButtonTapped:", forControlEvents: UIControlEvents.TouchDown)
        cameraButtonsView.addSubview(captureAudioButton)
        
        cancelCaptureAudioButton = UIButton()
        cancelCaptureAudioButton.hidden = true
        cancelCaptureAudioButton.setImage(UIImage(named: "Cancel_Audio"), forState: .Normal)
        cancelCaptureAudioButton.sizeToFit()
        cancelCaptureAudioButton.addTarget(self, action: "cancelCaptureAudioButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cameraButtonsView.addSubview(cancelCaptureAudioButton)
        
        takePictureButton = UIButton()
        takePictureButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        takePictureButton.sizeToFit()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "shutterButtonLongPressAction:")
        longPress.minimumPressDuration = 0.5
        longPress.allowableMovement = true
        takePictureButton.addGestureRecognizer(longPress)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "shutterButtonTapAction:")
        takePictureButton.addGestureRecognizer(tapGesture)
        
        cameraButtonsView.addSubview(takePictureButton)
        
        gridButton = UIButton()
        gridButton.setImage(UIImage(named: "Grid"), forState: .Normal)
        gridButton.sizeToFit()
        gridButton.addTarget(self, action: "gridButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cameraButtonsView.addSubview(gridButton)
        
        galleryButton = UIButton()
        galleryButton.setImage(UIImage(named: "Church"), forState: .Normal)
        galleryButton.addTarget(self, action: "galleryButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cameraButtonsView.addSubview(galleryButton)
    }
    
    private func addCameraButtonsViewConstraints() {
        cameraButtonsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self)
            make.height.equalTo()(self)
        }
        
        cancelCaptureAudioButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.cameraButtonsView).with().offset()(self.GRID_BUTTON_MARGIN_LEFT)
            make.centerY.equalTo()(self.cameraButtonsView)
            make.width.equalTo()(self.cancelCaptureAudioButton.frame.width)
            make.height.equalTo()(self.cancelCaptureAudioButton.frame.height)
        }
        
        gridButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.cameraButtonsView).with().offset()(self.GRID_BUTTON_MARGIN_LEFT)
            make.centerY.equalTo()(self.cameraButtonsView)
            make.width.equalTo()(self.gridButton.frame.width)
            make.height.equalTo()(self.gridButton.frame.height)
        }
        
        captureAudioButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.cameraButtonsView)
            make.centerY.equalTo()(self.cameraButtonsView)
            make.width.equalTo()(self.captureAudioButton.frame.width)
            make.height.equalTo()(self.captureAudioButton.frame.height)
        }
        
        takePictureButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.cameraButtonsView)
            make.centerY.equalTo()(self.cameraButtonsView)
            make.width.equalTo()(self.takePictureButton.frame.width)
            make.height.equalTo()(self.takePictureButton.frame.height)
        }
        
        galleryButton.mas_makeConstraints { (make) -> Void in
            make.right.equalTo()(self.cameraButtonsView).with().offset()(-self.GALLERY_BUTTON_MARGIN_RIGHT)
            make.centerY.equalTo()(self.cameraButtonsView)
            
            // intentional use of grid button width/height
            make.width.equalTo()(self.gridButton.frame.width)
            make.height.equalTo()(self.gridButton.frame.height)
        }
    }
    
    
    // MARK: - View State Setter
    
    func showCameraButtons() {
        self.slideToCameraView(notifyDelegate: false)
    }
    
    func showMyMugs() {
        self.slideToMyMugsView(notifyDelegate: false)
    }
    
    func showAudioRecordButton() {
        self.showRecordingView()
    }
    
    private func showRecordingView() {
        self.captureAudioButton.hidden = false
        self.cancelCaptureAudioButton.hidden = false
        self.takePictureButton.hidden = true
        self.galleryButton.hidden = true
        self.gridButton.hidden = true
    }
    
    private func hideRecordingView() {
        self.captureAudioButton.hidden = true
        self.cancelCaptureAudioButton.hidden = true
        self.takePictureButton.hidden = false
        self.galleryButton.hidden = false
        self.gridButton.hidden = false
    }
    
    // MARK: - Button Handlers
    
    func captureAudioButtonTapped(sender: UIButton!) {
        self.delegate?.composeBottomViewContainerDidTapCaptureAudioButton(self)
        self.hideRecordingView()
    }
    
    func cancelCaptureAudioButtonTapped(sender: UIButton!) {
        self.delegate?.composeBottomViewContainerDidTapSkipAudioButton(self)
        self.hideRecordingView()
    }

    func shutterButtonLongPressAction(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == .Began) {
            self.delegate?.composeBottomViewContainerDidHoldShutterButton(self)
        }
    }
    
    func shutterButtonTapAction(gesture: UITapGestureRecognizer) {
        self.delegate?.composeBottomViewContainerDidTapTakePictureButton(self)
    }
    
    func gridButtonTapped(sender: UIButton!) {
        self.slideToMyMugsView()
    }
    
    func galleryButtonTapped(sender: UIButton!) {
        self.delegate?.composeBottomViewContainerDidTapGalleryButton(self)
    }
    
    
    // MARK: - MyMugs Load Methods
    
    func reloadMyMugs() {
        
    }
    
    
    // MARK: - Views Transitions
    
    private func slideToMyMugsView(notifyDelegate: Bool = true) {
        if (notifyDelegate) {
            delegate?.composeBottomViewContainerWillOpenMyMugsView(self)
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.myMugsView.alpha = 1.0
            
            self.myMugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self)
                make.right.equalTo()(self)
                make.top.equalTo()(self)
                make.height.equalTo()(self)
            })
            
            self.cameraButtonsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.myMugsView.mas_right)
                make.width.equalTo()(self)
                make.top.equalTo()(self)
                make.height.equalTo()(self)
            })
            
            self.layoutIfNeeded()
        })
    }
    
    private func slideToCameraView(notifyDelegate: Bool = true) {
        if (notifyDelegate) {
            delegate?.composeBottomViewContainerWillOpenCameraControls(self)
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.myMugsView.alpha = 0.0

            self.myMugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.width.equalTo()(self)
                make.right.equalTo()(self.mas_left)
                make.top.equalTo()(self)
                make.height.equalTo()(self)
            })
            
            self.cameraButtonsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self)
                make.right.equalTo()(self)
                make.top.equalTo()(self)
                make.height.equalTo()(self)
            })
            
            self.layoutIfNeeded()
        })
    }
    
    
    // MARK: - MyMugsView Delegate
    
    func myMugsViewDidTapAddMug(myMugsView: MyMugsView!) {
        slideToCameraView()
    }
    
    func myMugsView(myMugsView: MyMugsView!, didChangeMugSelection mug: Mug?) {
        // TODO: delegate
        
//        if (mug == nil) { // User deselected current mug
//            self.mugTexts[selectedWordIndex].associatedMug = nil
//            self.mugImageView.image = UIImage.imageWithColor(UIColor.avacado())
//        } else {
//            self.mugTexts[selectedWordIndex].associatedMug = mug
//            let mugImagePath = mug!.backgroundContentLocalPath()
//            self.mugImageView.image = UIImage(contentsOfFile: mugImagePath)
//        }
    }
    
    func myMugsView(myMugsView: MyMugsView!, mugsForSelectedWord hasMugs: Bool!) {
//        if (hasMugs!) {
//            self.slideToMyMugsView()
//        } else {
//            if (!isAlreadyUsingAPicture) {
//                self.slideToCameraView()
//            }
//        }
    }
}

protocol ComposeBottomViewContainerDelegate {
    
    func composeBottomViewContainerDidTapCaptureAudioButton(composeBottomViewContainer: ComposeBottomViewContainer)
    
    func composeBottomViewContainerDidTapSkipAudioButton(composeBottomViewContainer: ComposeBottomViewContainer)

    func composeBottomViewContainerDidHoldShutterButton(composeBottomViewContainer: ComposeBottomViewContainer)

    func composeBottomViewContainerDidTapTakePictureButton(composeBottomViewContainer: ComposeBottomViewContainer)
    
    func composeBottomViewContainerWillOpenMyMugsView(composeBottomViewContainer: ComposeBottomViewContainer)
    
    func composeBottomViewContainerWillOpenCameraControls(composeBottomViewContainer: ComposeBottomViewContainer)
    
    func composeBottomViewContainerDidTapGalleryButton(composeBottomViewContainer: ComposeBottomViewContainer)
    
}

protocol ComposeBottomViewContainerDataSource {
    
    func composeBottomViewContainerFlipsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [Mug]
}
