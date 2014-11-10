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

class ComposeViewController : MugChatViewController, FlipMessageWordListViewDelegate, FlipMessageWordListViewDataSource, ComposeBottomViewContainerDelegate, ComposeBottomViewContainerDataSource, ComposeTopViewContainerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderServiceDelegate, ConfirmFlipViewControllerDelegate {
    
    private let NO_EMPTY_FLIP_INDEX = -1
    
    private let IPHONE_4S_TOP_CONTAINER_HEIGHT: CGFloat = 240.0
    private let FLIP_MESSAGE_WORDS_LIST_HEIGHT: CGFloat = 50.0
    
    private var composeTopViewContainer: ComposeTopViewContainer!
    private var flipMessageWordListView: FlipMessageWordListView!
    private var composeBottomViewContainer: ComposeBottomViewContainer!
    
    private var composeTitle: String!
    private var flipWords: [MugText]!
    
    private var highlightedWordIndex: Int!
    
    private var myMugsDictionary: Dictionary<String, [Mug]>!
    
    private var highlightedWordCurrentAssociatedImage: UIImage?
    
    
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
        composeTopViewContainer.delegate = self
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
    
    private func openPreview() {
        var flips = Array<Mug>()
        for flipWord in flipWords {
            if (flipWord.associatedMug != nil) {
                flips.append(flipWord.associatedMug!)
            } else {
                let flipDataSource = MugDataSource()
                var emptyFlip = flipDataSource.createEmptyMugWithWord(flipWord.text)
                flips.append(emptyFlip)
            }
        }
        
        let previewViewController = PreviewViewController(flips: flips)
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    
    // MARK: - View States Setters
    
    private func showContentForHighlightedWord(shouldReloadWords: Bool = true) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
            
            if (shouldReloadWords) {
                self.flipMessageWordListView.reloadWords()
            }
            
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    private func showFlipCreatedState(flip: Mug) {
        //        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.composeTopViewContainer.showFlip(flip)
        self.composeBottomViewContainer.showMyMugs()
        //        })
    }
    
    private func showNewFlipWithoutSavedFlipsForWord(word: String) {
        //        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.composeTopViewContainer.showCameraWithWord(word)
        self.composeBottomViewContainer.showCameraButtons()
        //            self.flipMessageWordListView.reloadWords()
        //            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        //        })
    }
    
    private func showNewFlipWithSavedFlipsForWord(word: String) {
        //        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: word)
        self.composeBottomViewContainer.showMyMugs()
        //            self.flipMessageWordListView.reloadWords()
        //            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        //        })
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
    
    private func onMugAssociated() {
        self.reloadMyMugs()
        self.updateFlipWordsState()
        self.moveToNextFlipWord()
    }
    
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
            let flipWord = self.flipWords[self.highlightedWordIndex]
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
        
        // If the user moves to another word while we were showing the audio buttons, that Flip will be discarded.
        composeBottomViewContainer.hideRecordingView()
        highlightedWordCurrentAssociatedImage = nil
        
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
        
        var splittedTextWords: [String] = MugStringsUtil.splitMugString(flipWord.text);
        
        /////
        println("BEFORE")
        for f in flipWords {
            println("   \(f.position): \(f.text)")
        }
        /////
        
        var newFlipWords = Array<MugText>()
        var flipWordsToAdd = Array<MugText>()
        var position = 0
        if (splittedTextWords.count > 1) {
            for oldFlipWord in flipWords {
                if (flipWord.position == oldFlipWord.position) {
                    for newWord in splittedTextWords {
                        var newFlipWord = MugText(position: position, text: newWord, state: FlipState.NewWord)
                        newFlipWords.append(newFlipWord)
                        flipWordsToAdd.append(newFlipWord)
                        position++
                    }
                } else {
                    oldFlipWord.position = position // updating flip position value
                    newFlipWords.append(oldFlipWord)
                    position++
                }
            }
            flipWords = newFlipWords
            
            /////
            println("AFTER")
            for f in flipWords {
                println("   \(f.position): \(f.text)")
            }
            println("   ")
            /////
            
            self.reloadMyMugs()
            self.updateFlipWordsState()
            //            self.flipMessageWordListView.reloadWords(animated: false) // Word state can change
            self.composeBottomViewContainer.reloadMyMugs() // Refresh selected state
            
            if (highlightedWordIndex == flipWord.position) {
                self.showContentForHighlightedWord(shouldReloadWords: false)
            }
            
            self.flipMessageWordListView.replaceFlipWord(flipWord, forFlipWords: flipWordsToAdd)
            
        }
        //        var mugTextView: MugTextView
        //        var lastMugText: MugTextView!
        //        var splitMugTextView: MugTextView!
        
        //        var foundMug: Bool = false
        //        var contentOffset: CGFloat = 0.0
        //        var scrollViewWidth: CGFloat = self.scrollView.contentSize.width
        //        var textViewY = (CGRectGetHeight(self.frame) / 2) - (MUG_TEXT_HEIGHT / 2)
        
        //        var index = -1
        //        var mugTextViewsUpdated = [MugTextView]()
        //
        //        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
        //
        //            for mugTextView in self.mugTextViews {
        //                index++
        //                mugTextViewsUpdated.append(mugTextView)
        //
        //                if (mugTextView.mugText.text == text) {
        //                    foundMug = true
        //
        //                    var oldMugTextViewWidth : CGFloat = mugTextView.frame.width
        //
        //                    //Update the original MugText with the first string of the splitted text
        //                    mugTextView.mugText.text = splittedTextWords[0]
        //                    mugTextView.textLabel.text = splittedTextWords[0]
        //                    self.mugTexts[index].text = splittedTextWords[0]
        //
        //                    //update mugTextView size to fit the smaller text
        //                    var requiredWidth = mugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
        //                    var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
        //                    mugTextView.frame = CGRectMake(mugTextView.frame.origin.x, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
        //
        //                    scrollViewWidth = scrollViewWidth - oldMugTextViewWidth + mugTextViewWidth
        //
        //                    splitMugTextView = mugTextView
        //                    lastMugText = mugTextView
        //
        //                    contentOffset = lastMugText.frame.origin.x + lastMugText.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
        //
        //                    var newMugTextView : MugTextView
        //                    for var i=1; i < splittedTextWords.count; i++ { //creating and positioning new MugTextViews
        //                        index++
        //
        //                        var mugText = MugText(position: self.mugTexts.count, text: splittedTextWords[i], state: FlipState.NewWord)
        //                        self.mugTexts.insert(mugText, atIndex: index)
        //
        //                        newMugTextView = MugTextView(mugText: mugText)
        //                        self.addGestureRecognizers(newMugTextView)
        //                        self.scrollView.addSubview(newMugTextView)
        //
        //                        var requiredWidth = newMugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
        //                        var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
        //                        newMugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
        //                        mugTextViewsUpdated.append(newMugTextView)
        //
        //                        lastMugText = newMugTextView
        //                        contentOffset += newMugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
        //                        scrollViewWidth += newMugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
        //                    }
        //
        //                    self.scrollView.contentSize = CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height)
        //                } else {
        //                    if (foundMug) { //texts after the split one must be moved to the right
        //                        var requiredWidth = mugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
        //                        var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
        //
        //                        mugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
        //
        //                        contentOffset += mugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
        //                    }
        //                }
        //            }
        //
        //            }, completion: { (value: Bool) in
        //                //Inserting new mugTextViews in self.mugTextViews
        //                for var i=0; i < mugTextViewsUpdated.count; i++ {
        //                    var mugTextView = mugTextViewsUpdated[i]
        //                    if (i < self.mugTextViews.count) {
        //                        if (self.mugTextViews[i].mugText.position != mugTextView.mugText.position) {
        //                            self.mugTextViews.insert(mugTextView, atIndex: i)
        //                        }
        //                    } else { //new mugText added in the end
        //                        self.mugTextViews.append(mugTextView)
        //                    }
        //                }
        //
        //                self.delegate?.mugsTextsViewDidSplitMugText(self.mugTexts)
        //
        //                self.centerScrollViewAtView(splitMugTextView)
        //                self.delegate?.mugsTextsViewDidSelectMugText(splitMugTextView.mugText)
        //                ()})
        
    }
    
    // MARK: - ComposeBottomViewContainerDelegate Methods
    
    func composeBottomViewContainerDidTapCaptureAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.composeTopViewContainer.startRecordingProgressBar()
        })
        
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
        composeTopViewContainer.startRecordingProgressBar()
        composeTopViewContainer.captureVideo()
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
    
    func composeBottomViewContainer(composeBottomViewContainer: ComposeBottomViewContainer, didTapAtFlip flip: Mug) {
        let flipWord = flipWords[highlightedWordIndex]
        
        // Sometimes the saved flip has the word in a different case. So, we need to change it without override the saved one.
        flip.word = flipWord.text
        
        if (flipWord.associatedMug == nil) {
            flipWord.associatedMug = flip
            self.composeTopViewContainer.showFlip(flip)
        } else {
            if (flipWord.associatedMug.mugID == flip.mugID) {
                flipWord.associatedMug = nil
                self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
            } else {
                flipWord.associatedMug = flip
                self.composeTopViewContainer.showFlip(flip)
            }
        }
        self.updateFlipWordsState()
        self.flipMessageWordListView.reloadWords(animated: false) // Word state can change
        self.composeBottomViewContainer.reloadMyMugs() // Refresh selected state
    }
    
    
    // MARK: - ComposeBottomViewContainerDataSource
    
    func composeBottomViewContainerFlipsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [Mug] {
        let flipWord = flipWords[highlightedWordIndex]
        return myMugsDictionary[flipWord.text]!
    }
    
    func flipIdForHighlightedWord() -> String? {
        let flipWord = flipWords[highlightedWordIndex]
        if (flipWord.associatedMug != nil) {
            return flipWord.associatedMug.mugID
        }
        return nil
    }
    
    
    // MARK: - ComposeTopViewContainerDelegate
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, withSuccess success: Bool) {
        if (success) {
            let flipWord = flipWords[highlightedWordIndex]
            let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipVideo: url)
            self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
        } else {
            println("Did finish recording with success = false")
        }
    }
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, cameraAvailable available: Bool) {
        composeBottomViewContainer.setCameraButtonEnabled(available)
    }
    
    func composeTopViewContainerDidTapMicrophoneButton(composeTopViewContainer: ComposeTopViewContainer) {
        // Clean any previous image
        self.highlightedWordCurrentAssociatedImage = nil
        
        let flipWord = flipWords[highlightedWordIndex]
        composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
        composeBottomViewContainer.showAudioRecordButton()
    }
    
    
    // MARK: - Gallery control
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)  {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        self.highlightedWordCurrentAssociatedImage = image.cropImageInCenter()
        
        composeTopViewContainer.showImage(self.highlightedWordCurrentAssociatedImage!, andText: flipWord.text)
        composeBottomViewContainer.showAudioRecordButton()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Audio Recorder Service Delegate
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL fileURL: NSURL?, success: Bool!) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text,
            flipPicture: self.highlightedWordCurrentAssociatedImage,
            flipAudio: fileURL)
        
        confirmFlipViewController.delegate = self
        self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
    }
    
    
    // MARK: - ConfirmFlipViewController Delegate
    
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success: Bool, mug: Mug?) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        if (success) {
            flipWord.associatedMug = mug
            self.onMugAssociated()
        } else {
            self.composeTopViewContainer.showCameraWithWord(flipWord.text)
        }
    }
}