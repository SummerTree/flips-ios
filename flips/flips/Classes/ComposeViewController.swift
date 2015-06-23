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

import Foundation

private let GROUP_CHAT = NSLocalizedString("Group Chat", comment: "Group Chat")

private let STOCK_FLIP_DOWNLOAD_FAILED_TITLE = NSLocalizedString("Download Failed", comment: "Download Failed")
private let STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE = NSLocalizedString("Flips failed to download content for the selected Flip. \nPlease try again.", comment: "Flips failed to download content for the selected Flip. \nPlease try again.")

private let NO_SPACE_VIDEO_ERROR_TITLE = "Cannot Record Video"
private let NO_SPACE_VIDEO_ERROR_MESSAGE = "There is not enough available storage to record video. You manage your storage in Settings."
private let NO_SPACE_PHOTO_ERROR_TITLE = "Cannot Take Photo"
private let NO_SPACE_PHOTO_ERROR_MESSAGE = "There is not enough available storage to take a photo. You manage your storage in Settings."

class ComposeViewController : FlipsViewController, FlipMessageWordListViewDelegate, FlipMessageWordListViewDataSource, ComposeBottomViewContainerDelegate, ComposeBottomViewContainerDataSource, ComposeTopViewContainerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioRecorderServiceDelegate, ConfirmFlipViewControllerDelegate, PreviewViewControllerDelegate {
    
    private let NO_FLIP_SELECTED_INDEX = -1
    
    private let IPHONE_4S_TOP_CONTAINER_HEIGHT: CGFloat = 240.0
    private let FLIP_MESSAGE_WORDS_LIST_HEIGHT: CGFloat = 50.0
    
    private let MILLISECONDS_UNTIL_RECORDING_SESSION_IS_REALLY_DONE: UInt64 = 300
    
    internal var composeTopViewContainer: ComposeTopViewContainer!
    internal var flipMessageWordListView: FlipMessageWordListView!
    internal var composeBottomViewContainer: ComposeBottomViewContainer!
    
    private var composeTitle: String!
    internal var flipWords: [FlipText]!
    
    internal var highlightedWordIndex: Int!
    
    internal var myFlipsDictionary: Dictionary<String, [String]>!
    private var stockFlipsDictionary: Dictionary<String, [String]>!
    
    weak private var highlightedWordCurrentAssociatedImage: UIImage?
    
    private var contactIDs: [String]?
    private var roomID: String?
    
    internal var words: [String]!
    
    weak var delegate: ComposeViewControllerDelegate?
    
    var audioRecorder: AudioRecorderService?
    
    // analytics state flags
    private var fromVideo: Bool = false
    private var fromPicture: Bool = false
    private var fromFrontCamera: Bool = false
    private var fromCameraRoll: Bool = false
    private var fromAudio: Bool = false
    private var inLandspace: Bool = false
    
    // MARK: - Init Methods
    
    init(composeTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.composeTitle = composeTitle
        self.highlightedWordIndex = 0
    }
    
    init(composeTitle: String, words: [String]) {
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
        stockFlipsDictionary = Dictionary<String, [String]>()
        
        flipWords = Array()
        for (var i = 0; i < words.count; i++) {
            var word = words[i]
            var flipText: FlipText = FlipText(position: i, text: word, state: FlipState.NotAssociatedAndNoResourcesAvailable)
            self.flipWords.append(flipText)
            myFlipsDictionary[word] = Array<String>()
            stockFlipsDictionary[word] = Array<String>()
        }
    }

    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(self.composeTitle)
        self.setNeedsStatusBarAppearanceUpdate()
        
        if (self.shouldShowPreviewButton()) {
            var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview"), style: .Done, target: self, action: "previewButtonTapped:")
            previewBarButton.tintColor = UIColor.flipOrange()
            self.navigationItem.rightBarButtonItem = previewBarButton
        }
        
