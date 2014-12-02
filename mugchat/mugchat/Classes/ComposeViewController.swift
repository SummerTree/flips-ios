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

private let GROUP_CHAT = NSLocalizedString("Group Chat", comment: "Group Chat")

class ComposeViewController : FlipsViewController, FlipMessageWordListViewDelegate, FlipMessageWordListViewDataSource, ComposeBottomViewContainerDelegate, ComposeBottomViewContainerDataSource, ComposeTopViewContainerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderServiceDelegate, ConfirmFlipViewControllerDelegate, PreviewViewControllerDelegate {
    
    private let NO_EMPTY_FLIP_INDEX = -1
    
    private let IPHONE_4S_TOP_CONTAINER_HEIGHT: CGFloat = 240.0
    private let FLIP_MESSAGE_WORDS_LIST_HEIGHT: CGFloat = 50.0
    
    private var composeTopViewContainer: ComposeTopViewContainer!
    private var flipMessageWordListView: FlipMessageWordListView!
    private var composeBottomViewContainer: ComposeBottomViewContainer!
    
    private var composeTitle: String!
    internal var flipWords: [FlipText]!
    
    internal var highlightedWordIndex: Int!
    
    private var myFlipsDictionary: Dictionary<String, [String]>!
    
    private var highlightedWordCurrentAssociatedImage: UIImage?
    
    private var contactIDs: [String]?
    private var roomID: String?
    
    internal var words: [String]!
    
    var delegate: ComposeViewControllerDelegate?
    
    
    // MARK: - Init Methods
    
    init(composeTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.composeTitle = composeTitle
        self.highlightedWordIndex = 0
    }
    
    init(composeTitle: String, words : [String]) {
        super.init(nibName: nil, bundle: nil)
        self.composeTitle = composeTitle
        self.words = words
        
        self.initFlipWords(words)
        
        self.highlightedWordIndex = 0
    }
    
    convenience init(contacts: [Contact], words: [String]) {
        var title = GROUP_CHAT
        
        if (contacts.count == 1) {
            if let contactTitle = contacts.first?.contactTitle {
                title = contactTitle
            }
        }
        
        self.init(composeTitle: title, words: words)
        
        self.contactIDs = Array<String>()
        for contact in contacts {
            self.contactIDs?.append(contact.contactID)
        }
    }
    
