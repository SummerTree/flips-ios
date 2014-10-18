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
import AVFoundation

class ComposeView : UIView, CustomNavigationBarDelegate, CameraViewDelegate {
    
    private let MUG_IMAGE_WIDTH: CGFloat = 240.0
    private let MUGWORD_MARGIN_BOTTOM: CGFloat = 40.0
    private let MUGWORD_LIST_HEIGHT: CGFloat = 50.0
    private let GRID_BUTTON_MARGIN_LEFT: CGFloat = 37.5
    private let GALLERY_BUTTON_MARGIN_RIGHT: CGFloat = 37.5
    private let MY_MUGS_LABEL_MARGIN_TOP: CGFloat = 5.0
    private let MY_MUGS_LABEL_MARGIN_LEFT: CGFloat = 10.0
    private let ADD_MUG_BUTTON_MARGIN_TOP: CGFloat = 5.0
    
    var delegate: ComposeViewDelegate?
    
    var mugs : [MugText] = [MugText]()
    
    private var mugContainerView: UIView!
    private var cameraPreview: CameraView!
    private var mugImageView: UIImageView!
    private var mugWordLabel: UILabel!
    private var mugTextsContainer : MugTextsContainer!
    
    private var mugsOrCameraButtonsView: UIView!
    
    private var cameraButtonsView: UIView!
    private var takePictureButton: UIButton!
    private var captureAudioButton: UIButton!
    private var cancelCaptureAudioButton: UIButton!
    private var gridButton: UIButton!
    private var galleryButton: UIButton!
    
    private var mugsView: UIView!
    private var myMugsLabel: UILabel!
    private var addMugButton: UIButton!
    private var arrowToCurrentMug: UIButton!
    
    func viewDidLoad() {
        makeConstraints()
        self.layoutIfNeeded()
    }
    
    override init() {
        super.init()
        
        // just for debugging, since we don't have integration between the views
        let stringTest = "I love San Francisco!" as String
        var texts : [String] = MugStringsUtil.splitMugString(stringTest);
        createMugs(texts)
        
        addSubviews()
    }

    init(words: [String]) {
        super.init()
        createMugs(words)
        addSubviews()
    }
    
    func createMugs(texts: [String]) {
        var i: Int
        for i=0; i < texts.count; i++ {
            var text = texts[i]
            var mugText: MugText
            
            //TEMP (for tests)
            switch i {
            case 0:
                mugText = MugText(mugId: i, text: text, state: MugState.Default)
            case 1:
                mugText = MugText(mugId: i, text: text, state: MugState.AssociatedImageOrVideoWithAdditionalResources)
            case 2:
                mugText = MugText(mugId: i, text: text, state: MugState.AssociatedImageOrVideo)
            case 3:
                mugText = MugText(mugId: i, text: text, state: MugState.AssociatedWord)
            default:
                mugText = MugText(mugId: i, text: text, state: MugState.Default)
            }
            
            self.mugs.append(mugText)
        }
    }
    
    private func addSubviews() {
        mugContainerView = UIView()
        self.addSubview(mugContainerView)
        
        cameraPreview = CameraView(interfaceOrientation: AVCaptureVideoOrientation.Portrait, showAvatarCropArea: false, showMicrophoneButton: true)
        cameraPreview.alpha = 0.0
        cameraPreview.delegate = self
        self.addSubview(cameraPreview)
        
        mugImageView = UIImageView.imageWithColor(UIColor.avacado())
//        mugImageView = UIImageView(image: UIImage(named: "Church"))
        mugImageView.sizeToFit()
        mugImageView.contentMode = UIViewContentMode.ScaleAspectFill
        mugContainerView.addSubview(mugImageView)
        
        mugWordLabel = UILabel()
        mugWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        mugWordLabel.textColor = UIColor.whiteColor()
        mugWordLabel.text = "I"
        mugContainerView.addSubview(mugWordLabel)
        
        mugTextsContainer = MugTextsContainer(texts: self.mugs)
        self.addSubview(mugTextsContainer)
        
        mugsOrCameraButtonsView = UIView()
        mugsOrCameraButtonsView.backgroundColor = UIColor.sand()
        self.addSubview(mugsOrCameraButtonsView)
        
        addCameraButtonsViewSubviews()
        addMugsViewSubviews()
    }
    
