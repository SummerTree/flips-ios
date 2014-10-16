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

let CapturingStillImageContext = UnsafeMutablePointer<()>()
let RecordingContext = UnsafeMutablePointer<()>()
let SessionRunningAndDeviceAuthorizedContext = UnsafeMutablePointer<()>()

public typealias CapturePictureSuccess = (UIImage?) -> Void
public typealias CapturePictureFail = (NSError?) -> Void

class CameraView : UIView {
    
    private let DEVICE_AUTHORIZED_KEY_PATH = "sessionRunningAndDeviceAuthorized"
    private let CAPTURING_STILL_IMAGE_KEY_PATH = "stillImageOutput.capturingStillImage"
    private let RECORDING_KEY_PATH = "movieFileOutput.recording"
    
    private let CAMERA_BUTTON_RIGHT_MARGIN: CGFloat = -10
    private let CAMERA_BUTTON_VERTICAL_MARGIN: CGFloat = 10
    
    private var currentInterfaceOrientation: AVCaptureVideoOrientation!
    
    private var previewView: AVCamPreviewView!
    private var avatarCropAreaView: CropOverlayView!
    private var cameraButtonView: UIView!
    private var flashLabel: UILabel!
    private var flashButton: UIButton!
    private var toggleCameraButton: UIButton!
    
    private var flashMode: AVCaptureFlashMode!
    
    private var showAvatarCropArea: Bool
    
    var delegate: CameraViewDelegate?
    
    // Session Management
    var sessionQueue: dispatch_queue_t!
    var session: AVCaptureSession!
    var videoDeviceInput: AVCaptureDeviceInput!
    var movieFileOutput: AVCaptureMovieFileOutput!
    var stillImageOutput: AVCaptureStillImageOutput!
    
    // Utilities
    var backgroundRecordingId: UIBackgroundTaskIdentifier!
    private var deviceAuthorized: Bool!
    private var sessionRunningAndDeviceAuthorized: Bool!
    var lockInterfaceRotation: Bool!
    var runtimeErrorHandlingObserver: AnyObject!
    
    
    // MARK: - Initialization Methods
    