    convenience init(roomID: String, composeTitle: String, words: [String]) {
        self.init(composeTitle: composeTitle, words: words)
        self.roomID = roomID
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func initFlipWords(words: [String]) {
        myFlipsDictionary = Dictionary<String, [String]>()
        flipWords = Array()
        for (var i = 0; i < words.count; i++) {
            var word = words[i]
            var flipText: FlipText = FlipText(position: i, text: word, state: FlipState.NewWord)
            self.flipWords.append(flipText)
            myFlipsDictionary[word] = Array<String>()
        }
    }
    
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(self.composeTitle)
        
        if (self.shouldShowPreviewButton()) {
            var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
            previewBarButton.tintColor = UIColor.orangeColor()
            self.navigationItem.rightBarButtonItem = previewBarButton
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.addSubviews()
        self.addConstraints()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.reloadMyFlips()
            self.updateFlipWordsState()
            self.showContentForHighlightedWord()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        composeBottomViewContainer.updateGalleryButtonImage()
        composeTopViewContainer.viewWillAppear()
        AudioRecorderService.sharedInstance.delegate = self
        self.shouldEnableUserInteraction(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        composeTopViewContainer.viewWillDisappear()
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
        
        if (self.shouldShowPlusButtonInWords()) {
            flipMessageWordListView.showPlusButton()
        }
        
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
        var previewViewController: PreviewViewController
        if (contactIDs != nil) {
            previewViewController = PreviewViewController(flipWords: self.flipWords, contactIDs: self.contactIDs!)
        } else {
            previewViewController = PreviewViewController(flipWords: self.flipWords, roomID: self.roomID!)
        }
        
        previewViewController.delegate = self
        self.navigationController?.pushViewController(previewViewController, animated: true)
    }
    
    
    // MARK: - View States Setters
    
    internal func showContentForHighlightedWord(shouldReloadWords: Bool = true) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let flipWord = self.flipWords[self.highlightedWordIndex]
            
            if (flipWord.associatedFlipId != nil) {
                self.showFlipCreatedState(flipWord.associatedFlipId!)
            } else {
                let flipDataSource = FlipDataSource()
                let myFlips = flipDataSource.getMyFlipsForWord(flipWord.text)
                if (myFlips.count > 0) {
                    self.showNewFlipWithSavedFlipsForWord(flipWord.text)
                } else {
                    self.showNewFlipWithoutSavedFlipsForWord(flipWord.text)
                }
            }
            
            if (shouldReloadWords) {
                self.flipMessageWordListView.reloadWords()
            } else {
                self.flipMessageWordListView.updateWordState()
            }
            
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    private func showFlipCreatedState(flipId: String) {
        if (self.canShowMyFlips()) {
            self.composeTopViewContainer.showFlip(flipId)
            self.composeBottomViewContainer.showMyFlips()
        } else {
            self.composeTopViewContainer.showFlip(flipId)
            self.composeBottomViewContainer.showFlipCreateMessage()
        }
    }
    
    private func showNewFlipWithoutSavedFlipsForWord(word: String) {
        self.composeTopViewContainer.showCameraWithWord(word)
        self.composeBottomViewContainer.showCameraButtons()
    }
    
    private func showNewFlipWithSavedFlipsForWord(word: String) {
        if (self.canShowMyFlips()) {
            self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: word)
            self.composeBottomViewContainer.showMyFlips()
        } else {
            self.showNewFlipWithoutSavedFlipsForWord(word)
        }
    }
    
    
    // MARK: - Flips CoreData Loader
    
    internal func reloadMyFlips() {
        let flipDataSource = FlipDataSource()
        
        var words = Array<String>()
        for flipWord in self.flipWords {
            words.append(flipWord.text)
        }
        
        self.myFlipsDictionary = flipDataSource.getMyFlipsIdsForWords(words)
    }
    
    
    // MARK: - FlipWords Methods
    
    private func onFlipAssociated() {
        self.reloadMyFlips()
        self.updateFlipWordsState()
        self.moveToNextFlipWord()
    }
    
    internal func updateFlipWordsState() {
        for flipWord in flipWords {
            let word = flipWord.text
            let myFlipsForWord = myFlipsDictionary[word]
            
            if (flipWord.associatedFlipId == nil) {
                if (myFlipsForWord!.count == 0) {
                    flipWord.state = .NewWord
                } else {
                    flipWord.state = .NotAssociatedWithResources
                }
            } else {
                if (myFlipsForWord!.count == 1) {
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
            if (flipWord.associatedFlipId == nil) {
                return index
            }
            index++
        }
        return NO_EMPTY_FLIP_INDEX
    }
    
    private func moveToNextFlipWord() {
        let nextIndex = self.nextEmptyFlipWordIndex()
        if (nextIndex == NO_EMPTY_FLIP_INDEX) {
            self.showContentForHighlightedWord(shouldReloadWords: false)
            if (self.shouldShowPreviewButton()) {
                self.openPreview()
            } else {
                self.composeBottomViewContainer.showAllFlipCreateMessage()
            }
        } else {
            self.highlightedWordIndex = nextIndex
            let flipWord = self.flipWords[self.highlightedWordIndex]
            self.showContentForHighlightedWord(shouldReloadWords: false)
        }
    }
    
    
    // MARK: - FlipMessageWordListViewDataSource
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> FlipText {
        return flipWords[index]
    }
    
    func numberOfFlipWords() -> Int {
        return flipWords.count
    }
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int {
        return highlightedWordIndex
    }
    
    
    // MARK: - FlipMessageWordListViewDelegate
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSelectFlipWord flipWord: FlipText!) {
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
            if (self.canShowMyFlips()) {
                composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
                composeBottomViewContainer.showMyFlips()
            } else {
                composeTopViewContainer.showCameraWithWord(flipWord.text)
                composeBottomViewContainer.showCameraButtons()
            }
        case FlipState.AssociatedWithoutOtherResources, FlipState.AssociatedWithOtherResources:
            composeTopViewContainer.showFlip(flipWord.associatedFlipId!)
            if (self.canShowMyFlips()) {
                composeBottomViewContainer.showMyFlips()
            } else {
                composeBottomViewContainer.showFlipCreateMessage()
            }
        }
    }
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSplitFlipWord flipWord: FlipText!) {
        var splittedTextWords: [String] = FlipStringsUtil.splitFlipString(flipWord.text);
        
        var newFlipWords = Array<FlipText>()
        var flipWordsToAdd = Array<FlipText>()
        var position = 0
        if (splittedTextWords.count > 1) {
            for oldFlipWord in flipWords {
                if (flipWord.position == oldFlipWord.position) {
                    for newWord in splittedTextWords {
                        var newFlipWord = FlipText(position: position, text: newWord, state: FlipState.NewWord)
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
            
            self.reloadMyFlips()
            self.updateFlipWordsState()
            
            self.composeBottomViewContainer.reloadMyFlips() // Refresh selected state
            
            if (highlightedWordIndex == flipWord.position) {
                self.showContentForHighlightedWord(shouldReloadWords: false)
            }
            
            self.flipMessageWordListView.replaceFlipWord(flipWord, forFlipWords: flipWordsToAdd)
        }
    }
    
    func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView) {
        // DO NOTHING - the optional mark didn't work on this delegate because of the others methods' params
    }
    
    // MARK: - ComposeBottomViewContainerDelegate Methods
    
    func composeBottomViewContainerDidTapCaptureAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        AudioRecorderService.sharedInstance.startRecording()
    }
    
    func composeBottomViewContainerDidTapSkipAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipPicture: self.highlightedWordCurrentAssociatedImage, flipAudio: nil)
        confirmFlipViewController.title = self.composeTitle
        confirmFlipViewController.showPreviewButton = self.shouldShowPreviewButton()
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
    