    private func addCameraButtonsViewSubviews() {
        cameraButtonsView = UIView()
        mugsOrCameraButtonsView.addSubview(cameraButtonsView)
        
        captureAudioButton = UIButton()
        captureAudioButton.hidden = true
        captureAudioButton.setImage(UIImage(named: "Capture_Audio"), forState: .Normal)
        captureAudioButton.sizeToFit()
        captureAudioButton.addTarget(self, action: "captureAudioButtonTapped:", forControlEvents: .TouchUpInside)
        cameraButtonsView.addSubview(captureAudioButton)
        
        cancelCaptureAudioButton = UIButton()
        cancelCaptureAudioButton.hidden = true
        cancelCaptureAudioButton.setImage(UIImage(named: "Cancel_Audio"), forState: .Normal)
        cancelCaptureAudioButton.sizeToFit()
        cancelCaptureAudioButton.addTarget(self, action: "cancelCaptureAudioButtonTapped:", forControlEvents: .TouchUpInside)
        cameraButtonsView.addSubview(cancelCaptureAudioButton)
        
        takePictureButton = UIButton()
        takePictureButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        takePictureButton.sizeToFit()
        takePictureButton.addTarget(self, action: "takePictureButtonTapped:", forControlEvents: .TouchUpInside)
        cameraButtonsView.addSubview(takePictureButton)
        
        gridButton = UIButton()
        gridButton.setImage(UIImage(named: "Grid"), forState: .Normal)
        gridButton.sizeToFit()
        gridButton.addTarget(self, action: "gridButtonTapped:", forControlEvents: .TouchUpInside)
        cameraButtonsView.addSubview(gridButton)
        
        galleryButton = UIButton()
        galleryButton.setImage(UIImage(named: "Church"), forState: .Normal)
        galleryButton.addTarget(self, action: "galleryButtonTapped:", forControlEvents: .TouchUpInside)
        cameraButtonsView.addSubview(galleryButton)
    }
    
    private func addMugsViewSubviews() {
        mugsView = UIView()
        mugsOrCameraButtonsView.addSubview(mugsView)
        
        arrowToCurrentMug = UIButton()
        arrowToCurrentMug.userInteractionEnabled = false
        arrowToCurrentMug.setImage(UIImage(named: "Triangle"), forState: .Normal)
        arrowToCurrentMug.sizeToFit()
        mugsView.addSubview(arrowToCurrentMug)
        
        myMugsLabel = UILabel()
        myMugsLabel.numberOfLines = 1
        myMugsLabel.sizeToFit()
        myMugsLabel.text = NSLocalizedString("My Mugs", comment: "My Mugs")
        myMugsLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h3)
        myMugsLabel.textColor = UIColor.plum()
        mugsView.addSubview(myMugsLabel)
        