    init(interfaceOrientation: AVCaptureVideoOrientation, showAvatarCropArea: Bool = false) {
        self.showAvatarCropArea = showAvatarCropArea

        super.init(frame: CGRect.zeroRect)
        
        currentInterfaceOrientation = interfaceOrientation
        
        self.initSubviews()
        self.initCamera()
        
        self.updateConstraintsIfNeeded()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        self.backgroundColor = UIColor.deepSea()
        
        previewView = AVCamPreviewView()
        self.addSubview(previewView)
        
        if (showAvatarCropArea) {
            avatarCropAreaView = CropOverlayView(cropHoleSize: CGSizeMake(A1_AVATAR_SIZE - A1_BORDER_WIDTH, A1_AVATAR_SIZE - A1_BORDER_WIDTH))
            avatarCropAreaView.backgroundColor = UIColor.clearColor()
            self.addSubview(avatarCropAreaView)
        }
        
        cameraButtonView = UIView()
        cameraButtonView.backgroundColor = UIColor.clearColor()
        cameraButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "focusAndExposeTap:"))
        self.addSubview(cameraButtonView)

        
        flashLabel = UILabel()
        flashLabel.text = NSLocalizedString("Auto", comment: "Auto")
        flashLabel.backgroundColor = UIColor.clearColor()
        flashLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h5)
        flashLabel.textColor = UIColor.whiteColor()
        flashLabel.textAlignment = NSTextAlignment.Center
        flashLabel.sizeToFit()
        flashLabel.hidden = true
        cameraButtonView.addSubview(flashLabel)
        
        flashButton = UIButton()
        flashButton.setImage(UIImage(named: "Flash_Button"), forState: .Normal)
        flashButton.sizeToFit()
        flashButton.addTarget(self, action: "flashButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flashButton.enabled = false
        cameraButtonView.addSubview(flashButton)
        
        toggleCameraButton = UIButton()
        toggleCameraButton.setImage(UIImage(named: "Front_Back"), forState: .Normal)
        toggleCameraButton.sizeToFit()
        toggleCameraButton.addTarget(self, action: "toggleCameraButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cameraButtonView.addSubview(toggleCameraButton)
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
        
        cameraButtonView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.mas_width)
            make.height.equalTo()(self.mas_width)
        }
        
        flashButton.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.bottom.equalTo()(self.cameraButtonView.mas_centerY).with().offset()(-self.CAMERA_BUTTON_VERTICAL_MARGIN)
            make.trailing.equalTo()(self.cameraButtonView).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
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
            make.top.equalTo()(self.cameraButtonView.mas_centerY).with().offset()(self.CAMERA_BUTTON_VERTICAL_MARGIN)
            make.trailing.equalTo()(self.cameraButtonView).with().offset()(self.CAMERA_BUTTON_RIGHT_MARGIN)
            make.width.equalTo()(self.toggleCameraButton.frame.width)
            make.height.equalTo()(self.toggleCameraButton.frame.height)
        }
    }
    
    private func initCamera() {
        self.session = AVCaptureSession()
        
        self.previewView.session = session
        
        self.checkDeviceAuthorizationStatus()
        
        self.sessionQueue = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL)
        
        dispatch_async(sessionQueue, { () -> Void in
            self.backgroundRecordingId = UIBackgroundTaskInvalid
            
            var error: NSError?
            
            var videoDevice = CameraView.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Front)
            var deviceInput: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error)
            
            self.flashMode = AVCaptureFlashMode.Auto
            CameraView.setFlashMode(self.flashMode, forDevice: videoDevice)
            
            if (error != nil) {
                println("TakePicture error: \(error)")
            }
            
            if (self.session.canAddInput(deviceInput as AVCaptureInput)) {
                self.session.addInput(deviceInput as AVCaptureInput)
                self.videoDeviceInput = deviceInput as AVCaptureDeviceInput
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Why are we dispatching this to the main queue?
                    // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                    // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                    
                    var previewViewLayer = self.previewView.layer as AVCaptureVideoPreviewLayer
                    previewViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewViewLayer.connection.videoOrientation = self.currentInterfaceOrientation
                })
            }
            
            error = nil
            
            var audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as AVCaptureDevice
            var audioDeviceInput: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice, error: &error)
            
            if (error != nil) {
                println("TakePicture error 2: \(error)")
            }
            
            if (self.session.canAddInput(audioDeviceInput as AVCaptureInput)) {
                self.session.addInput(audioDeviceInput as AVCaptureInput)
            }
            
            var movieOutput = AVCaptureMovieFileOutput()
            if (self.session.canAddOutput(movieOutput)) {
                self.session.addOutput(movieOutput)
                self.movieFileOutput = movieOutput
                
                var connection = self.movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
                if (connection.videoStabilizationEnabled) {
                    connection.enablesVideoStabilizationWhenAvailable = true
                }
            }
            
            var imageOutput = AVCaptureStillImageOutput()
            if (self.session.canAddOutput(imageOutput)) {
                self.stillImageOutput = imageOutput
                self.stillImageOutput.outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
                self.session.addOutput(self.stillImageOutput)
            }
        })
    }
    
    func registerObservers() {
        dispatch_async(self.sessionQueue, { () -> Void in
            self.addObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: CapturingStillImageContext)
            self.addObserver(self, forKeyPath: self.RECORDING_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: RecordingContext)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput.device)
            
            weak var weakSelf = self
            self.runtimeErrorHandlingObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: self.session, queue: nil, usingBlock: { (notification) -> Void in
                var strongSelf = weakSelf
                dispatch_async(strongSelf?.sessionQueue, { () -> Void in
                    // Manually restarting the session since it must have been stopped due to an error.
                    strongSelf?.session.startRunning()
                    return ()
                })
            })
            self.session.startRunning()
        })
    }
    
    func removeObservers() {
        dispatch_async(self.sessionQueue, { () -> Void in
            self.session.stopRunning()
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: self.videoDeviceInput.device)
            NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver)
            
            self.removeObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, context: SessionRunningAndDeviceAuthorizedContext)
            self.removeObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, context: CapturingStillImageContext)
            self.removeObserver(self, forKeyPath: self.RECORDING_KEY_PATH, context: RecordingContext)
        })
    }
    
    
    // MARK: - Overridden Method
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if let changes = change as? [NSString: Bool] {
            if (context == CapturingStillImageContext) {
                if let isCapturingStillImage = changes[NSKeyValueChangeNewKey] {
                    if (isCapturingStillImage) {
                        self.runTakePictureAnimation()
                    }
                }
            } else if (context == RecordingContext) {
                if let isRecording = changes[NSKeyValueChangeNewKey] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // TODO: we aren't recording yet
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
                            self.toggleCameraButton.enabled = true
                        } else {
                            self.delegate?.cameraView(self, cameraAvailable: false)
                            self.toggleCameraButton.enabled = false
                        }
                    })
                }
            } else {
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
    
    
    // MARK: - Button Actions
    
    func toggleCameraButtonTapped() {
        self.delegate?.cameraView(self, cameraAvailable: false)
        self.toggleCameraButton.enabled = false
        
        dispatch_async(self.sessionQueue, { () -> Void in
            var currentVideoDevice = self.videoDeviceInput.device
            var preferredPosition = AVCaptureDevicePosition.Unspecified
            var currentPosition = currentVideoDevice.position
            
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
            
            var videoDevice = CameraView.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition)
            var deviceInput: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: nil)
            
            self.session.beginConfiguration()
            self.session.removeInput(self.videoDeviceInput)
            if (self.session.canAddInput(deviceInput as AVCaptureInput)) {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: currentVideoDevice)
                
                CameraView.setFlashMode(self.flashMode, forDevice: videoDevice)
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDevice)
                
                self.videoDeviceInput = deviceInput as AVCaptureDeviceInput
                self.session.addInput(self.videoDeviceInput)
            } else {
                self.session.addInput(self.videoDeviceInput)
            }
            
            self.session.commitConfiguration()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.flashButton.enabled = flashEnabled
                self.flashLabel.hidden = !flashEnabled
                
                self.delegate?.cameraView(self, cameraAvailable: true)
                self.toggleCameraButton.enabled = true
            })
        })
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
        
        CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
    }
    
    func capturePictureWithCompletion(success: CapturePictureSuccess, fail: CapturePictureFail) {
        dispatch_async(self.sessionQueue, { () -> Void in
            let videoPreviewLayer = self.previewView.layer as AVCaptureVideoPreviewLayer
            let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            videoConnection.videoOrientation = videoPreviewLayer.connection.videoOrientation
            
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
            
            self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageDataSampleBuffer, error) -> Void in
                
                if (imageDataSampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    var image = UIImage(data: imageData)
                    
                    var squaredRect : CGRect
                    if (image.size.width > image.size.height) {
                        var cropX = (image.size.width / 2) - (image.size.height / 2)
                        squaredRect = CGRectMake(cropX, 0, image.size.height, image.size.height)
                    } else {
                        var cropY = (image.size.height / 2) - (image.size.width / 2)
                        squaredRect = CGRectMake(0, cropY, image.size.width, image.size.width)
                    }
                    
                    var squaredImage = image.cropImageToRect(squaredRect)
                    
                    if (self.videoDeviceInput.device.position == AVCaptureDevicePosition.Front) {
                        // We need to flip the image captured by the front camera
                        squaredImage = UIImage(CGImage: squaredImage.CGImage, scale: squaredImage.scale, orientation: UIImageOrientation.LeftMirrored)
                    }
                    success(squaredImage)
                } else {
                    fail(error)
                }
            })
        })
    }
    
    func focusAndExposeTap(gestureRecognizer: UIGestureRecognizer) {
        let layer = self.previewView.layer as AVCaptureVideoPreviewLayer
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
    
    
    // MARK: - Notification Handlers
    
    func subjectAreaDidChange(notification: NSNotification) {
        var devicePoint = CGPointMake(0.5, 0.5)
        self.focusWithMode(AVCaptureFocusMode.ContinuousAutoFocus, exposesWithMode: AVCaptureExposureMode.ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    
    // MARK: - Device Configuration
    
    func focusWithMode(focusMode: AVCaptureFocusMode, exposesWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(self.sessionQueue, { () -> Void in
            var device = self.videoDeviceInput.device
            var error: NSError? = nil
            
            if (device.lockForConfiguration(&error)) {
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
            } else {
                println("error configuring device: \(error)")
            }
        })
    }
    
    class func setFlashMode(flashMode: AVCaptureFlashMode, forDevice device: AVCaptureDevice) {
        if (device.hasFlash && device.isFlashModeSupported(flashMode)) {
            var error: NSError? = nil
            if (device.lockForConfiguration(&error)) {
                device.flashMode = flashMode
                device.unlockForConfiguration()
            } else {
                println("Error settinf flash: \(error)")
            }
        }
    }
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice {
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice : AVCaptureDevice = devices.first as AVCaptureDevice
        
        for device in devices {
            if (device.position == position) {
                captureDevice = device as AVCaptureDevice
                break
            }
        }
        
        return captureDevice
    }
    
    
    // MARK: - Utility Methods
    
    func checkDeviceAuthorizationStatus() {
        var mediaType = AVMediaTypeVideo
        
        AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted) -> Void in
            if (granted) {
                //Granted access to mediaType
                self.deviceAuthorized = true
            } else {
                //Not granted access to mediaType
                self.deviceAuthorized = false
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var title = NSLocalizedString("MugChat", comment: "MugChat")
                    var message = NSLocalizedString("MugChat doesn't have permission to use Camera, please change privacy settings", comment: "MugChat doesn't have permission to use Camera, please change privacy settings")
                    var okButton = NSLocalizedString("OK", comment: "OK")
                    var alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: okButton)
                    alertView.show()
                })
            }
        })
    }
}


protocol CameraViewDelegate {
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool) // Take a picture button should be disabled
    
}