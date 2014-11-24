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

class ComposeBottomViewContainer : UIView, MyFlipsViewDelegate, MyFlipsViewDataSource {
    
    private let GRID_BUTTON_MARGIN_LEFT: CGFloat = 37.5
    private let GALLERY_BUTTON_MARGIN_RIGHT: CGFloat = 37.5
    
    private let FLIP_CREATED_TEXT = NSLocalizedString("Flip Created", comment: "Flip Created")
    
    private let BUILDER_ALL_FLIPS_CREATED_MESSAGE = NSLocalizedString("Oh snap! We're tapped!\nPress the \"+\" button to add some words to record, or check back later... we'll add more suggested words from time to time.", comment: "Oh snap!  We're tapped!\nPress the \"+\" button to add some words to record, or check back later... we'll add more suggested words from time to time.")
    
    private var cameraButtonsView: UIView!
    private var takePictureButton: UIButton!
    private var captureAudioButton: UIButton!
    private var cancelCaptureAudioButton: UIButton!
    
    private var gridButton: UIButton!
    private var galleryButton: UIButton!
    
    private var builderFlipCreateLabel: UILabel!
    
    private var myMugsView: MyFlipsView!
    
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
        
        self.builderFlipCreateLabel = UILabel()
        self.builderFlipCreateLabel.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h1)
        self.builderFlipCreateLabel.text = FLIP_CREATED_TEXT
        self.builderFlipCreateLabel.hidden = true
        self.builderFlipCreateLabel.textColor = UIColor.deepSea()
        self.builderFlipCreateLabel.backgroundColor = UIColor.sand()
        self.builderFlipCreateLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.builderFlipCreateLabel)
        
        self.addCameraButtons()
        
        myMugsView = MyFlipsView()
        myMugsView.delegate = self
        myMugsView.dataSource = self
        myMugsView.alpha = 0.0
        self.addSubview(myMugsView)
    }
    
    private func addConstraints() {
        builderFlipCreateLabel.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.top.equalTo()(self)
            make.width.equalTo()(self)
            make.height.equalTo()(self)
        }
        
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
        longPress.allowableMovement = 50.0
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
        galleryButton.setImage(UIImage(named: "Filter_Photo"), forState: .Normal)
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
    
    func setCameraButtonEnabled(enabled: Bool) {
        self.takePictureButton.enabled = enabled
    }
    
    func showCameraButtons() {
        self.hideFlipCreatedMessage()
        self.slideToCameraView(notifyDelegate: false)
        
        if let canShowMyFlipsButton = dataSource?.composeBottomViewContainerCanShowMyFlipsButton(self) {
            if (canShowMyFlipsButton) {
                gridButton.hidden = false
            } else {
                gridButton.hidden = true
            }
        }
    }
    
    func showMyMugs() {
        self.hideFlipCreatedMessage()
        self.reloadMyMugs()
        self.slideToMyMugsView(notifyDelegate: false)
    }
    
    func showAudioRecordButton() {
        self.hideFlipCreatedMessage()
        self.showRecordingView()
    }
    
    private func showRecordingView() {
        self.hideFlipCreatedMessage()
        self.captureAudioButton.hidden = false
        self.cancelCaptureAudioButton.hidden = false
        self.takePictureButton.hidden = true
        self.galleryButton.hidden = true
        self.gridButton.hidden = true
    }
    
    func hideRecordingView() {
        self.captureAudioButton.hidden = true
        self.cancelCaptureAudioButton.hidden = true
        self.takePictureButton.hidden = false
        self.galleryButton.hidden = false
        self.gridButton.hidden = false
    }
    
    func showFlipCreateMessage() {
        self.bringSubviewToFront(self.builderFlipCreateLabel)
        self.builderFlipCreateLabel.hidden = false
    }
    
    func showAllFlipCreateMessage() {
        self.builderFlipCreateLabel.numberOfLines = 5
        var text = NSMutableAttributedString(string: BUILDER_ALL_FLIPS_CREATED_MESSAGE)
        text.addAttribute(NSFontAttributeName, value: UIFont.avenirNextBoldItalic(UIFont.HeadingSize.h5), range: NSMakeRange(0, 23))
        text.addAttribute(NSFontAttributeName, value: UIFont.avenirNextBold(UIFont.HeadingSize.h6), range: NSMakeRange(23, text.length-23))
        
        self.builderFlipCreateLabel.attributedText = text
        self.showFlipCreateMessage()
    }
    
    func hideFlipCreatedMessage() {
        self.sendSubviewToBack(self.builderFlipCreateLabel)
        self.builderFlipCreateLabel.hidden = true
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
        myMugsView.reload()
    }
    
    func updateGalleryButtonImage() {
        galleryButton.setLastCameraPhotoAsButtonImage()
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
    
    
    // MARK: - MyFlipsView Delegate
    
    func myFlipsViewDidTapAddFlip(myFlipsView: MyFlipsView!) {
        slideToCameraView()
    }
    
    func myFlipsView(myFlipsView: MyFlipsView!, didTapAtIndex index: Int) {
        let flipIds = dataSource?.composeBottomViewContainerFlipIdsForHighlightedWord(self) as [String]!
        delegate?.composeBottomViewContainer(self, didTapAtFlipWithId: flipIds[index])
    }
    
    
    // MARK: - MyFlipsViewDataSource
    
    func myFlipsViewNumberOfFlips() -> Int {
        let flipIds = dataSource?.composeBottomViewContainerFlipIdsForHighlightedWord(self) as [String]!
        return flipIds.count
    }
    
    func myFlipsView(myFlipsView: MyFlipsView, flipIdAtIndex index: Int) -> String {
        let flipIds = dataSource?.composeBottomViewContainerFlipIdsForHighlightedWord(self) as [String]!
        return flipIds[index]
    }
    
    func myFlipsViewSelectedFlipId() -> String? {
        let flipId = dataSource?.flipIdForHighlightedWord()
        return flipId
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
    
    func composeBottomViewContainer(composeBottomViewContainer: ComposeBottomViewContainer, didTapAtFlipWithId flipId: String)
}

protocol ComposeBottomViewContainerDataSource {
    
    func composeBottomViewContainerFlipIdsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [String]
    
    func flipIdForHighlightedWord() -> String?
    
    func composeBottomViewContainerCanShowMyFlipsButton(composeBottomViewContainer: ComposeBottomViewContainer) -> Bool
}
