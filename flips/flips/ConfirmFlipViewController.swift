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

class ConfirmFlipViewController: UIViewController, ConfirmFlipViewDelegate {
    
    var delegate: ConfirmFlipViewControllerDelegate?
    
    private var confirmFlipView: ConfirmFlipView!

    var showPreviewButton = true
    
    private var flipWord: String!
    private var flipVideoURL: NSURL?
    private var flipThumbnailURL: NSURL?

    convenience init(flipWord: String!, flipPicture: UIImage?, flipAudio: NSURL?) {
        self.init()
        self.flipWord = flipWord
        self.confirmFlipView = ConfirmFlipView()

        var videoComposer = VideoComposer()
        videoComposer.flipVideoFromImage(flipPicture, andAudioURL:flipAudio, successHandler: { (flipVideoURL, thumbnailURL) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.flipVideoURL = flipVideoURL
                self.flipThumbnailURL = thumbnailURL
                self.confirmFlipView.setupPlayerWithWord(flipWord, videoURL: flipVideoURL)
            })
        })
        
    }
    
    convenience init(flipWord: String!, flipVideo: NSURL?) {
        self.init()
        self.flipWord = flipWord
        self.confirmFlipView = ConfirmFlipView()

        var videoComposer = VideoComposer()
        videoComposer.flipVideoFromVideo(flipVideo, successHandler: { (flipVideoURL, thumbnailURL) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.flipVideoURL = flipVideoURL
                self.flipThumbnailURL = thumbnailURL
                self.confirmFlipView.setupPlayerWithWord(flipWord, videoURL: flipVideoURL)
            })
        })
    }
    
    override func loadView() {
        self.view = self.confirmFlipView
        self.view.backgroundColor = UIColor.whiteColor()
        self.confirmFlipView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWhiteNavBarWithoutButtons(self.title!)
        
        if (showPreviewButton) {
            var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
            previewBarButton.enabled = false
            previewBarButton.tintColor = UIColor.orangeColor()
            self.navigationItem.rightBarButtonItem = previewBarButton
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        confirmFlipView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.confirmFlipView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    
    // MARK: - ConfirmFlipViewDelegate
    
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        pictureContainerView.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
    
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!) {
        self.confirmFlipView.showActivityIndicator()

        var createFlipSuccessBlock : CreateFlipSuccessCompletion = { (flip) -> Void in
            let flipInContext = flip.inContext(NSManagedObjectContext.MR_defaultContext()) as Flip
            self.navigationController?.popViewControllerAnimated(false)
            self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: true, flipID: flipInContext.flipID)
            self.confirmFlipView.hideActivityIndicator()
        }
        
        var createFlipFailBlock : CreateFlipFailureCompletion = { (error) -> Void in
            if let flipError = error {
                let errorTitle = flipError.error?
                let errorMessage = flipError.details?
                self.confirmFlipView.hideActivityIndicator()
                self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: false, flipID: nil)
                var alertView = UIAlertView(title: errorTitle, message: errorMessage, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
        }

        PersistentManager.sharedInstance.createAndUploadFlip(self.flipWord,
            videoURL: flipVideoURL!,
            thumbnailURL: flipThumbnailURL!,
            createFlipSuccessCompletion: createFlipSuccessBlock,
            createFlipFailCompletion: createFlipFailBlock)
    }
    
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!) {
        self.delegate?.confirmFlipViewController(self, didFinishEditingWithSuccess: false, flipID: nil)
        self.navigationController?.popViewControllerAnimated(false)
    }

}

protocol ConfirmFlipViewControllerDelegate {
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success:Bool, flipID: String?)
}