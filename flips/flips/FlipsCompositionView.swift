//
//  FlipsCompositionView.swift
//  flips
//
//  Created by Taylor Bell on 8/27/15.
//
//

import Foundation
import UIKit

class FlipsCompositionView : UIView, UIScrollViewDelegate {
    
    weak var delegate : FlipsCompositionViewDelegate?
    weak var dataSource : FlipsCompositionViewDataSource?
    weak var cameraViewDelegate : CameraViewDelegate! {
        set {
            cameraView.delegate = newValue
        }
        get {
            return cameraView.delegate
        }
    }
    
    // Recording Timer
    private var audioTimer : NSTimer!
    
    // UI
    private var cameraView : CameraView!
    private var progressBar : UIView!
    private var audioButton : UIButton!
    private var previewScrollView : UIScrollView!
    private var playerViews : [FlipCompositionPlayerView!] = []
    
    
    
    ////
    // MARK: - init
    ////
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        initSubviews()
        initConstraints()
    }
    
    
    
    ////
    // MARK: - Subview Initialization
    ////
    
    func initSubviews() {
        
        cameraView = CameraView(interfaceOrientation: .Portrait, showAvatarCropArea: false, showMicrophoneButton: false)
        self.addSubview(cameraView)
        
        previewScrollView = UIScrollView()
        previewScrollView.delegate = self
        previewScrollView.pagingEnabled = true
        previewScrollView.bounces = false
        self.addSubview(previewScrollView)
        
        progressBar = UIView()
        progressBar.backgroundColor = UIColor.avacado()
        self.addSubview(progressBar)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleAudioButtonPress:"))
        longPressRecognizer.minimumPressDuration = 0.1
        
        audioButton = UIButton()
        audioButton.setImage(UIImage(named: "Capture_Audio")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        audioButton.sizeToFit()
        audioButton.tintColor = UIColor.redColor()
        audioButton.hidden = true
        audioButton.addGestureRecognizer(longPressRecognizer)
        self.addSubview(audioButton)
    
    }
    
    func initConstraints() {
        
        cameraView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.height.equalTo()(self)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self)
        }
        
        progressBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.height.equalTo()(UIScreen.mainScreen().bounds.size.height * 0.01)
            make.width.equalTo()(0)
        }
        
        audioButton.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.right.equalTo()(self).offset()(-25)
        }
        
        previewScrollView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self)
        }
        
    }
    
    
    
    ////
    // MARK: - Video Capture
    ////
    
    func startVideoCapture() {
        startCaptureProgressBar()
        cameraView.startRecording()
    }
    
    func finishVideoCapture() {
        cameraView.stopRecording()
        hideCaptureProgressBar()
    }
    
    
    
    ////
    // MARK: - Image Capture
    ////
    
    func capturePhotoWithCompletion(success: CapturePictureSuccess, failure: CapturePictureFail) {
        cameraView.capturePictureWithCompletion(success, fail: failure)
    }
    
    
    
    ////
    // MARK: - Progress Bar
    ////
    
    func startCaptureProgressBar() {
        
        progressBar.hidden = false;
        
        UIView.animateWithDuration(3.0, animations: { () -> Void in
            
            self.progressBar.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self)
                update.left.equalTo()(self)
                update.height.equalTo()(UIScreen.mainScreen().bounds.size.height * 0.01)
                update.width.equalTo()(self)
            })
            
            self.layoutIfNeeded()
            
        }) { (completed) -> Void in
            
            self.progressBar.hidden = true
            
            self.progressBar.mas_updateConstraints({ (update) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self)
                update.left.equalTo()(self)
                update.height.equalTo()(UIScreen.mainScreen().bounds.size.height * 0.01)
                update.width.equalTo()(0)
            })
                
            self.layoutIfNeeded()
            
        }
        
    }
    
    func hideCaptureProgressBar() {
        progressBar.hidden = true
    }
    
    
    
    ////
    // MARK: - Audio Button
    ////
    
    func showAudioButton(animated: Bool) {
        
        audioButton.hidden = false
        
        if animated
        {
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 1.0
            pulseAnimation.fromValue = 0.8
            pulseAnimation.toValue = 1
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = 10
            
            audioButton.layer.addAnimation(pulseAnimation, forKey: "pulse")
        }
        
    }
    
    func hideAudioButton() {
        audioButton.hidden = true
        audioButton.layer.removeAnimationForKey("pulse")
    }
    
    func startAudioTimer() {
        audioTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("handleAudioTimerExpired"), userInfo: nil, repeats: false)
    }
    
    func clearAudioTimer() {
        audioTimer.invalidate()
        audioTimer = nil
    }
    
    func handleAudioTimerExpired() {
        
        if let timer = self.audioTimer {
            clearAudioTimer()
            hideCaptureProgressBar()
            delegate?.didReleaseRecordAudioButton()
        }
        
    }
    
    func handleAudioButtonPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch(gestureRecognizer.state) {
            case .Began:
                self.delegate?.didPressRecordAudioButton()
                audioButton.layer.removeAnimationForKey("pulse")
                startCaptureProgressBar()
                startAudioTimer()
                break;
            case .Ended:
                if let timer = self.audioTimer {
                    clearAudioTimer()
                    hideCaptureProgressBar()
                    self.delegate?.didReleaseRecordAudioButton()
                }
                break;
            default:
                break;
        }
        
    }
    
    
    
    ////
    // Camera View Management
    ////
    
    func updateCameraViewObservers() {
        
        if let source = dataSource {
            
            if source.currentFlipWordHasContent() {
                cameraView.removeObservers()
            }
            else {
                cameraView.registerObservers()
            }
            
        }
        
    }
    
    
    
    ////
    // MARK: - Player View Management
    ////
    
    internal func refresh() {
        
        if let source = dataSource
        {
            if source.flipWordsCount() != playerViews.count
            {
                initPlayerViews()
            }
            else
            {
                updatePlayerViews()
            }
            
            let index = Int(floor(previewScrollView.contentOffset.x / previewScrollView.frame.width))
            
            if let image = source.flipImageForWordAtIndex(index)
            {
                showAudioButton(true)
            }
            else
            {
                hideAudioButton()
            }
            
            updateCameraViewObservers()
            
        }
        
    }
    
    internal func initPlayerViews() {
        
        if playerViews.count > 0
        {
            for playerView in playerViews
            {
                playerView.removeFromSuperview()
            }
            
            playerViews = Array()
        }
        
        if let source = dataSource
        {
            for var index = 0; index < source.flipWordsCount(); index++
            {
                insertWordLabelAtIndex(index)
                
                let playerView = playerViewForIndex(index)
                playerViews.append(playerView)
            }
            
            let contentHeight = previewScrollView.frame.height
            let contentWidth = previewScrollView.frame.width * CGFloat(source.flipWordsCount())
            
            previewScrollView.contentSize = CGSizeMake(contentWidth, contentHeight)
            
            scrollToIndex(source.currentFlipWord().position, animated: false)
        }
        
    }
    
    internal func updatePlayerViews() {
        
        if let source = dataSource
        {
            for var index = 0; index < source.flipWordsCount(); index++
            {
                if shouldUpdatePlayerViewAtIndex(index)
                {
                    let newPlayerView = playerViewForIndex(index)
                    
                    if newPlayerView == nil && playerViews[index] != nil
                    {
                        animateViewSwipedOut(playerViews[index])
                    }
                    else if newPlayerView != nil && playerViews[index] != nil
                    {
                        playerViews[index].removeFromSuperview()
                    }
                    
                    playerViews[index] = newPlayerView
                }
            }
        }
        
    }
    
    internal func shouldUpdatePlayerViewAtIndex(index: Int) -> (Bool) {
        
        if let source = dataSource {
            
            let flipWord = source.flipWordAtIndex(index)
            let flipPage = source.flipPageForWordAtIndex(index)
            
            let hasFlip = flipWord.associatedFlipId != nil || flipPage.pageID != nil
            let hasVideo = flipPage.videoURL != nil
            let hasImage = source.flipWordAtIndexHasImage(index)
            
            if let playerView = playerViews[index]
            {
                if hasFlip
                {
                    let playerFlipID = playerView.flip?.flipID
                    return playerFlipID == nil || (playerFlipID != flipWord.associatedFlipId && playerFlipID != flipPage.pageID)
                }
                else if hasVideo
                {
                    let playerVideoURL = playerView.flip != nil ? playerView.flip?.backgroundURL : nil
                    return playerVideoURL == nil || playerVideoURL != flipPage.videoURL?.absoluteString
                }
                else if hasImage
                {
                    let playerImage = playerView.flipImage
                    return playerImage != source.flipImageForWordAtIndex(index)
                }
                
                return true
            }
            else
            {
                return hasFlip || hasVideo || hasImage;
            }
            
        }
        
        return false
        
    }
    
    private func insertWordLabelAtIndex(index: Int) {
        
        if let source = dataSource {
            
            let wordLabel = UILabel.flipWordLabel()
            wordLabel.sizeToFit()
            wordLabel.text = source.flipWordAtIndex(index).text
            previewScrollView.addSubview(wordLabel)
            
            wordLabel.mas_makeConstraints { (make) -> Void in
                make.bottom.equalTo()(self.previewScrollView).with().offset()(self.previewScrollView.frame.height + FLIP_WORD_LABEL_MARGIN_BOTTOM)
                make.centerX.equalTo()(self.previewScrollView).with().offset()(self.previewScrollView.frame.width * CGFloat(index))
            }
            
        }
        
    }
    
    private func playerViewForIndex(index: Int) -> (FlipCompositionPlayerView?) {
        
        if let unwrappedDataSource = dataSource {
            
            let flipWord = unwrappedDataSource.flipWordAtIndex(index)
            let flipPage = unwrappedDataSource.flipPageForWordAtIndex(index)
            var playerView : FlipCompositionPlayerView?
            
            if (flipWord.associatedFlipId != nil)
            {
                let flip = FlipDataSource().getFlipById(flipWord.associatedFlipId!)
                playerView = FlipCompositionPlayerView(flip: flip)
            }
            else if (flipPage.videoURL != nil)
            {
                let flip = flipPage.createFlip()
                playerView = FlipCompositionPlayerView(flip: flip)
            }
            else if (flipPage.pageID != nil)
            {
                let flip = FlipDataSource().getFlipById(flipPage.pageID!)
                playerView = FlipCompositionPlayerView(flip: flip)
            }
            else if (unwrappedDataSource.flipWordAtIndexHasImage(index))
            {
                let image = unwrappedDataSource.flipImageForWordAtIndex(index)
                playerView = FlipCompositionPlayerView(image: image!, text: flipWord.text)
            }
            
            if let resultView = playerView {
                
                let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("didSwipeUpPlayerView:"))
                swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
                playerView?.addGestureRecognizer(swipeRecognizer)
                
                previewScrollView.addSubview(resultView)
                
                resultView.mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.previewScrollView)
                    make.left.equalTo()(self.previewScrollView.frame.width * CGFloat(index))
                    make.width.equalTo()(self.previewScrollView)
                    make.height.equalTo()(self.previewScrollView)
                })
                
            }
            
            return playerView
            
        }
        
        return nil
        
    }
    
    
    
    ////
    // MARK: - Swipe Up Gesture Handler
    ////
    
    internal func didSwipeUpPlayerView(gestureRecognizer: UISwipeGestureRecognizer) {
        
        hideAudioButton()
        
        if let playerView = gestureRecognizer.view as? FlipCompositionPlayerView
        {
            let currentCenter = playerView.center
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                
                playerView.center = CGPointMake(currentCenter.x, -(playerView.frame.height / 2))
                
            }, completion: { (success) -> Void in
                
                playerView.removeFromSuperview()
                
                for var index : Int = 0; index < self.playerViews.count; index++
                {
                    let currentPlayerView = self.playerViews[index]
                    
                    if currentPlayerView != nil && currentPlayerView == playerView
                    {
                        self.playerViews[index] = nil
                        self.delegate?.didSwipeAwayFlipAtIndex(index)
                        break
                    }
                }
                
                
            })
        }
        
    }
    
    internal func animateViewSwipedOut(playerView : FlipCompositionPlayerView) {
        
        let currentCenter = playerView.center
            
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            
            playerView.center = CGPointMake(currentCenter.x, -(playerView.frame.height / 2))
            
        }, completion: { (success) -> Void in
            
            playerView.removeFromSuperview()
            
        })
        
    }
    
    
    
    ////
    // MARK: - Scrolling
    ////
    
    internal func scrollToIndex(index: Int, animated: Bool = true) {
        
        let offset = CGPointMake(CGFloat(index) * self.previewScrollView.frame.width, 0)
        previewScrollView.setContentOffset(offset, animated: animated)
        
        if let playerView = playerViews[index], source = dataSource
        {
            if source.flipImageForWordAtIndex(index) == nil
            {
                hideAudioButton()
            }
            else
            {
                showAudioButton(true)
            }
        }
        
    }
    
    
    
    ////
    // MARK: - UIScrollView Delegate
    ////
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        delegate?.didScrollToFlipAtIndex(currentPage)
    }

}

protocol FlipsCompositionViewDelegate : class {
    
    func didPressRecordAudioButton()
    
    func didReleaseRecordAudioButton()
    
    func didScrollToFlipAtIndex(index: Int)
    
    func didSwipeAwayFlipAtIndex(index: Int)
    
}

protocol FlipsCompositionViewDataSource : class {
    
    func currentFlipWord() -> (FlipText)
    
    func flipWordsCount() -> (Int)
    
    func flipWordAtIndex(index: Int) -> (FlipText)
    
    func flipPageForWordAtIndex(index: Int) -> (FlipPage)
    
    func flipWordAtIndexHasImage(index: Int) -> (Bool)
    
    func flipImageForWordAtIndex(index: Int) -> (UIImage?)
    
    func currentFlipWordHasContent() -> (Bool)
    
}