    func composeBottomViewContainerWillOpenMyFlipsView(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        
        if (flipWord.associatedFlipId != nil) {
            composeTopViewContainer.showFlip(flipWord.associatedFlipId!)
        } else {
            composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
        }
        composeBottomViewContainer.reloadMyFlips()
    }
    
    func composeBottomViewContainerWillOpenCameraControls(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        composeTopViewContainer.showCameraWithWord(flipWord.text)
    }
    
    func composeBottomViewContainerDidTapGalleryButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            var imagePickerController = UIImagePickerControllerWithLightStatusBar()
            var textAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            imagePickerController.navigationBar.barTintColor = UIColor.flipOrange()
            imagePickerController.navigationBar.translucent = false
            imagePickerController.navigationBar.tintColor = UIColor.whiteColor()
            imagePickerController.navigationBar.titleTextAttributes = textAttributes
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePickerController.allowsEditing = false
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func composeBottomViewContainer(composeBottomViewContainer: ComposeBottomViewContainer, didTapAtFlipWithId flipId: String) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        
        if (flipWord.associatedFlipId == nil) {
            flipWord.associatedFlipId = flipId
            self.composeTopViewContainer.showFlip(flipId)
        } else {
            if (flipWord.associatedFlipId == flipId) {
                flipWord.associatedFlipId = nil
                self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
            } else {
                flipWord.associatedFlipId = flipId
                self.composeTopViewContainer.showFlip(flipId)
            }
        }
        self.updateFlipWordsState()
        
        self.flipMessageWordListView.reloadWords(animated: false) // Word state can change
        self.composeBottomViewContainer.reloadMyFlips() // Refresh selected state
    }
    
    
    // MARK: - ComposeBottomViewContainerDataSource
    
    func composeBottomViewContainerFlipIdsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [String] {
        let flipWord = flipWords[highlightedWordIndex]
        return myFlipsDictionary[flipWord.text]!
    }
    
    func flipIdForHighlightedWord() -> String? {
        let flipWord = flipWords[highlightedWordIndex]
        if (flipWord.associatedFlipId != nil) {
            return flipWord.associatedFlipId
        }
        return nil
    }
    
    func composeBottomViewContainerCanShowMyFlipsButton(composeBottomViewContainer: ComposeBottomViewContainer) -> Bool {
        return self.canShowMyFlips()
    }
    
    
    // MARK: - ComposeTopViewContainerDelegate
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, withSuccess success: Bool) {
        if (success) {
            let flipWord = flipWords[highlightedWordIndex]
            let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipVideo: url)
            confirmFlipViewController.title = self.composeTitle
            confirmFlipViewController.delegate = self
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
    
    func enableUserInteractionWithComposeView(enable: Bool) {
        self.shouldEnableUserInteraction(enable)
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
    
    // MARK: User Interaction Methods
    
    func shouldEnableUserInteraction(enabled: Bool) {
        if enabled {
            self.view.userInteractionEnabled = true
            self.navigationController?.view.userInteractionEnabled = true
            println("User interaction enabled for compose view")
        } else {
            self.view.userInteractionEnabled = false
            self.navigationController?.view.userInteractionEnabled = false
            println("User interaction disabled for compose view")
        }
    }
    
    
    // MARK: - Audio Recorder Service Delegate
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL fileURL: NSURL?, success: Bool!) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text,
            flipPicture: self.highlightedWordCurrentAssociatedImage,
            flipAudio: fileURL)
        
        confirmFlipViewController.delegate = self
        confirmFlipViewController.title = self.composeTitle
        self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
    }
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didRequestRecordPermission: Bool) {
        if (didRequestRecordPermission) {
            self.composeTopViewContainer.startRecordingProgressBar()
        }
    }
    
    func audioRecorderServiceDidFinishPlaying(audioRecorderService: AudioRecorderService!) {
        self.shouldEnableUserInteraction(true)
    }
    
    
    // MARK: - ConfirmFlipViewController Delegate
    
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success: Bool, flip: Flip?) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        if (success) {
            flipWord.associatedFlipId = flip?.flipID
            self.onFlipAssociated()
        } else {
            self.composeTopViewContainer.showCameraWithWord(flipWord.text)
        }
    }
    
    
    // MARK: - Internal Methods (methods to be overriden by Builder
    
    func shouldShowPreviewButton() -> Bool {
        return true
    }
    
    func canShowMyFlips() -> Bool {
        return true
    }
    
    func shouldShowPlusButtonInWords() -> Bool {
        return false
    }
    
    
    // MARK: - PreviewViewControllerDelegate

    func previewViewController(viewController: PreviewViewController, didSendMessageToRoom roomID: String) {
        delegate?.composeViewController(self, didSendMessageToRoom: roomID)
    }
}

protocol ComposeViewControllerDelegate {
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String)

}