        addMugButton = UIButton()
        addMugButton.addTarget(self, action: "addMugButtonTapped:", forControlEvents: .TouchUpInside)
        addMugButton.setImage(UIImage(named: "AddMediaButton"), forState: .Normal)
        addMugButton.sizeToFit()
        mugsView.addSubview(addMugButton)
    }
    
    private func makeConstraints() {
        mugContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.cameraPreview)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.composeViewMakeConstraintToNavigationBarBottom(mugContainerView)
        
        cameraPreview.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.mugContainerView)
                make.width.equalTo()(self.MUG_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.mugContainerView)
                make.right.equalTo()(self.mugContainerView)
            }

            make.height.equalTo()(self.mugImageView.mas_width)
        }
        
        mugImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.mugContainerView)
                make.width.equalTo()(self.MUG_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.mugContainerView)
                make.right.equalTo()(self.mugContainerView)
            }
            
            make.height.equalTo()(self.mugImageView.mas_width)
        }
        
        mugWordLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.mugContainerView)
            make.bottom.equalTo()(self.mugImageView).with().offset()(-self.MUGWORD_MARGIN_BOTTOM)
        }
        
        mugTextsContainer.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugContainerView.mas_bottom)
            make.height.equalTo()(self.MUGWORD_LIST_HEIGHT)
        }
        
        mugsOrCameraButtonsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugTextsContainer.mas_bottom)
            make.bottom.equalTo()(self)
        }
        
        makeCameraButtonsViewConstraints()
        makeMugsViewConstraints()
    }
    
    private func makeCameraButtonsViewConstraints() {
        cameraButtonsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.mugsView.mas_right)
            make.width.equalTo()(self.mugsOrCameraButtonsView)
            make.top.equalTo()(self.mugsOrCameraButtonsView)
            make.height.equalTo()(self.mugsOrCameraButtonsView)
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
    
    private func makeMugsViewConstraints() {
        mugsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.mugsOrCameraButtonsView)
            make.right.equalTo()(self.mugsOrCameraButtonsView)
            make.top.equalTo()(self.mugsOrCameraButtonsView)
            make.height.equalTo()(self.mugsOrCameraButtonsView)
        }
        
        arrowToCurrentMug.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.mugsView)
            make.centerY.equalTo()(self.mugsView.mas_top)
        }
        
        myMugsLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugsView).with().offset()(self.MY_MUGS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self.mugsView).with().offset()(self.MY_MUGS_LABEL_MARGIN_LEFT)
        }
        
        addMugButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.myMugsLabel)
            make.top.equalTo()(self.myMugsLabel.mas_bottom).with().offset()(self.ADD_MUG_BUTTON_MARGIN_TOP)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.width.equalTo()(self.addMugButton.frame.width / 3 * 2)
                make.height.equalTo()(self.addMugButton.mas_width)
            } else {
                make.width.equalTo()(self.addMugButton.frame.width)
                make.height.equalTo()(self.addMugButton.frame.height)
            }
        }
    }
    
    func setPicture(image: UIImage!) {
        self.mugImageView.image = image
        hideCameraShowPicture()
        self.showRecordingView()
    }
    
    func showRecordingView() {
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
    
    
    // MARK: - Nav Bar Delegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.delegate?.composeViewDidTapBackButton(self)
    }
    
    
    // MARK: - Button actions
    
    func addMugButtonTapped(sender: UIButton!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.cameraPreview.alpha = 1.0
            self.cameraPreview.registerObservers()
            
            self.mugImageView.alpha = 0.0
            self.mugsView.alpha = 0.0
            self.mugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.width.equalTo()(self.mugsOrCameraButtonsView)
                make.right.equalTo()(self.cameraButtonsView.mas_left)
                make.top.equalTo()(self.mugsOrCameraButtonsView)
                make.height.equalTo()(self.mugsOrCameraButtonsView)
            })
            
            self.cameraButtonsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsOrCameraButtonsView)
                make.right.equalTo()(self.mugsOrCameraButtonsView)
                make.top.equalTo()(self.mugsOrCameraButtonsView)
                make.height.equalTo()(self.mugsOrCameraButtonsView)
            })
            
            self.layoutIfNeeded()
        })
    }
    
    func takePictureButtonTapped(sender: UIButton!) {
        self.delegate?.composeViewDidTapTakePictureButton(self, withCamera: self.cameraPreview)
    }
    
    func gridButtonTapped(sender: UIButton!) {
        self.slideToMyMugsView()
    }
    
    func galleryButtonTapped(sender: UIButton!) {
        self.delegate?.composeViewDidTapGalleryButton(self)
    }
    
    func cancelCaptureAudioButtonTapped(sender: UIButton!) {
        self.showCameraHidePicture()
        self.hideRecordingView()
    }
    
    func captureAudioButtonTapped(sender: UIButton!) {
        println("Starting recording ..")
    }
    
    func slideToMyMugsView() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.mugsView.alpha = 1.0
            self.hideCameraShowPicture()
            
            self.mugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsOrCameraButtonsView)
                make.right.equalTo()(self.mugsOrCameraButtonsView)
                make.top.equalTo()(self.mugsOrCameraButtonsView)
                make.height.equalTo()(self.mugsOrCameraButtonsView)
            })
            
            self.cameraButtonsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsView.mas_right)
                make.width.equalTo()(self.mugsOrCameraButtonsView)
                make.top.equalTo()(self.mugsOrCameraButtonsView)
                make.height.equalTo()(self.mugsOrCameraButtonsView)
            })
            
            self.layoutIfNeeded()
        })
    }
    

    // MARK: - Required inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - CameraViewDelegate
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool)  {
        // Take a picture button should be disabled
        takePictureButton.enabled = available
    }
    
    func cameraViewDidTapMicrophoneButton(cameraView: CameraView) {
        println("starting recording microphone")
    }
    
    func hideCameraShowPicture() {
        self.cameraPreview.alpha = 0.0
        self.cameraPreview.removeObservers()
        
        self.mugImageView.alpha = 1.0
    }
    
    func showCameraHidePicture() {
        self.cameraPreview.alpha = 1.0
        self.cameraPreview.registerObservers()
        
        self.mugImageView.alpha = 0.0
    }
}


// MARK: - View Delegate

protocol ComposeViewDelegate {
    func composeViewDidTapBackButton(composeView: ComposeView!)
    func composeViewDidTapTakePictureButton(composeView: ComposeView!, withCamera cameraView: CameraView!)
    func composeViewDidTapGalleryButton(composeView: ComposeView!)
    func composeViewMakeConstraintToNavigationBarBottom(containerView: UIView!)
}