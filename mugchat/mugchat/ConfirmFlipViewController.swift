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
    
    private var confirmFlipView: ConfirmFlipView!
    private var previewFlipTimer: NSTimer!
    private var isPlaying = true
    
    convenience init(flipPicture: UIImage!, flipWord: String!) {
        self.init()
        self.confirmFlipView = ConfirmFlipView(flipPicture: flipPicture, flipWord: flipWord)
    }
    
    override func loadView() {
        self.view = self.confirmFlipView
        self.confirmFlipView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithoutButtons(NSLocalizedString("MugBoys", comment: "MugBoys"))
        
        var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
        previewBarButton.enabled = false
        previewBarButton.tintColor = UIColor.orangeColor()
        self.navigationItem.rightBarButtonItem = previewBarButton
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        confirmFlipView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        AudioRecorderService.sharedInstance.playLastRecordedAudio()
        self.previewFlipTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "startPreviewFlipTimer", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.previewFlipTimer.invalidate()
    }
    
    func startPreviewFlipTimer() {
        AudioRecorderService.sharedInstance.playLastRecordedAudio()
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
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func confirmFlipViewDidTapPlayOrPausePreviewButton(flipView: ConfirmFlipView!) {
        if (isPlaying) {
            self.previewFlipTimer.invalidate()
        } else {
            AudioRecorderService.sharedInstance.playLastRecordedAudio()
            self.previewFlipTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "startPreviewFlipTimer", userInfo: nil, repeats: true)
        }
        
        self.isPlaying = !self.isPlaying
    }
}