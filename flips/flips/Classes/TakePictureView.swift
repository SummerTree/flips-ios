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

import AVFoundation


class TakePictureView : UIView, CustomNavigationBarDelegate, CameraViewDelegate {
    
    private var navigationBar: CustomNavigationBar!
    private var cameraView: CameraView!
    
    private var bottomButtonsContainerView: UIView!
    private var takePictureButton: UIButton!
    private var galleryButton: UIButton!
    
    weak var delegate: TakePictureViewDelegate?
    

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
        bottomButtonsContainerView.backgroundColor = UIColor.lightGreyF2()
        self.addSubview(bottomButtonsContainerView)
        
        let imageSizer = UIImageView(image: UIImage(named: "Capture")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        let sizerMult : CGFloat = 1.35
        
        takePictureButton = UIButton.buttonWithType(.Custom) as! UIButton
        takePictureButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        takePictureButton.sizeToFit()
        takePictureButton.addTarget(self, action: "takePictureButtonTapped", forControlEvents: .TouchUpInside)
        takePictureButton.tintColor = UIColor.whiteColor()
        takePictureButton.layer.borderColor = UIColor.whiteColor().CGColor
        takePictureButton.layer.borderWidth = 3.0
        takePictureButton.layer.cornerRadius = (imageSizer.frame.height * sizerMult) / 2
        takePictureButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        takePictureButton.backgroundColor = UIColor.lightGrayColor()
        takePictureButton.setImage(UIImage(named: "CameraNew")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        bottomButtonsContainerView.addSubview(takePictureButton)
        takePictureButton.enabled = cameraView.isDeviceAuthorized()
        
        galleryButton = UIButton()
//        galleryButton.setImage(UIImage(named: "Grid"), forState: .Normal)
        galleryButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        galleryButton.sizeToFit()
//        galleryButton.setImage(UIImage(named: "Filter_Photo"), forState: .Normal)
        galleryButton.tintColor = UIColor.whiteColor()
        galleryButton.layer.borderColor = UIColor.whiteColor().CGColor
        galleryButton.layer.borderWidth = 3.0
        galleryButton.layer.cornerRadius = (imageSizer.frame.height * sizerMult) / 2
        galleryButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        galleryButton.backgroundColor = UIColor.lightGrayColor()
        galleryButton.setImage(UIImage(named: "Gallery")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
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
        
        let imageSizer = UIImageView(image: UIImage(named: "Capture")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        let sizerMult : CGFloat = 1.35
        
        takePictureButton.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self.bottomButtonsContainerView)
            make.height.equalTo()(imageSizer.frame.height * sizerMult)
            make.width.equalTo()(imageSizer.frame.height * sizerMult)
        }
        
        let heightDivider : CGFloat = 3
        
        takePictureButton.imageView!.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.takePictureButton).offset()(imageSizer.frame.height / heightDivider)
            make.top.equalTo()(self.takePictureButton).offset()(imageSizer.frame.height / heightDivider)
            make.right.equalTo()(self.takePictureButton).offset()(-1 * (imageSizer.frame.height / heightDivider))
            make.bottom.equalTo()(self.takePictureButton).offset()(-1 * (imageSizer.frame.height / heightDivider))
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
        //galleryButton.setLastCameraPhotoAsButtonImage()
    }
    
    func viewWillDisappear(animated: Bool) {
        cameraView.removeObservers()
    }
    
    func shouldAutorotate() -> Bool {
        return cameraView.shouldAutorotate()
    }
    
    
    // MARK: - Button Handlers
    
    func takePictureButtonTapped() {
        cameraView.capturePictureWithCompletion({ (image, frontCamera, inLandspace) -> Void in
            if (image != nil) {
                var receivedImage = image as UIImage!
                
                var avatarImage: UIImage! = receivedImage.avatarA1Image(self.cameraView.frame)
                
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
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.takePictureButton.enabled = available
		})
    }
}