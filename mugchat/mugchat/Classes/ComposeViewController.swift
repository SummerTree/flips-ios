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

class ComposeViewController : MugChatViewController, FlipMessageWordListViewDelegate, FlipMessageWordListViewDataSource, ComposeBottomViewContainerDelegate, ComposeBottomViewContainerDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderServiceDelegate, ConfirmFlipViewControllerDelegate {
    
    private let NO_EMPTY_FLIP_INDEX = -1
    
//    private let composeView : ComposeView
//    private let cacheHandler = CacheHandler.sharedInstance
    
    private let IPHONE_4S_TOP_CONTAINER_HEIGHT: CGFloat = 240.0
    private let FLIP_MESSAGE_WORDS_LIST_HEIGHT: CGFloat = 50.0
    
    private var composeTopViewContainer: ComposeTopViewContainer!
    private var flipMessageWordListView: FlipMessageWordListView!
    private var composeBottomViewContainer: ComposeBottomViewContainer!
    
    private var composeTitle: String!
    private var flipWords: [MugText]!
    
    private var highlightedWordIndex: Int!
    
    private var myMugsDictionary: Dictionary<String, [Mug]>!
    
    
    private var highlightedWordCurrentAssociatedImage: UIImage!
    
    // MARK: - Init Methods
    
    init(composeTitle: String, words : [String]) {
        super.init(nibName: nil, bundle: nil)
        self.composeTitle = composeTitle

        self.initFlipWords(words)
        
        self.highlightedWordIndex = 0
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initFlipWords(words: [String]) {
        flipWords = Array()
        for (var i = 0; i < words.count; i++) {
            var word = words[i]
            var mugText: MugText = MugText(position: i, text: word, state: FlipState.NewWord)
            self.flipWords.append(mugText)
        }
    }
    
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(self.composeTitle)
        
        var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
        previewBarButton.tintColor = UIColor.orangeColor()
        self.navigationItem.rightBarButtonItem = previewBarButton
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.addSubviews()
        self.addConstraints()
        
        self.reloadMyMugs()
        self.updateFlipWordsState()
        
        self.showContentForHighlightedWord()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    
    // MARK: - View Initialization Methods
    
    private func addSubviews() {
        composeTopViewContainer = ComposeTopViewContainer()
        self.view.addSubview(composeTopViewContainer)
        
        flipMessageWordListView = FlipMessageWordListView()
        flipMessageWordListView.dataSource = self
        flipMessageWordListView.delegate = self
        self.view.addSubview(flipMessageWordListView)
        
        composeBottomViewContainer = ComposeBottomViewContainer()
        composeBottomViewContainer.delegate = self
        composeBottomViewContainer.dataSource = self
        self.view.addSubview(composeBottomViewContainer)
    }
    
    private func addConstraints() {
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView

        composeTopViewContainer.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.view)
                make.height.equalTo()(self.IPHONE_4S_TOP_CONTAINER_HEIGHT)
            } else {
                make.height.equalTo()(self.view.mas_width)
            }
        }
        
