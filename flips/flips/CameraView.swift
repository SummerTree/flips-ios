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
    var sessionQueue: dispatch_queue_t!
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
    private var observersRegistered: Bool! = false
    
    // MARK: - Initialization Methods
    
    init(interfaceOrientation: AVCaptureVideoOrientation, showAvatarCropArea: Bool = false, showMicrophoneButton: Bool = false) {
        self.showingFrontCamera = true
        self.showAvatarCropArea = showAvatarCropArea
        self.showMicrophoneButton = showMicrophoneButton
        self.isMicrophoneAvailable = false

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
        frontCameraButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "focusAndExposeTap:"))
        self.addSubview(frontCameraButtonView)
        
        backCameraButtonView = UIView()
        backCameraButtonView.alpha = 0
        backCameraButtonView.backgroundColor = UIColor.clearColor()
        backCameraButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "focusAndExposeTap:"))
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
        flashButton.addTarget(self, action: "flashButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        flashButton.enabled = false
        self.addSubview(flashButton)
        
        toggleCameraButton = UIButton()
        toggleCameraButton.setImage(UIImage(named: "Front_Back"), forState: .Normal)
        toggleCameraButton.sizeToFit()
        toggleCameraButton.addTarget(self, action: "toggleCameraButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(toggleCameraButton)
        
        if (self.showMicrophoneButton) {
            microphoneButton = UIButton()
            microphoneButton.setImage(UIImage(named: "Audio"), forState: .Normal)
            microphoneButton.sizeToFit()
            microphoneButton.addTarget(self, action: "microphoneButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(microphoneButton)
        }
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.setTranslatesAutoresizingMaskIntoConstraints(false)
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
        
        frontCameraButtonView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.mas_width)
            make.height.equalTo()(self.mas_width)
        }
        
        backCameraButtonView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.mas_width)
            make.height.equalTo()(self.mas_width)
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
        
        self.checkDeviceAuthorizationStatus()
        
        self.sessionQueue = dispatch_get_main_queue()!
        
        dispatch_async(self.sessionQueue, { () -> Void in
            self.backgroundRecordingId = UIBackgroundTaskInvalid
            
            var error: NSError?
            
            var videoDevice = CameraView.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: AVCaptureDevicePosition.Front)
            
            if (videoDevice == nil) {
                self.showAlert(self.CAMERA_ERROR, message: NSLocalizedString("Unable to find a camera"))
                self.activityIndicator.stopAnimating()
                return;
            }
            
            var deviceInput: AVCaptureDeviceInput! = AVCaptureDeviceInput.deviceInputWithDevice(videoDevice, error: &error) as? AVCaptureDeviceInput
            
            if (deviceInput == nil || error != nil) {
                self.toggleCameraButton.enabled = false
                
                println("TakePicture error: \(error)")
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
                    
                    var previewViewLayer = self.previewView.layer as AVCaptureVideoPreviewLayer
                    previewViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewViewLayer.connection.videoOrientation = self.currentInterfaceOrientation
                    
                    self.activityIndicator.stopAnimating()
                })
            }
            
            if (self.showMicrophoneButton) {
                // We should ask for audio access if we aren't showing the button to record audio.
                if let audioDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio).first as? AVCaptureDevice {
                    error = nil

                    if let audioDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(audioDevice, error: &error) as? AVCaptureDeviceInput {
                        self.isMicrophoneAvailable = true
                        if (self.session.canAddInput(audioDeviceInput as AVCaptureInput)) {
                            self.session.addInput(audioDeviceInput as AVCaptureInput)
                        }
                    } else {
                        self.isMicrophoneAvailable = false
                        
                        let alertView = UIAlertView(title: NSLocalizedString("Microphone Error"), message: error?.localizedFailureReasonOrDescription, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    }
                } else {
                    self.isMicrophoneAvailable = false
                }
            }
            
            var movieOutput = AVCaptureMovieFileOutput()
            
            if (self.session.canAddOutput(movieOutput)) {
                self.session.addOutput(movieOutput)
                var connection = movieOutput.connectionWithMediaType(AVMediaTypeVideo)

                if (connection.videoStabilizationEnabled) {
                    connection.enablesVideoStabilizationWhenAvailable = true
                }
                self.movieFileOutput = movieOutput
            }
            
            var imageOutput = AVCaptureStillImageOutput()
            if (self.session.canAddOutput(imageOutput)) {
                imageOutput.outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
                self.session.addOutput(imageOutput)
                self.stillImageOutput = imageOutput
            }
        })
    }
    
    func registerObservers() {
        dispatch_async(self.sessionQueue, { () -> Void in
            self.addObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: SessionRunningAndDeviceAuthorizedContext)
            self.addObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: CapturingStillImageContext)
            self.addObserver(self, forKeyPath: self.RECORDING_KEY_PATH, options: (NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New), context: RecordingContext)
            
            if let deviceInput = self.videoDeviceInput {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: deviceInput.device)
            }
            
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
            self.observersRegistered = true
        })
    }
    
    func removeObservers() {
        dispatch_async(self.sessionQueue, { () -> Void in
            self.session.stopRunning()
            
            if (self.observersRegistered!) {
                
                if let deviceInput = self.videoDeviceInput {
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: deviceInput.device)
                }
                
                NSNotificationCenter.defaultCenter().removeObserver(self.runtimeErrorHandlingObserver)
                
                self.removeObserver(self, forKeyPath: self.DEVICE_AUTHORIZED_KEY_PATH, context: SessionRunningAndDeviceAuthorizedContext)
                self.removeObserver(self, forKeyPath: self.CAPTURING_STILL_IMAGE_KEY_PATH, context: CapturingStillImageContext)
                self.removeObserver(self, forKeyPath: self.RECORDING_KEY_PATH, context: RecordingContext)
                
                self.observersRegistered = false
            }
        })
    }
    
    
    // MARK: - Overridden Method
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
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
    
    func bringButtonsToFront() {
        self.bringSubviewToFront(flashButton)
        self.bringSubviewToFront(flashLabel)
        self.bringSubviewToFront(toggleCameraButton)
        
        if (showMicrophoneButton) {
            self.bringSubviewToFront(microphoneButton)
        }
    }
    
    func toggleCameraButtonTapped() {
        self.delegate?.cameraView(self, cameraAvailable: false)
        self.toggleCameraButton.enabled = false
        
        dispatch_async(self.sessionQueue, { () -> Void in
            if let currentVideoDevice = self.videoDeviceInput?.device {
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
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (self.showingFrontCamera) {
                        UIView.transitionFromView(self.frontCameraButtonView, toView: self.backCameraButtonView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: { (finished) -> Void in
                            self.frontCameraButtonView.alpha = 0
                            self.backCameraButtonView.alpha = 1
                            self.bringButtonsToFront()
                        })
                    } else {
                        UIView.transitionFromView(self.backCameraButtonView, toView: self.frontCameraButtonView, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: { (finished) -> Void in
                            self.frontCameraButtonView.alpha = 1
                            self.backCameraButtonView.alpha = 0
                            self.bringButtonsToFront()
                        })
                    }
                    self.showingFrontCamera = !self.showingFrontCamera
                })
                
                self.session.commitConfiguration()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.flashButton.enabled = flashEnabled
                    self.flashLabel.hidden = !flashEnabled
                    
                    self.delegate?.cameraView(self, cameraAvailable: true)
                    self.toggleCameraButton.enabled = true
                })
            }
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
        
        if let device = self.videoDeviceInput?.device {
            CameraView.setFlashMode(self.flashMode, forDevice: device)
        }
    }
    
    func microphoneButtonTapped() {
        if (self.isMicrophoneAvailable) {
            self.delegate?.cameraViewDidTapMicrophoneButton!(self)
        } else {
            var alertMessage = UIAlertView(title: LocalizedString.MICROPHONE_ACCESS, message: LocalizedString.MICROPHONE_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
        }
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
                    var image = UIImage(data: imageData)!
        
                    if (self.videoDeviceInput.device.position == AVCaptureDevicePosition.Front) {
                        image = UIImage(CGImage: image.CGImage, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)!
                        image = image.cropSquareThumbnail()
                    } else {
                        image = image.cropSquareThumbnail()
                    }

                    success(image)
                } else {
                    fail(error)
                }
            })
        })
    }
    
    func captureVideo() {
        let videoPreviewLayer = self.previewView.layer as AVCaptureVideoPreviewLayer
        let videoConnection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        videoConnection.videoOrientation = videoPreviewLayer.connection.videoOrientation
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        CameraView.setFlashMode(self.flashMode, forDevice: self.videoDeviceInput.device)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss.SSS"
        let currentFileName = "recording-\(dateFormatter.stringFromDate(NSDate())).mov"
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var videoFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        var videoURL = NSURL(fileURLWithPath: videoFilePath)!
        
        var fileManager = NSFileManager.defaultManager()
        
        if (fileManager.fileExistsAtPath(videoURL.path!)) {
            println("File already exists, removing it.")
            fileManager.removeItemAtURL(videoURL, error: nil)
        }
        
        let oneSecond = 1 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
        
        dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
            self.stopRecording()
        }

        self.movieFileOutput.startRecordingToOutputFileURL(videoURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        println("Stop recording video")
        self.movieFileOutput.stopRecording()
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
            if let device = self.videoDeviceInput?.device {
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
    
    class func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice! {
        var devices = AVCaptureDevice.devicesWithMediaType(mediaType)
        var captureDevice: AVCaptureDevice! = devices.first as? AVCaptureDevice
        
        for device in devices as [AVCaptureDevice]! {
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
    
    // MARK: - Utility Methods
    
    func checkDeviceAuthorizationStatus() {
        var mediaType = AVMediaTypeVideo
        
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
        default:
            self.deviceAuthorized = false
            self.delegate?.cameraView(self, cameraAvailable: false)
            showAlert(title, message: message)
        }
    }
    
    
    // MARK: Finish Record Output Delegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if (error != nil) {
            println("An error happen while recording a video: error [\(error)] and userinfo[\(error.userInfo)]")
            self.delegate?.cameraView!(self, didFinishRecordingVideoAtURL: nil, withSuccess: false)
        } else {
            self.delegate?.cameraView!(self, didFinishRecordingVideoAtURL: outputFileURL, withSuccess: true)
        }
    }
}


@objc protocol CameraViewDelegate {
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool) // Take a picture button should be disabled
    optional func cameraViewDidTapMicrophoneButton(cameraView: CameraView)
    optional func cameraView(cameraView: CameraView, didFinishRecordingVideoAtURL videoURL: NSURL?, withSuccess success: Bool)
}