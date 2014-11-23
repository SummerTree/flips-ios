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

import AVFoundation


class TakePictureView : UIView, CustomNavigationBarDelegate, CameraViewDelegate {
    
    private var navigationBar: CustomNavigationBar!
    private var cameraView: CameraView!
    
    private var bottomButtonsContainerView: UIView!
    private var takePictureButton: UIButton!
    private var galleryButton: UIButton!
    
    var delegate: TakePictureViewDelegate?
    

    // MARK: - Initialization Methods
    
    init(interfaceOrientation: AVCaptureVideoOrientation) {
        super.init(frame: CGRect.zeroRect)
        
        self.initSubviewsWithInterfaceOrientation(interfaceOrientation)
        
        self.updateConstraintsIfNeeded()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviewsWithInterfaceOrientation(orientation: AVCaptureVideoOrientation) {
        self.backgroundColor = UIColor.blackColor()
        
        cameraView = CameraView(interfaceOrientation: orientation, showAvatarCropArea: true)
        cameraView.delegate = self
        self.addSubview(cameraView)
        
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar(NSLocalizedString("Take Picture", comment: "Take Picture"), showBackButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        bottomButtonsContainerView = UIView()
        bottomButtonsContainerView.backgroundColor = UIColor.whiteColor()
        self.addSubview(bottomButtonsContainerView)
        
        takePictureButton = UIButton()
        takePictureButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        takePictureButton.sizeToFit()
        takePictureButton.addTarget(self, action: "takePictureButtonTapped", forControlEvents: .TouchUpInside)
        bottomButtonsContainerView.addSubview(takePictureButton)
        
        galleryButton = UIButton()
        galleryButton.setImage(UIImage(named: "Grid"), forState: .Normal)
        galleryButton.sizeToFit()
        galleryButton.setImage(UIImage(named: "Filter_Photo"), forState: .Normal)
        galleryButton.addTarget(self, action: "galleryButtonTapped", forControlEvents: .TouchUpInside)
        bottomButtonsContainerView.addSubview(galleryButton)
    }
    
    
    // MARK: - Overridden Method
    
    override func updateConstraints() {
        super.updateConstraints()
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }

        cameraView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.frame.size.width)
            make.height.equalTo()(self.frame.size.width)
        }

        bottomButtonsContainerView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.cameraView.mas_bottom)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
        
        takePictureButton.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self.bottomButtonsContainerView)
            make.width.equalTo()(self.takePictureButton.frame.width)
            make.height.equalTo()(self.takePictureButton.frame.height)
        }
        
        var galleryButtonCenterXOffset : CGFloat = self.frame.width / 4
        galleryButton.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerY.equalTo()(self.bottomButtonsContainerView)
            make.leading.equalTo()(self.bottomButtonsContainerView.mas_centerX).with().offset()(galleryButtonCenterXOffset)
            make.width.equalTo()(self.galleryButton.frame.width)
            make.height.equalTo()(self.galleryButton.frame.height)
        }
    }
    
    
    // MARK: - Public Methods
    
    func viewWillAppear(animated: Bool) {
        cameraView.registerObservers()
        galleryButton.setLastCameraPhotoAsButtonImage()
    }
    
    func viewWillDisappear(animated: Bool) {
        cameraView.removeObservers()
    }
    
    func shouldAutorotate() -> Bool {
        return cameraView.shouldAutorotate()
    }
    
    
    // MARK: - Button Handlers
    
    func takePictureButtonTapped() {
        cameraView.capturePictureWithCompletion({ (image) -> Void in
            if (image != nil) {
                var receivedImage = image as UIImage!
                
                var avatarImage: UIImage! = receivedImage.avararA1Image(self.cameraView.frame)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.delegate?.takePictureView(self, didTakePicture: avatarImage)
                    return ()
                })
            } else {
                println("Capturing picture problem. Image is nil")
            }
        }, fail: { (error) -> Void in
            println("Error capturing picture: \(error)")
        })
    }
    
    func galleryButtonTapped() {
        self.delegate?.takePictureViewDidTapGalleryButton(self)
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.takePictureViewDidTapBackButton(self)
    }
    
    
    // MARK: - CameraViewDelegate
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool)  {
        // Take a picture button should be disabled
        takePictureButton.enabled = available
    }
}