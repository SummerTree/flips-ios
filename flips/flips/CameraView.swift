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

import UIKit
import AVFoundation

let CapturingStillImageContext = UnsafeMutablePointer<()>()
let RecordingContext = UnsafeMutablePointer<()>()
let SessionRunningAndDeviceAuthorizedContext = UnsafeMutablePointer<()>()

public typealias CapturePictureSuccess = (UIImage?, Bool, Bool) -> Void
public typealias CapturePictureFail = (NSError?) -> Void

class CameraView : UIView, AVCaptureFileOutputRecordingDelegate {
    
    private let CAMERA_ERROR = NSLocalizedString("Camera Error")
    private let CAMERA_ERROR_MESSAGE = NSLocalizedString("Unable to find a camera")
    private let DEVICE_AUTHORIZED_KEY_PATH = "sessionRunningAndDeviceAuthorized"
    private let CAPTURING_STILL_IMAGE_KEY_PATH = "stillImageOutput.capturingStillImage"
    private let RECORDING_KEY_PATH = "movieFileOutput.recording"
    
    private let CAMERA_BUTTON_RIGHT_MARGIN: CGFloat = -10
    private let CAMERA_BUTTON_VERTICAL_MARGIN: CGFloat = 10

    private let CAMERA_VIEW_FRAME_WIDTH_ON_IPHONE_4: CGFloat = 240
    
    private var currentInterfaceOrientation: AVCaptureVideoOrientation!
    
    private var activityIndicator: UIActivityIndicatorView!
    private var previewView: AVCamPreviewView!
    private var avatarCropAreaView: CropOverlayView!
    private var frontCameraButtonView: UIView!
    private var backCameraButtonView: UIView!
    private var flashLabel: UILabel!
    private var flashButton: UIButton!
    private var microphoneButton: UIButton!
    private var toggleCameraButton: UIButton!
    
    private var flashMode: AVCaptureFlashMode!
    
    private var showAvatarCropArea: Bool
    private var showMicrophoneButton: Bool
    private var isMicrophoneAvailable: Bool
    private var showingFrontCamera: Bool
    
    weak var delegate: CameraViewDelegate?
    
    // Session Management
    var session: AVCaptureSession!
    var videoDeviceInput: AVCaptureDeviceInput!
    var movieFileOutput: AVCaptureMovieFileOutput!
    var stillImageOutput: AVCaptureStillImageOutput!
    
    // Utilities
    var backgroundRecordingId: UIBackgroundTaskIdentifier!
    private var deviceAuthorized: Bool = false
    private var sessionRunningAndDeviceAuthorized: Bool!
    var lockInterfaceRotation: Bool!
    var runtimeErrorHandlingObserver: AnyObject!

    // Observers state
    private var observersRegistered: Bool = false
    private var observersRegisteredBeforeResignActive: Bool = false

    private var observerResignActive: AnyObject!
    private var observerBecomeActive: AnyObject!
    
    // MARK: - Initialization Methods
    
