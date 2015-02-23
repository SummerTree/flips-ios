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

private let STOCK_FLIP_DOWNLOAD_FAILED_TITLE = NSLocalizedString("Download Failed", comment: "Download Failed")
private let STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE = NSLocalizedString("Flips failed to download content for the selected Flip. \nPlease try again.", comment: "Flips failed to download content for the selected Flip. \nPlease try again.")

private let NO_SPACE_VIDEO_ERROR_TITLE = "Cannot Record Video"
private let NO_SPACE_VIDEO_ERROR_MESSAGE = "There is not enough available storage to record video. You manage your storage in Settings."
private let NO_SPACE_PHOTO_ERROR_TITLE = "Cannot Take Photo"
private let NO_SPACE_PHOTO_ERROR_MESSAGE = "There is not enough available storage to take a photo. You manage your storage in Settings."

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
    private var stockFlipsDictionary: Dictionary<String, [String]>!
    
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
        
        findAndSaveStockFlips(words)
        
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
    
    private func findAndSaveStockFlips(words: [String]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let flipService = FlipService()
            flipService.stockFlipsForWords(words, success: { (responseAsJSON) -> Void in
                let stockFlipsAsJSON = responseAsJSON?.array
                for stockFlipJson in stockFlipsAsJSON! {
                    PersistentManager.sharedInstance.createOrUpdateFlipWithJsonAsync(stockFlipJson)
                }
            }, failure: { (flipError) -> Void in
                if (flipError != nil) {
                    println("Error \(flipError)")
                }
            })
        })
    }
    
    private func checkForPermissionToCaptureMedia() -> Bool {
        switch AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) {
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
            navigationController?.popViewControllerAnimated(true)
            return false
        case .Authorized:
            return true
        default:
            var title = NSLocalizedString("Flips")
            var message = NSLocalizedString("Flips doesn't have permission to use Camera, please change privacy settings")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
            
            navigationController?.popViewControllerAnimated(true)
            
            return false
        }
    }
    
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!self.checkForPermissionToCaptureMedia()) {
            return
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(self.composeTitle)
        self.setNeedsStatusBarAppearanceUpdate()
        
        if (self.shouldShowPreviewButton()) {
            var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview"), style: .Done, target: self, action: "previewButtonTapped:")
            previewBarButton.tintColor = UIColor.orangeColor()
            self.navigationItem.rightBarButtonItem = previewBarButton
        }
        
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
        
        composeBottomViewContainer?.updateGalleryButtonImage()
        
        composeTopViewContainer?.viewWillAppear()
        composeTopViewContainer?.delegate = self
        
        AudioRecorderService.sharedInstance.delegate = self
        
        self.shouldEnableUserInteraction(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        composeTopViewContainer?.viewWillDisappear()
        composeTopViewContainer?.delegate = nil
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
        if (self.flipWords.count == 0) {
            self.composeBottomViewContainer.showAllFlipCreateMessage()
            return
        }
        
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
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
            
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        })
    }
    
    private func showFlipCreatedState(flipId: String) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        
        self.composeTopViewContainer.showFlip(flipId, withWord: flipWord.text)
        if (self.canShowMyFlips()) {
            self.composeBottomViewContainer.showMyFlips()
        } else {
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
        self.stockFlipsDictionary = flipDataSource.getStockFlipsIdsForWords(words)
        
        for flipWord in self.flipWords {
            if let firstFlipId:String = self.myFlipsDictionary[flipWord.text]?.first {
                flipWord.associatedFlipId = firstFlipId
            }
        }
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
            composeTopViewContainer.showFlip(flipWord.associatedFlipId!, withWord: flipWord.text)
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
            
            self.delegate?.composeViewController?(self, didChangeFlipWords: flipWords.map { $0.text})
            
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
        AudioRecorderService.sharedInstance.startRecording { (error) -> Void in
            if let error = error {
                self.composeTopViewContainer.showCameraWithWord(self.flipWords[self.highlightedWordIndex].text)
                var alertMessage = UIAlertView(title: LocalizedString.MICROPHONE_ACCESS, message: LocalizedString.MICROPHONE_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertMessage.show()
            }
        }
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
            composeTopViewContainer.showFlip(flipWord.associatedFlipId!, withWord: flipWord.text)
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
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let flipDataSource = FlipDataSource()
            if let selectedFlip = flipDataSource.retrieveFlipWithId(flipId) {
                if (selectedFlip.isPrivate.boolValue) {
                    self.onFlipSelected(flipId)
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                } else {
                    let flipWord = self.flipWords[self.highlightedWordIndex]
                    if (flipWord.associatedFlipId == nil) {
                        let flipsCache = FlipsCache.sharedInstance
                        flipsCache.videoForFlip(selectedFlip,
                            success: { (localPath: String!) in
                                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                                self.onFlipSelected(flipId)
                            }, failure: { (error: FlipError) in
                                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    println("Downloading stock flip(id: \(flipId)) error: \(error)")
                                    let alertView = UIAlertView(title: STOCK_FLIP_DOWNLOAD_FAILED_TITLE, message: STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                                    alertView.show()
                                })
                        })
                    } else {
                        self.onFlipSelected(flipId)
                        ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                    }
                }
            } else {
                UIAlertView.showUnableToLoadFlip()
            }
        })
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
    
    func composeTopViewContainer(composeTopViewContainer: ComposeTopViewContainer, didFinishRecordingVideoAtUrl url: NSURL?, withSuccess success: Bool) {
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
        self.highlightedWordCurrentAssociatedImage = image.squareCrop(UIImageSource.Unknown)
        
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
        var flipImage = self.highlightedWordCurrentAssociatedImage
        
        let confirmFlipViewController = ConfirmFlipViewController(flipWord: flipWord.text, flipPicture: flipImage, flipAudio: fileURL)
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
    
    func confirmFlipViewController(confirmFlipViewController: ConfirmFlipViewController!, didFinishEditingWithSuccess success: Bool, flipID: String?) {
        let flipWord = self.flipWords[self.highlightedWordIndex]
        if (success) {
            flipWord.associatedFlipId = flipID
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

@objc protocol ComposeViewControllerDelegate {
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String)
    
    optional func composeViewController(viewController: ComposeViewController, didChangeFlipWords words: [String])
    
}