//        var topLayoutConstraint = NSLayoutConstraint(item: composeTopViewContainer,
//            attribute: NSLayoutAttribute.Top,
//            relatedBy: NSLayoutRelation.Equal,
//            toItem: self.topLayoutGuide,
//            attribute: NSLayoutAttribute.Bottom,
//            multiplier: 1,
//            constant: 0)
//        self.view.addConstraint(topLayoutConstraint)
        
        flipMessageWordListView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.composeTopViewContainer.mas_bottom)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(self.FLIP_MESSAGE_WORDS_LIST_HEIGHT)
        }
        
        composeBottomViewContainer.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipMessageWordListView.mas_bottom)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
        }
    }
    

    // MARK: - Bar Buttons
    
    func previewButtonTapped(sender: AnyObject?) {
        self.openPreview()
    }
    
    
    // MARK: - View States Setters
    
    private func showContentForHighlightedWord() {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let flipWord = self.flipWords[self.highlightedWordIndex]
            
            if (flipWord.associatedMug != nil) {
                self.showFlipCreatedState(flipWord.associatedMug!)
            } else {
                let flipDataSource = MugDataSource()
                let myFlips = flipDataSource.getMyMugsForWord(flipWord.text)
                if (myFlips.count > 0) {
                    self.showNewFlipWithSavedFlipsForWord(flipWord.text)
                } else {
                    self.showNewFlipWithoutSavedFlipsForWord(flipWord.text)
                }
            }
        })
    }
    
    private func showFlipCreatedState(flip: Mug) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.composeTopViewContainer.showFlip(flip)
            self.composeBottomViewContainer.showMyMugs()
            self.flipMessageWordListView.reloadWords()
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    private func showNewFlipWithoutSavedFlipsForWord(word: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.composeTopViewContainer.showCameraWithWord(word)
            self.composeBottomViewContainer.showCameraButtons()
            self.flipMessageWordListView.reloadWords()
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    private func showNewFlipWithSavedFlipsForWord(word: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: word)
            self.composeBottomViewContainer.showMyMugs()
            self.flipMessageWordListView.reloadWords()
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    
    // MARK: - Flips CoreData Loader
    
    private func reloadMyMugs() {
        let flipDataSource = MugDataSource()
        
        var words = Array<String>()
        for flipWord in flipWords {
            words.append(flipWord.text)
        }
        
        myMugsDictionary = flipDataSource.getMyMugsForWords(words)
    }
    
    
    // MARK: - FlipWords Methods
    
    private func updateFlipWordsState() {
        for flipWord in flipWords {
            let word = flipWord.text
            let myMugsForWord = myMugsDictionary[word]
            println("word[\(word)] count: \(myMugsForWord!.count)")

            if (flipWord.associatedMug == nil) {
                if (myMugsForWord!.count == 0) {
                    flipWord.state = .NewWord
                } else {
                    flipWord.state = .NotAssociatedWithResources
                }
            } else {
                if (myMugsForWord!.count == 1) {
                    flipWord.state = .AssociatedWithoutOtherResources
                } else {
                    flipWord.state = .AssociatedWithOtherResources
                }
            }
        }
    }
    
    private func nextEmptyFlipWordIndex() -> Int {
        var index = 0
        for flipWord in flipWords {
            if (flipWord.associatedMug == nil) {
                return index
            }
            index++
        }
        return NO_EMPTY_FLIP_INDEX
    }
    
    private func moveToNextFlipWord() {
        let nextIndex = self.nextEmptyFlipWordIndex()
        if (nextIndex == NO_EMPTY_FLIP_INDEX) {
            self.openPreview()
        } else {
            self.highlightedWordIndex = nextIndex
            self.showContentForHighlightedWord()
        }
    }
    
    
    // MARK: - FlipMessageWordListViewDataSource
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> MugText {
        return flipWords[index]
    }
    
    func numberOfFlipWords() -> Int {
        return flipWords.count
    }
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int {
        return highlightedWordIndex
    }
    
    
    // MARK: - FlipMessageWordListViewDelegate
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSelectFlipWord flipWord: MugText!) {
        highlightedWordIndex = flipWord.position
        
        println("didSelectFlipWord: \(flipWord.text)")
        var status : FlipState = flipWord.state
        switch status {
        case FlipState.NewWord:
            composeTopViewContainer.showCameraWithWord(flipWord.text)
            composeBottomViewContainer.showCameraButtons()
        case FlipState.NotAssociatedWithResources:
            composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
            composeBottomViewContainer.showMyMugs()
        case FlipState.AssociatedWithoutOtherResources, FlipState.AssociatedWithOtherResources:
            composeTopViewContainer.showFlip(flipWord.associatedMug!)
            composeBottomViewContainer.showMyMugs()
        }
    }
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSplitFlipWord flipWord: MugText!) {
        println("didSplitFlipWord: \(flipWord.text)")
    }

    
    private func openPreview() {
        let previewViewController = PreviewViewController(words: flipWords)
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    
    // MARK: - ComposeBottomViewContainerDelegate Methods
    
    func composeBottomViewContainerDidTapCaptureAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        AudioRecorderService.sharedInstance.delegate = self
        AudioRecorderService.sharedInstance.startRecording()
    }
    
    func composeBottomViewContainerDidTapSkipAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipPicture: self.highlightedWordCurrentAssociatedImage, flipAudio: nil)
        confirmFlipViewController.delegate = self
        self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
    }
    
    func composeBottomViewContainerDidHoldShutterButton(composeBottomViewContainer: ComposeBottomViewContainer) {
//        composeTopViewContainer.captureVideo()
    }
    
    func composeBottomViewContainerDidTapTakePictureButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        composeTopViewContainer.capturePictureWithCompletion({ (image) -> Void in
            if (image != nil) {
                let receivedImage = image as UIImage!
                self.highlightedWordCurrentAssociatedImage = receivedImage
                let flipWord = self.flipWords[self.highlightedWordIndex]
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.composeTopViewContainer.showImage(receivedImage, andText: flipWord.text)
                    self.composeBottomViewContainer.showAudioRecordButton()
                })
            } else {
                println("Capturing picture problem. Image is nil")
            }
            }, fail: { (error) -> Void in
                println("Error capturing picture: \(error)")
        })
    }
    
    func composeBottomViewContainerWillOpenMyMugsView(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        
        if (flipWord.associatedMug != nil) {
            composeTopViewContainer.showFlip(flipWord.associatedMug)
            // TODO: we need to set selected mug in bottom
        } else {
            composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
        }
    }
    
    func composeBottomViewContainerWillOpenCameraControls(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        composeTopViewContainer.showCameraWithWord(flipWord.text)
    }
    
    func composeBottomViewContainerDidTapGalleryButton(composeBottomViewContainer: ComposeBottomViewContainer) {
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
    
    
//    func composeViewDidFinishRecordingView(composeView: ComposeView!, withURL videoURL: NSURL!) {
//        let confirmFlipViewController = ConfirmFlipViewController(flipWord: self.composeView.getMugWord(), flipVideo: videoURL)
//        self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
//    }
    
    // MARK: - ComposeBottomViewContainerDataSource
    
    func composeBottomViewContainerFlipsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [Mug] {
        println("composeBottomViewContainerFlipsForHighlightedWord")
        // TODO:
        return Array<Mug>()
    }
    
    
    // MARK: - Gallery control
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        if (NSThread.mainThread() == NSThread.currentThread()) {
            println("IS MAIN THREAD")
        }
        
        let flipWord = self.flipWords[self.highlightedWordIndex]
        self.highlightedWordCurrentAssociatedImage = image.cropImageInCenter()
        composeTopViewContainer.showImage(self.highlightedWordCurrentAssociatedImage, andText: flipWord.text)
        composeBottomViewContainer.showAudioRecordButton()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Audio Recorder Service Delegate
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL fileURL: NSURL?, success: Bool!) {
        if (NSThread.mainThread() == NSThread.currentThread()) {
            println("IS MAIN THREAD")
        }
        
        let flipWord = self.flipWords[self.highlightedWordIndex]
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text,
            flipPicture: self.highlightedWordCurrentAssociatedImage,
            flipAudio: fileURL)
        
        confirmFlipViewController.delegate = self
        self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
    }
    
    
    // MARK: - ConfirmFlipViewController Delegate
    
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success: Bool, mug: Mug?) {
        if (success) {
            let flipWord = self.flipWords[self.highlightedWordIndex]
            flipWord.associatedMug = mug
            
            self.moveToNextFlipWord()
        } else {
            println("confirm fail")
        }
    }
}