        self.addSubviews()
        self.addConstraints()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.reloadMyFlips()
            self.mapWordsToFirstAvailableFlip()
            self.updateFlipWordsState()
            self.showContentForHighlightedWord()
        })

        self.shouldEnableUserInteraction(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        composeBottomViewContainer?.updateGalleryButtonImage()
        
        composeTopViewContainer?.viewWillAppear()
        composeTopViewContainer?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        composeTopViewContainer?.viewWillDisappear()
        composeTopViewContainer?.delegate = nil

        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as! UIView
        
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
        if (self.flipWords.count == 0) {
            self.composeBottomViewContainer.showAllFlipCreateMessage()
            return
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let flipWord = self.flipWords[self.highlightedWordIndex]
            
            if (flipWord.associatedFlipId != nil) {
                self.showFlipCreatedState(flipWord.associatedFlipId!)
            } else {
                let flipDataSource = FlipDataSource()
                let myFlips = flipDataSource.getMyFlipsForWord(flipWord.text)
                let stockFlips = flipDataSource.getStockFlipsForWord(flipWord.text)
                let numberOfFlips = myFlips.count + stockFlips.count
                
                if (numberOfFlips > 0) {
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
        })
    }

    private func showFlipCreatedState(flipId: String) {
        let flipWord = self.flipWords[self.highlightedWordIndex]

        if (self.canShowMyFlips()) {
            self.composeBottomViewContainer.showMyFlips()
        } else {
            self.showNewFlipWithoutSavedFlipsForWord(flipWord.text)
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
        self.stockFlipsDictionary = flipDataSource.getStockFlipsIdsForWords(words)
    }

    private func mapWordsToFirstAvailableFlip() {
        for flipWord in self.flipWords {
            if let firstFlipId:String = self.myFlipsDictionary[flipWord.text]?.first {
                flipWord.associatedFlipId = firstFlipId
            }
        }
    }
    
    
    // MARK: - FlipWords Methods
    
    func onFlipAssociated() {
        self.reloadMyFlips()
        self.updateFlipWordsState()
        self.moveToNextFlipWord()
    }
    
    internal func updateFlipWordsState() {
        for flipWord in flipWords {
            let word = flipWord.text
            let myFlipsForWord = myFlipsDictionary[word]
            let stockFlipsForWord = stockFlipsDictionary[word]
            
            let numberOfFlipsForWord = myFlipsForWord!.count + stockFlipsForWord!.count
            
            if (flipWord.associatedFlipId == nil) {
                if (numberOfFlipsForWord == 0) {
                    flipWord.state = .NotAssociatedAndNoResourcesAvailable
                } else {
                    flipWord.state = .NotAssociatedButResourcesAvailable
                }
            } else {
                if (numberOfFlipsForWord == 1) {
                    flipWord.state = .AssociatedAndNoResourcesAvailable
                } else {
                    flipWord.state = .AssociatedAndResourcesAvailable
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
        return NO_FLIP_SELECTED_INDEX
    }
    
    internal func moveToNextFlipWord() {
        let nextIndex = self.nextEmptyFlipWordIndex()
        if (nextIndex == NO_FLIP_SELECTED_INDEX) {
            if (self.shouldShowPreviewButton()) {
                let oneSecond = 0.5 * Double(NSEC_PER_SEC)
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
                dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                    self.openPreview()
                }
            } else {
                self.composeBottomViewContainer.showAllFlipCreateMessage()
            }
        } else {
            self.highlightedWordIndex = nextIndex
        }
        
        self.showContentForHighlightedWord(shouldReloadWords: !self.canShowMyFlips())
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
        self.highlightedWordIndex = flipWord.position
        
        highlightedWordCurrentAssociatedImage = nil
        
        var status : FlipState = flipWord.state
        switch status {
        case FlipState.NotAssociatedAndNoResourcesAvailable:
            composeTopViewContainer.showCameraWithWord(flipWord.text)
            composeBottomViewContainer.showCameraButtons()
        case FlipState.NotAssociatedButResourcesAvailable:
            if (self.canShowMyFlips()) {
                composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
                composeBottomViewContainer.showMyFlips()
            } else {
                composeTopViewContainer.showCameraWithWord(flipWord.text)
                composeBottomViewContainer.showCameraButtons()
            }
        case FlipState.AssociatedAndNoResourcesAvailable, FlipState.AssociatedAndResourcesAvailable:
            self.showContentForHighlightedWord(shouldReloadWords: false)
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
                        var newFlipWord = FlipText(position: position, text: newWord, state: FlipState.NotAssociatedAndNoResourcesAvailable)
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
            
            self.delegate?.composeViewController?(self, didChangeFlipWords: flipWords.map { $0.text })
            
            self.reloadMyFlips()
            self.updateFlipWordsState()
            
            self.composeBottomViewContainer.reloadMyFlips() // Refresh selected state
            
            if (highlightedWordIndex == flipWord.position) {
                self.showContentForHighlightedWord(shouldReloadWords: false)
            }
            
            self.flipMessageWordListView.reloadWords(animated: true)
        }
    }
    
    func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView) {
        // DO NOTHING - the optional mark didn't work on this delegate because of the others methods' params
    }
    
    // MARK: - ComposeBottomViewContainerDelegate Methods
    
    func composeBottomViewContainerDidTapCaptureAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        self.audioRecorder = AudioRecorderService()
        if let recorder = self.audioRecorder {
            recorder.delegate = self
            recorder.startRecording { (error) -> Void in
                if let error = error {
                    self.composeTopViewContainer.showCameraWithWord(self.flipWords[self.highlightedWordIndex].text)
                    var alertMessage = UIAlertView(title: LocalizedString.MICROPHONE_ACCESS, message: LocalizedString.MICROPHONE_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                    alertMessage.show()
                }
            }
        }
    }
    
    func composeBottomViewContainerDidTapSkipAudioButton(composeBottomViewContainer: ComposeBottomViewContainer) {
        self.hideAudioRecordingView()
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
        composeTopViewContainer.capturePictureWithCompletion({ (image, fromFrontCamera, inLandscape) -> Void in
            if (image != nil) {
                let receivedImage = image as UIImage!
                self.highlightedWordCurrentAssociatedImage = receivedImage
                let flipWord = self.flipWords[self.highlightedWordIndex]
                
                self.fromPicture = true
                self.fromFrontCamera = fromFrontCamera
                self.inLandspace = inLandscape
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.rightBarButtonItem?.enabled = false

                    self.composeTopViewContainer.showImage(receivedImage, andText: flipWord.text)
                    self.showAudioRecordingView()
                })
            } else {
                println("Capturing picture problem. Image is nil")
                var alertMessage = UIAlertView(title: NO_SPACE_PHOTO_ERROR_TITLE, message: NO_SPACE_PHOTO_ERROR_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertMessage.show()
            }
            }, fail: { (error) -> Void in
                println("Error capturing picture: \(error)")
                var alertMessage = UIAlertView(title: LocalizedString.ERROR, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertMessage.show()
        })
    }
    
    func composeBottomViewContainerWillOpenMyFlipsView(composeBottomViewContainer: ComposeBottomViewContainer) {
        let flipWord = flipWords[highlightedWordIndex]
        
        if (flipWord.associatedFlipId != nil) {
            var autoPlay = (self.navigationController?.topViewController == self)
            composeTopViewContainer.showFlip(flipWord.associatedFlipId!, withWord: flipWord.text, autoPlay: autoPlay);
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let flipDataSource = FlipDataSource()
            if let selectedFlip = flipDataSource.retrieveFlipWithId(flipId) {
                if (selectedFlip.isPrivate.boolValue) {
                    self.onFlipSelected(flipId)
                } else {
                    let flipWord = self.flipWords[self.highlightedWordIndex]
                    if (flipWord.associatedFlipId == nil) {
                        let flipsCache = FlipsCache.sharedInstance
                        flipsCache.get(NSURL(string: selectedFlip.backgroundURL)!,
                            success: { (url: String!, localPath: String!) in
                                self.onFlipSelected(flipId)
                            }, failure: { (url: String!, error: FlipError) in
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    println("Downloading stock flip(id: \(flipId)) error: \(error)")
                                    let alertView = UIAlertView(title: STOCK_FLIP_DOWNLOAD_FAILED_TITLE, message: STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                                    alertView.show()
                                })
                            },
                            progress: nil
                        )
                    } else {
                        self.onFlipSelected(flipId)
                    }
                }
            } else {
                UIAlertView.showUnableToLoadFlip()
            }
        })
    }
    
    private func showAudioRecordingView() {
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.flipMessageWordListView.setEnabled(false)
        self.composeBottomViewContainer.showAudioRecordButton()
    }
    
    private func hideAudioRecordingView() {
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.flipMessageWordListView.setEnabled(true)
        self.composeBottomViewContainer.hideRecordingView()
    }
    
    private func onFlipSelected(flipId: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let flipWord = self.flipWords[self.highlightedWordIndex]
            
            if (flipWord.associatedFlipId == nil) {
                flipWord.associatedFlipId = flipId
                self.composeTopViewContainer.showFlip(flipId, withWord: flipWord.text)
            } else {
                if (flipWord.associatedFlipId == flipId) {
                    flipWord.associatedFlipId = nil
                    self.composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
                } else {
                    flipWord.associatedFlipId = flipId
                    self.composeTopViewContainer.showFlip(flipId, withWord: flipWord.text)
                }
            }
            self.updateFlipWordsState()
            
            self.flipMessageWordListView.reloadWords(animated: false) // Word state can change
            self.composeBottomViewContainer.reloadMyFlips() // Refresh selected state
        })
    }

    // MARK: - ComposeBottomViewContainerDataSource
    
    func composeBottomViewContainerFlipIdsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [String] {
        if (flipWords.count == 0) {
            return Array<String>()
        }
        
        let flipWord = flipWords[highlightedWordIndex]
        return myFlipsDictionary[flipWord.text]!
    }
    
    func composeBottomViewContainerStockFlipIdsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [String] {
        if (flipWords.count == 0) {
            return Array<String>()
        }
        
        let flipWord = flipWords[highlightedWordIndex]
        return stockFlipsDictionary[flipWord.text]!
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
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, inLandscape landscape: Bool, fromFrontCamera frontCamera: Bool, withSuccess success: Bool) {
        if (success) {
            let flipWord = flipWords[highlightedWordIndex]
            let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipVideo: url)
            confirmFlipViewController.title = self.composeTitle
            confirmFlipViewController.delegate = self
            self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
        } else {
            var alertMessage = UIAlertView(title: NO_SPACE_VIDEO_ERROR_TITLE, message: NO_SPACE_VIDEO_ERROR_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
        }
        
        self.fromVideo = true
        self.fromFrontCamera = frontCamera
        self.inLandspace = landscape
    }
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, cameraAvailable available: Bool) {
        composeBottomViewContainer.setCameraButtonEnabled(available)
    }
    
    func composeTopViewContainerDidTapMicrophoneButton(composeTopViewContainer: ComposeTopViewContainer) {
        // Clean any previous image
        self.highlightedWordCurrentAssociatedImage = nil
        
        let flipWord = flipWords[highlightedWordIndex]
        composeTopViewContainer.showImage(UIImage.emptyFlipImage(), andText: flipWord.text)
        self.showAudioRecordingView()
    }
    
    func enableUserInteractionWithComposeView(enable: Bool) {
        self.shouldEnableUserInteraction(enable)
    }
    
    // MARK: - Gallery control
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)  {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        let croppedImage = image.cropSquareThumbnail()
        self.highlightedWordCurrentAssociatedImage = croppedImage
        
        composeTopViewContainer.showImage(self.highlightedWordCurrentAssociatedImage!, andText: flipWord.text)
        self.showAudioRecordingView()
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.fromCameraRoll = true
    }
    
    // MARK: User Interaction Methods
    
    func shouldEnableUserInteraction(enabled: Bool) {
        if enabled {
            self.view.userInteractionEnabled = true
            self.navigationController?.view.userInteractionEnabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true

            println("User interaction enabled for compose view")
        } else {
            self.view.userInteractionEnabled = false
            self.navigationController?.view.userInteractionEnabled = false
            self.navigationItem.rightBarButtonItem?.enabled = false

            println("User interaction disabled for compose view")
        }
    }
    
    
    // MARK: - Audio Recorder Service Delegate
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL fileURL: NSURL?, success: Bool!) {
        self.audioRecorder = nil
        
        let time = MILLISECONDS_UNTIL_RECORDING_SESSION_IS_REALLY_DONE * NSEC_PER_MSEC
        let delayInMilliseconds = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        dispatch_after(delayInMilliseconds, dispatch_get_main_queue()) { () -> Void in            
            let flipWord = self.flipWords[self.highlightedWordIndex]
            var flipImage = self.highlightedWordCurrentAssociatedImage
            
            let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipPicture: flipImage, flipAudio: fileURL)
            confirmFlipViewController.delegate = self
            confirmFlipViewController.title = self.composeTitle
            self.navigationController?.pushViewController(confirmFlipViewController, animated: false)
            self.hideAudioRecordingView()
        }
        
        self.fromAudio = true
    }
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didRequestRecordPermission: Bool) {
        if (didRequestRecordPermission) {
            self.composeTopViewContainer.startRecordingProgressBar()
        }
    }
    
    
    // MARK: - ConfirmFlipViewController Delegate
    
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success: Bool, flipID: String?) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        if (success) {
            flipWord.associatedFlipId = flipID
            self.onFlipAssociated()
            
            AnalyticsService.logFlipCreated(self.fromVideo, fromPicture: self.fromPicture, fromBackCamera: (self.fromPicture && !self.fromFrontCamera), fromFrontCamera: self.fromFrontCamera, fromCameraRoll: self.fromCameraRoll, fromAudio: self.fromAudio, inLandscape: self.fromAudio)
        } else {
            self.composeTopViewContainer.showCameraWithWord(flipWord.text)
            self.composeBottomViewContainer.showCameraButtons()
            
            AnalyticsService.logFlipRejected(self.fromVideo, fromPicture: self.fromPicture, fromBackCamera: (self.fromPicture && !self.fromFrontCamera), fromFrontCamera: self.fromFrontCamera, fromCameraRoll: self.fromCameraRoll, fromAudio: self.fromAudio, inLandscape: self.fromAudio)
        }
        
        self.fromVideo = false
        self.fromPicture = false
        self.fromFrontCamera = false
        self.fromCameraRoll = false
        self.fromAudio = false
        self.inLandspace = false
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

@objc protocol ComposeViewControllerDelegate {
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String)
    
    optional func composeViewController(viewController: ComposeViewController, didChangeFlipWords words: [String])
    
}