    init(interfaceOrientation: AVCaptureVideoOrientation, showAvatarCropArea: Bool = false, showMicrophoneButton: Bool = false) {
        self.showingFrontCamera = true
        self.showAvatarCropArea = showAvatarCropArea
        self.showMicrophoneButton = showMicrophoneButton
        self.isMicrophoneAvailable = false

        super.init(frame: CGRect.zero)

        let notificationCenter = NSNotificationCenter.defaultCenter()
        weak var weakSelf = self
        self.observerBecomeActive = notificationCenter.addObserverForName("UIApplicationDidBecomeActiveNotification", object: nil, queue: nil) { (notification) -> Void in
            if let strongSelf = weakSelf {
                if (strongSelf.observersRegisteredBeforeResignActive) {
                    strongSelf.registerObservers()
                }
            }
        }
        self.observerResignActive = notificationCenter.addObserverForName("UIApplicationWillResignActiveNotification", object: nil, queue: nil) { (notification) -> Void in
            if let strongSelf = weakSelf {
                strongSelf.observersRegisteredBeforeResignActive = strongSelf.observersRegistered
                if (strongSelf.observersRegisteredBeforeResignActive) {
                    strongSelf.removeObservers()
                }
            }
        }

        currentInterfaceOrientation = interfaceOrientation
        
        self.initSubviews()
        self.initCamera()
        self.setCameraButtonsEnabled(false)

        self.updateConstraintsIfNeeded()
    }

    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self.observerBecomeActive, name: "UIApplicationDidBecomeActiveNotification", object: nil)
        notificationCenter.removeObserver(self.observerResignActive, name: "UIApplicationWillResignActiveNotification", object: nil)

        self.removeObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        self.backgroundColor = UIColor.blackColor()
        
        self.previewView = AVCamPreviewView()
        self.addSubview(self.previewView)
        
        if (showAvatarCropArea) {
            avatarCropAreaView = CropOverlayView(cropHoleSize: CGSizeMake(A1_AVATAR_SIZE - A1_BORDER_WIDTH, A1_AVATAR_SIZE - A1_BORDER_WIDTH))
            avatarCropAreaView.backgroundColor = UIColor.clearColor()
            self.addSubview(avatarCropAreaView)
        }
        
        frontCameraButtonView = UIView()
        frontCameraButtonView.backgroundColor = UIColor.clearColor()
        frontCameraButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CameraView.focusAndExposeTap(_:))))
        self.addSubview(frontCameraButtonView)
        
        backCameraButtonView = UIView()
        backCameraButtonView.alpha = 0
        backCameraButtonView.backgroundColor = UIColor.clearColor()
        backCameraButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CameraView.focusAndExposeTap(_:))))
        self.addSubview(backCameraButtonView)
        
        flashLabel = UILabel()
        flashLabel.text = NSLocalizedString("Auto", comment: "Auto")
        flashLabel.backgroundColor = UIColor.clearColor()
        flashLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        flashLabel.textColor = UIColor.whiteColor()
        flashLabel.textAlignment = NSTextAlignment.Center
        flashLabel.sizeToFit()
        flashLabel.hidden = true
        self.addSubview(flashLabel)
        
        flashButton = UIButton()
        flashButton.setImage(UIImage(named: "Flash_Button"), forState: .Normal)
        flashButton.sizeToFit()
        flashButton.addTarget(self, action: #selector(CameraView.flashButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
        flashButton.enabled = false
        self.addSubview(flashButton)
        
        toggleCameraButton = UIButton()
        toggleCameraButton.setImage(UIImage(named: "Front_Back"), forState: .Normal)
        toggleCameraButton.sizeToFit()
        toggleCameraButton.addTarget(self, action: #selector(CameraView.toggleCameraButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(toggleCameraButton)
        
        if (self.showMicrophoneButton) {
            microphoneButton = UIButton()
            microphoneButton.setImage(UIImage(named: "Audio"), forState: .Normal)
            microphoneButton.sizeToFit()
            microphoneButton.addTarget(self, action: #selector(CameraView.microphoneButtonTapped), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(microphoneButton)
        }
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        self.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    
    // MARK: - Overridden Method
    
    override func updateConstraints() {
        super.updateConstraints()
        
        previewView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self)
            make.width.equalTo()(self)
            make.height.equalTo()(self.previewView.mas_width)
        }
        
        if (showAvatarCropArea) {
            avatarCropAreaView.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self)
                make.centerX.equalTo()(self)
                make.width.equalTo()(self.mas_width)
                make.height.equalTo()(self.mas_width)
            }
        }
        if let _ = frontCameraButtonView.superview {
            frontCameraButtonView.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self)
                make.centerX.equalTo()(self)
                make.width.equalTo()(self.mas_width)
                make.height.equalTo()(self.mas_width)
            }
        }
        
        if let _ = backCameraButtonView.superview {
            backCameraButtonView.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self)
                make.centerX.equalTo()(self)
                make.width.equalTo()(self.mas_width)
                make.height.equalTo()(self.mas_width)
            }
        }
        
        if (self.showMicrophoneButton) {
            flashButton.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.bottom.equalTo()(self.toggleCameraButton.mas_top).with().offset()(-self.CAMERA_BUTTON_VERTICAL_MARGIN)
                make.trailing.equalTo()(self).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
                make.width.equalTo()(self.flashButton.frame.width)
                make.height.equalTo()(self.flashButton.frame.height)
            }

            flashLabel.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.bottom.equalTo()(self.flashButton.mas_top)
                make.centerX.equalTo()(self.flashButton)
                make.width.equalTo()(self.flashButton)
                make.height.equalTo()(self.flashLabel.frame.height)
            }
            
            toggleCameraButton.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.centerY.equalTo()(self)
                make.trailing.equalTo()(self).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
                make.width.equalTo()(self.toggleCameraButton.frame.width)
                make.height.equalTo()(self.toggleCameraButton.frame.height)
            }
            
            microphoneButton.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self.toggleCameraButton.mas_bottom).with().offset()(self.CAMERA_BUTTON_VERTICAL_MARGIN)
                make.trailing.equalTo()(self).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
                make.width.equalTo()(self.microphoneButton.frame.width)
                make.height.equalTo()(self.microphoneButton.frame.height)
            }
        } else {
            flashButton.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.bottom.equalTo()(self.mas_centerY).with().offset()(-self.CAMERA_BUTTON_VERTICAL_MARGIN)
                make.trailing.equalTo()(self).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
                make.width.equalTo()(self.flashButton.frame.width)
                make.height.equalTo()(self.flashButton.frame.height)
            }
            
            flashLabel.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.bottom.equalTo()(self.flashButton.mas_top)
                make.centerX.equalTo()(self.flashButton)
                make.width.equalTo()(self.flashButton)
                make.height.equalTo()(self.flashLabel.frame.height)
            }
            
            toggleCameraButton.mas_makeConstraints { (make) -> Void in
                make.removeExisting = true
                make.top.equalTo()(self.mas_centerY).with().offset()(self.CAMERA_BUTTON_VERTICAL_MARGIN)
                make.trailing.equalTo()(self).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
                make.width.equalTo()(self.toggleCameraButton.frame.width)
                make.height.equalTo()(self.toggleCameraButton.frame.height)
            }
        }
        
        activityIndicator.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self)
        }
    }
    
    private func showAlert(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        }
    }
    
    private func initCamera() {
        self.session = AVCaptureSession()
        self.previewView.session = session
        self.backgroundRecordingId = UIBackgroundTaskInvalid

        var error: NSError?
        let videoDevice = CameraView.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Front)

        if (videoDevice == nil) {
            self.showAlert(self.CAMERA_ERROR, message: NSLocalizedString("Unable to find a camera"))
            self.activityIndicator.stopAnimating()
            return;
        }

        var deviceInput: AVCaptureDeviceInput!
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice)
        }
        catch _ {
            self.setCameraButtonsEnabled(false)
            
            print("TakePicture error: \(error)")
            self.showAlert(self.CAMERA_ERROR, message: error?.localizedDescription ?? self.CAMERA_ERROR_MESSAGE)
            self.activityIndicator.stopAnimating()
            return
        }

        self.flashMode = AVCaptureFlashMode.Auto
        CameraView.setFlashMode(self.flashMode, forDevice: videoDevice)

        if (self.session.canAddInput(deviceInput)) {
            self.session.addInput(deviceInput)
            self.videoDeviceInput = deviceInput
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.

                let previewViewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
                previewViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewViewLayer.connection.videoOrientation = self.currentInterfaceOrientation

                self.activityIndicator.stopAnimating()
            })
        }

            // We should ask for audio access if we aren't showing the button to record audio.
            if let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as? AVCaptureDevice {
                error = nil
                
                do
                {
                    let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                    
                    self.isMicrophoneAvailable = true
                    
                    if (self.session.canAddInput(audioDeviceInput as AVCaptureInput)) {
                        self.session.addInput(audioDeviceInput as AVCaptureInput)
                    }
                }
                catch let error as NSError
                {
                    self.isMicrophoneAvailable = false
                    
                    UIAlertView(title: NSLocalizedString("Microphone Error"), message: error.localizedFailureReasonOrDescription, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
                }

            }
            else
            {
                self.isMicrophoneAvailable = false
            }

        let movieOutput = AVCaptureMovieFileOutput()

        if (self.session.canAddOutput(movieOutput)) {
            self.session.addOutput(movieOutput)
            _ = movieOutput.connectionWithMediaType(AVMediaTypeVideo)

            self.movieFileOutput = movieOutput
        }

        let imageOutput = AVCaptureStillImageOutput()
        if (self.session.canAddOutput(imageOutput)) {
            imageOutput.outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
            self.session.addOutput(imageOutput)
            self.stillImageOutput = imageOutput
        }
    }

    func registerObservers() {
        if (!deviceAuthorized) {
            self.checkDeviceAuthorizationStatus()
            return
        }
        
        if (!observersRegistered) {
            self.addObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, options: ([NSKeyValueObservingOptions.Old, NSKeyValueObservingOptions.New]), context: SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, options: ([NSKeyValueObservingOptions.Old, NSKeyValueObservingOptions.New]), context: CapturingStillImageContext)
            self.addObserver(self, forKeyPath: self.RECORDING_KEY_PATH, options: ([NSKeyValueObservingOptions.Old, NSKeyValueObservingOptions.New]), context: RecordingContext)
            
            if let deviceInput = self.videoDeviceInput {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraView.subjectAreaDidChange(_:)), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: deviceInput.device)
            }
            
            weak var weakSelf = self
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: { (notification) -> Void in
                let strongSelf = weakSelf
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Manually restarting the session since it must have been stopped due to an error.
                    strongSelf?.session.startRunning()
                    return ()
                })
            })
            self.session.startRunning()
            self.setCameraButtonsEnabled()
            
            self.observersRegistered = true
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.previewView.alpha = 1.0
                }, completion: { (finished) -> Void in
                    self.delegate?.cameraView(self, cameraAvailable: true)
                    return
            })
        } else {
            return
        }
    }

    func removeObservers() {
        self.delegate?.cameraView(self, cameraAvailable: false)
        self.session.stopRunning()
        self.setCameraButtonsEnabled(false)

        if (self.observersRegistered) {

            if let deviceInput = self.videoDeviceInput {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: deviceInput.device)
            }

            NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver)

            self.removeObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, context: SessionRunningAndDeviceAuthorizedContext)
            self.removeObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, context: CapturingStillImageContext)
            self.removeObserver(self, forKeyPath: self.RECORDING_KEY_PATH, context: RecordingContext)

            self.observersRegistered = false

            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.previewView.alpha = 0.0
            })
        }
    }


    // MARK: - Overridden Method

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let changes = change as? [String : Bool] {
            if (context == CapturingStillImageContext) {
                if let isCapturingStillImage = changes[NSKeyValueChangeNewKey] {
                    if (isCapturingStillImage) {
                        self.runTakePictureAnimation()
                    }
                }
            } else if (context == RecordingContext) {
                if let isRecording = changes[NSKeyValueChangeNewKey] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if (isRecording) {
                        } else {
                        }
                    })
                }
            } else if (context == SessionRunningAndDeviceAuthorizedContext) {
                if let isRunning = changes[NSKeyValueChangeNewKey] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if (isRunning) {
                            self.delegate?.cameraView(self, cameraAvailable: true)
                            self.setCameraButtonsEnabled()
                        } else {
                            self.delegate?.cameraView(self, cameraAvailable: false)
                            self.setCameraButtonsEnabled(false)
                        }
                    })
                }
            } else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
    
    
    // MARK: - Button Actions
    
    func bringButtonsToFront() {
        self.bringSubviewToFront(flashButton)
        self.bringSubviewToFront(flashLabel)
        self.bringSubviewToFront(toggleCameraButton)
        
        if (showMicrophoneButton) {
            self.bringSubviewToFront(microphoneButton)
        }
    }

    private func setCameraButtonsEnabled(enabled: Bool = true) {
        let flashEnabled = !self.showingFrontCamera && enabled

        self.flashButton.enabled = flashEnabled
        self.flashLabel.enabled = flashEnabled

        self.toggleCameraButton.enabled = enabled

        if (self.showMicrophoneButton) {
            self.microphoneButton.enabled = enabled
        }
    }

    func toggleCameraButtonTapped() {
        var overlayView: UIView? = nil

        if #available(iOS 8.0, *) {
            overlayView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        } else {
            overlayView = UIView()
            overlayView!.backgroundColor = UIColor.blackColor()
            overlayView!.alpha = 0.75
        }
        overlayView!.frame = self.previewView.frame
        self.previewView.addSubview(overlayView!)

        self.previewView.setNeedsLayout()
        self.previewView.layoutIfNeeded()

        self.prepareForCameraSwitch()

        var fromView = self.frontCameraButtonView
        var toView = self.backCameraButtonView
        var transition = UIViewAnimationOptions.TransitionFlipFromRight

        if (!self.showingFrontCamera) {
            fromView = self.backCameraButtonView
            toView = self.frontCameraButtonView
            transition = UIViewAnimationOptions.TransitionFlipFromLeft
        }

        UIView.transitionFromView(fromView,
            toView: toView,
            duration: 0.5,
            options: transition,
            completion: { (finished) -> Void in
                self.commitCameraSwitch()
                overlayView!.removeFromSuperview()
                fromView.alpha = 0.0
                toView.alpha = 1.0
                self.addSubview(fromView)
            }
        )

        self.showingFrontCamera = !self.showingFrontCamera
    }

    func flashButtonTapped() {
        if (self.flashMode == AVCaptureFlashMode.On) {
            self.flashMode = AVCaptureFlashMode.Off
            flashLabel.text = NSLocalizedString("Off",comment: "Off")
        } else if (self.flashMode == AVCaptureFlashMode.Off) {
            self.flashMode = AVCaptureFlashMode.Auto
            flashLabel.text = NSLocalizedString("Auto",comment: "Auto")
        } else if (self.flashMode == AVCaptureFlashMode.Auto) {
            self.flashMode = AVCaptureFlashMode.On
            flashLabel.text = NSLocalizedString("On",comment: "On")
        }
        
        if let device = self.videoDeviceInput?.device {
            CameraView.setFlashMode(self.flashMode, forDevice: device)
        }
    }
    
    func microphoneButtonTapped() {
        if (self.isMicrophoneAvailable) {
            self.delegate?.cameraViewDidTapMicrophoneButton!(self)
        } else {
            let alertMessage = UIAlertView(title: LocalizedString.MICROPHONE_ACCESS, message: LocalizedString.MICROPHONE_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
        }
    }
    
    func capturePictureWithCompletion(success: CapturePictureSuccess, fail: CapturePictureFail) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let videoPreviewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            let videoOrientation = videoPreviewLayer.connection.videoOrientation
            
            let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            videoConnection.videoOrientation = videoOrientation
        
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
            
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                
                if (imageDataSampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    var image = UIImage(data: imageData)!
        
                    if (self.videoDeviceInput.device.position == AVCaptureDevicePosition.Front) {
                        image = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                        image = image.cropSquareThumbnail()
                    } else {
                        image = image.cropSquareThumbnail()
                    }
                    
                    let isLandscape = (videoOrientation == AVCaptureVideoOrientation.LandscapeLeft) || (videoOrientation == AVCaptureVideoOrientation.LandscapeRight)
                    success(image, self.isCameraFrontPositioned(), isLandscape)
                } else {
                    fail(error)
                }
            })
        })
    }
    
    func captureVideo() {
        let videoPreviewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
        let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        videoConnection.videoOrientation = videoPreviewLayer.connection.videoOrientation
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss.SSS"
        let currentFileName = "recording-\(dateFormatter.stringFromDate(NSDate())).mov"
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        let videoFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        let videoURL = NSURL(fileURLWithPath: videoFilePath)
        
        let fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(videoURL.path!)) {
            print("File already exists, removing it.")
            do {
                try fileManager.removeItemAtURL(videoURL)
            } catch _ {
            }
        }
        
        let oneSecond = 1 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
        
        dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
            self.stopRecording()
        }

        self.movieFileOutput.startRecordingToOutputFileURL(videoURL, recordingDelegate: self)
    }
    
    func startRecording() {
        
        if !movieFileOutput.recording {
            
            let videoPreviewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
            let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            videoConnection.videoOrientation = videoPreviewLayer.connection.videoOrientation
            
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss.SSS"
            let currentFileName = "recording-\(dateFormatter.stringFromDate(NSDate())).mov"
            
            var dirPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            let docsDir: AnyObject = dirPaths[0]
            let videoFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
            let videoURL = NSURL(fileURLWithPath: videoFilePath)
            
            let fileManager = NSFileManager.defaultManager()
            
            if (fileManager.fileExistsAtPath(videoURL.path!)) {
                print("File already exists, removing it.")
                do {
                    try fileManager.removeItemAtURL(videoURL)
                } catch _ {
                }
            }
            
            self.movieFileOutput.startRecordingToOutputFileURL(videoURL, recordingDelegate: self)
            
        }
        
    }
    
    func stopRecording() {
        
        if movieFileOutput.recording {
            self.movieFileOutput.stopRecording()
        }
        
    }
    
    func focusAndExposeTap(gestureRecognizer: UIGestureRecognizer) {
        let layer = self.previewView.layer as! AVCaptureVideoPreviewLayer
        let devicePoint = layer.captureDevicePointOfInterestForPoint(gestureRecognizer.locationInView(gestureRecognizer.view))
        self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposesWithMode: AVCaptureExposureMode.AutoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
    }
    
    
    // MARK: - UI
    
    func runTakePictureAnimation() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.previewView.layer.opacity = 0.0
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.previewView.layer.opacity = 1.0
            })
        })
    }
    
    
    // MARK: - Getters
    
    func isDeviceAuthorized() -> Bool {
        return deviceAuthorized
    }
    
    func isSessionRunningAndDeviceAuthorized() -> Bool {
        return (session.running && isDeviceAuthorized())
    }
    
    func shouldAutorotate() -> Bool {
        return !self.lockInterfaceRotation
    }
    
    func isCameraFrontPositioned() -> Bool {
        if let currentVideoDevice = self.videoDeviceInput?.device {
            return (currentVideoDevice.position == AVCaptureDevicePosition.Front)
        } else {
            return false
        }
    }
    
    
    // MARK: - Notification Handlers
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPointMake(0.5, 0.5)
        self.focusWithMode(AVCaptureFocusMode.ContinuousAutoFocus, exposesWithMode: AVCaptureExposureMode.ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    
    // MARK: - Device Configuration
    
    func focusWithMode(focusMode: AVCaptureFocusMode, exposesWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let device = self.videoDeviceInput?.device {

                do
                {
                    try device.lockForConfiguration()
                    
                    if (device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode)) {
                        device.focusMode = focusMode
                        device.focusPointOfInterest = point
                    }
                    if (device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode)) {
                        device.exposureMode = exposureMode
                        device.exposurePointOfInterest = point
                    }
                    
                    device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                }
                catch let error as NSError
                {
                    print("error configuring device: \(error)")
                }
                
            }
        })
    }
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if (device.hasFlash && device.isFlashModeSupported(flashMode)) {
            
            do {
                try device.lockForConfiguration()
                device.flashMode = flashMode
                device.unlockForConfiguration()
            }
            catch let error as NSError {
                print("Error settinf flash: \(error)")
            }

        }
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice! {
        let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice: AVCaptureDevice! = devices.first as? AVCaptureDevice
        
        for device in devices as! [AVCaptureDevice]! {
            if (device.position == position) {
                captureDevice = device
                break
            }
        }
        
        return captureDevice
    }
    
    func getFontSizeMultiplierForDevice() -> CGFloat {
        return self.frame.size.width / self.CAMERA_VIEW_FRAME_WIDTH_ON_IPHONE_4
    }

    private func prepareForCameraSwitch() {
        self.delegate?.cameraView(self, cameraAvailable: false)
        self.setCameraButtonsEnabled(false)

        if let currentVideoDevice = self.videoDeviceInput?.device {
            var preferredPosition = AVCaptureDevicePosition.Unspecified
            let currentPosition = currentVideoDevice.position

            var flashEnabled = false
            switch currentPosition {
            case AVCaptureDevicePosition.Front:
                preferredPosition = AVCaptureDevicePosition.Back
                flashEnabled = true
                break
            default:
                preferredPosition = AVCaptureDevicePosition.Front
                break
            }

            let videoDevice = CameraView.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
            let deviceInput : AnyObject! = try? AVCaptureDeviceInput(device: videoDevice)

            self.session.beginConfiguration()
            self.session.removeInput(self.videoDeviceInput)
            if (self.session.canAddInput(deviceInput as! AVCaptureInput)) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)

                CameraView.setFlashMode(self.flashMode, forDevice: videoDevice)

                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CameraView.subjectAreaDidChange(_:)), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)

                self.videoDeviceInput = deviceInput as? AVCaptureDeviceInput
                self.session.addInput(self.videoDeviceInput)
            } else {
                self.session.addInput(self.videoDeviceInput)
            }

            self.session.commitConfiguration()
        }
    }

    private func commitCameraSwitch() {
        self.setCameraButtonsEnabled()

        self.flashLabel.hidden = self.showingFrontCamera

        self.delegate?.cameraView(self, cameraAvailable: true)
        self.bringButtonsToFront()
    }


    // MARK: - Utility Methods
    
    func checkDeviceAuthorizationStatus() {
        let mediaType = AVMediaTypeVideo
        
        let title = NSLocalizedString("Flips", comment: "Flips")
        let message = NSLocalizedString("Flips doesn't have permission to use Camera, please change privacy settings", comment: "Flips doesn't have permission to use Camera, please change privacy settings")
        
        switch AVCaptureDevice.authorizationStatusForMediaType(mediaType) {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted) -> Void in
                self.checkDeviceAuthorizationStatus()
            })
        case .Authorized:
            self.deviceAuthorized = true
            self.delegate?.cameraView(self, cameraAvailable: true)
            self.registerObservers()
        default:
            self.deviceAuthorized = false
            self.delegate?.cameraView(self, cameraAvailable: false)
            showAlert(title, message: message)
        }
    }
    
    
    // MARK: - Finish Record Output Delegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let videoPreviewLayer = self.previewView.layer as! AVCaptureVideoPreviewLayer
        let videoOrientation = videoPreviewLayer.connection.videoOrientation
        let isLandscape = (videoOrientation == AVCaptureVideoOrientation.LandscapeLeft) || (videoOrientation == AVCaptureVideoOrientation.LandscapeRight)

        if (error != nil) {
            print("An error happen while recording a video: error [\(error)] and userinfo[\(error.userInfo)]")
            self.delegate?.cameraView!(self, didFinishRecordingVideoAtURL: nil, inLandscape: isLandscape, fromFrontCamera: self.isCameraFrontPositioned(), withSuccess: false)
        } else {
            self.delegate?.cameraView!(self, didFinishRecordingVideoAtURL: outputFileURL, inLandscape: isLandscape, fromFrontCamera: self.isCameraFrontPositioned(), withSuccess: true)
        }
    }
}


//MARK: - CameraViewDelegate protocol declaration

@objc protocol CameraViewDelegate {
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool) // Take a picture button should be disabled
    optional func cameraViewDidTapMicrophoneButton(cameraView: CameraView)
    optional func cameraView(cameraView: CameraView, didFinishRecordingVideoAtURL videoURL: NSURL?, inLandscape landscape: Bool, fromFrontCamera frontCamera: Bool, withSuccess success: Bool)
}