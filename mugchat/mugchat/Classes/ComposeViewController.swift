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

import Foundation

class ComposeViewController : MugChatViewController, ComposeViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderServiceDelegate {
    
    private let composeView : ComposeView
    
    init() {
        composeView = ComposeView()
        super.init(nibName: nil, bundle: nil)
    }
    
    init(words : [String]) {
        composeView = ComposeView(words: words)
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        composeView.delegate = self
        self.view = composeView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(NSLocalizedString("MugChat", comment: "MugChat"))
        
        var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
        previewBarButton.tintColor = UIColor.orangeColor()
        self.navigationItem.rightBarButtonItem = previewBarButton
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.composeView.viewDidLoad()
    }
    
    
    // MARK: - Bar Buttons
    
    func previewButtonTapped(sender: AnyObject?) {
        println("Preview button tapped")
    }
    
    
    // MARK: - ComposeViewDelegate Methods
    
    func composeViewDidTapBackButton(composeView: ComposeView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func composeViewDidTapGalleryButton(composeView: ComposeView!) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            var imagePickerController = UIImagePickerControllerWithLightStatusBar()
            var textAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            imagePickerController.navigationBar.barTintColor = UIColor.mugOrange()
            imagePickerController.navigationBar.translucent = false
            imagePickerController.navigationBar.tintColor = UIColor.whiteColor()
            imagePickerController.navigationBar.titleTextAttributes = textAttributes
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePickerController.allowsEditing = false
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func composeViewDidTapCaptureAudioButton(composeView: ComposeView!) {
        AudioRecorderService.sharedInstance.delegate = self
        AudioRecorderService.sharedInstance.startRecording()
    }
    
    func composeViewDidTapTakePictureButton(composeView: ComposeView!, withCamera cameraView: CameraView!) {
        cameraView.capturePictureWithCompletion({ (image) -> Void in
            if (image != nil) {
                var receivedImage = image as UIImage!
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    composeView.setPicture(receivedImage)
                    return ()
                })
            } else {
                println("Capturing picture problem. Image is nil")
            }
            }, fail: { (error) -> Void in
                println("Error capturing picture: \(error)")
        })
    }
    
    func composeViewMakeConstraintToNavigationBarBottom(composeView: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        composeView.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }

    
    // MARK: - Gallery control
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        composeView.setPicture(image)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Audio Recorder Service Delegate
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL fileURL: NSURL?, success: Bool!) {
        audioRecorderService.playLastRecordedAudio()
    }
}