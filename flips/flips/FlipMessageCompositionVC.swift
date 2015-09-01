//
//  FlipMessageCompositionVC.swift
//  flips
//
//  Created by Taylor Bell on 8/28/15.
//
//

import Foundation

private let STOCK_FLIP_DOWNLOAD_FAILED_TITLE = NSLocalizedString("Download Failed", comment: "Download Failed")
private let STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE = NSLocalizedString("Flips failed to download content for the selected Flip. \nPlease try again.", comment: "Flips failed to download content for the selected Flip. \nPlease try again.")

private let MILLISECONDS_UNTIL_RECORDING_SESSION_IS_REALLY_DONE: UInt64 = 300

private let NO_SPACE_VIDEO_ERROR_TITLE = "Cannot Record Video"
private let NO_SPACE_VIDEO_ERROR_MESSAGE = "There is not enough available storage to record video. You manage your storage in Settings."

private let NO_SPACE_PHOTO_ERROR_TITLE = "Cannot Take Photo"
private let NO_SPACE_PHOTO_ERROR_MESSAGE = "There is not enough available storage to take a photo. You manage your storage in Settings."

class FlipMessageCompositionVC : FlipsViewController, FlipsCompositionViewDataSource, FlipsCompositionControlsDelegate, FlipMessageWordListViewDelegate, FlipsCompositionViewDelegate, CameraViewDelegate, AudioRecorderServiceDelegate, PreviewViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Title
    private var compositionTitle : String!
    
    // Contact
    internal var roomID : String!
    internal var contacts : [Contact]!
    internal var contactIDs : [String]!
    
    // Sending Options
    private var sendingOptions : [FlipsSendButtonOption]!
    
    // Flip Words Manager
    private var flipMessageManager : FlipMessageManager!
    
    // Audio Recorder Service
    private var flipAudioRecorder : AudioRecorderService!
    
    // UI
    private var flipCompositionView : FlipsCompositionView!
    private var flipControlsView : FlipsCompositionControlsView!
    private var flipMessageWordListView : FlipMessageWordListView!
    
    // ComposeViewControllerDelegate
    weak var delegate : FlipsCompositionControllerDelegate?
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(compositionTitle: String, words: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.compositionTitle = compositionTitle
        self.flipMessageManager = FlipMessageManager(words: words, draftingTable: self.draftingTable)
    }
    
    convenience init(compositionTitle: String) {
        self.init(compositionTitle: compositionTitle, words: Array<String>())
    }
    
    convenience init(roomID: String, compositionTitle: String, words: [String]) {
        self.init(compositionTitle: compositionTitle, words: words)
        self.roomID = roomID
    }
    
    convenience init(contacts: [Contact], words: [String]) {
        
        var title = "Group Chat"
        
        if (contacts.count == 1) {
            if let contactTitle = contacts.first?.contactTitle {
                title = contactTitle
            }
        }
        
        self.init(compositionTitle: title, words: words)
        
        contactIDs = contacts.map({ return $0.contactID })
        
    }
    
    convenience init(sendOptions: [FlipsSendButtonOption], contacts: [Contact], words: [String]) {
        self.init(contacts: contacts, words: words)
        self.sendingOptions = sendOptions
    }
    
    convenience init(sendOptions: [FlipsSendButtonOption], roomID: String, compositionTitle: String, words: [String]) {
        self.init(roomID: roomID, compositionTitle: compositionTitle, words: words)
        self.sendingOptions = sendOptions
    }
    
    
    
    ////
    // MARK: - Status Bar
    ////
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    
    
    ////
    // MARK: - Lifecycle
    ////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.setupWhiteNavBarWithBackButton(self.compositionTitle)
        self.setNeedsStatusBarAppearanceUpdate()
        
        let previewButton = UIBarButtonItem(title: NSLocalizedString("Preview"), style: .Done, target: self, action: "previewButtonTapped:")
        previewButton.tintColor = UIColor.flipOrange()
        self.navigationItem.rightBarButtonItem = previewButton
        
        initSubviews()
        initConstraints()
        initFlips()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.flipCompositionView.viewWillAppear()
        self.flipCompositionView.cameraViewDelegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.flipCompositionView.cameraViewDelegate = nil
        self.flipCompositionView.viewWillDissapear()
        super.viewWillDisappear(animated)
    }
    
    
    
    ////
    // MARK: - Content Initialization
    ////
    
    private func initSubviews() {
        
        flipCompositionView = FlipsCompositionView()
        flipCompositionView.delegate = self
        flipCompositionView.dataSource = self
        self.view.addSubview(flipCompositionView)
        
        flipMessageWordListView = FlipMessageWordListView()
        flipMessageWordListView.delegate = self
        flipMessageWordListView.dataSource = self.flipMessageManager
        self.view.addSubview(flipMessageWordListView)
        
        flipControlsView = FlipsCompositionControlsView()
        flipControlsView.delegate = self
        flipControlsView.dataSource = self.flipMessageManager
        self.view.addSubview(flipControlsView)
        
    }
    
    private func initConstraints() {
        
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as! UIView
        
        flipCompositionView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(self.view.mas_width)
        }
        
        flipMessageWordListView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipCompositionView.mas_bottom)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.height.equalTo()(50)
        }
        
        flipControlsView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.flipMessageWordListView.mas_bottom)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
        }
        
    }
    
    private func initFlips() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.flipMessageManager.reloadFlips()
            self.flipMessageManager.matchFlipWordsToFirstAvailableFlip()
            self.flipMessageManager.updateFlips()
            
            let nextEmptyIndex = self.flipMessageManager.getIndexForNextEmptyFlipWord()
            
            if self.flipMessageManager.currentFlipWordHasContent() {
                self.flipMessageManager.setCurrentFlipWordIndex(nextEmptyIndex)
            }
            
            self.updateViewForCurrentFlipWord()
            
        })
        
    }
    
    
    
    ////
    // MARK: - UI Updates
    ////
    
    internal func updateViewForCurrentFlipWord(reloadWords: Bool = true) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if (self.flipMessageManager.currentFlipWordHasContent())
            {
                self.flipControlsView.showEditControls()
                self.flipControlsView.scrollToDeleteButton()
            }
            else
            {
                self.flipControlsView.showCaptureControls()
                self.flipControlsView.scrollToVideoButton()
            }
            
            self.flipCompositionView.refresh()
            self.flipCompositionView.scrollToIndex(self.flipMessageManager.getCurrentFlipWordIndex())
            
            self.flipMessageWordListView.reloadWords(animated: false)
            
        })
        
    }
    
    
    
    ////
    // MARK: - Flip Word Scrolling
    ////
    
    internal func moveToNextEmptyFlipWord() {
        moveToFlipWordAtIndex(flipMessageManager.getIndexForNextEmptyFlipWord())
    }
    
    internal func moveToFlipWordAtIndex(index: Int) {
        
        if flipMessageManager.shouldCreateFlipForCurrentWord() {
            createFlipVideo()
        }
        
        // Move to the flip word at index
        flipMessageManager.setCurrentFlipWordIndex(index)
        
        // Reload the views
        updateViewForCurrentFlipWord()
        
    }
    
    
    
    ////
    // MARK: - Flip Assignment
    ////
    
    internal func assignFlip(flip: Flip, toFlipWord flipWord: FlipText) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if flipWord.associatedFlipId != flip.flipID
            {
                self.flipMessageManager.setCurrentFlipWordFlip(flip)
            }
            else
            {
                self.flipMessageManager.resetCurrentFlipWord()
            }
            
            self.updateViewForCurrentFlipWord()
            
        })
        
    }
    
    
    
    ////
    // MARK: - Flip Video Creation
    ////
    
    private func createFlipVideo() {
        
        let flipWord = flipMessageManager.getCurrentFlipWord()
        
        flipMessageManager.createFlipVideoForCurrentWord({ (videoURL, thumbnailURL) -> Void in
            
            if let videoURL = videoURL, let thumbnailURL = thumbnailURL
            {
                self.didCreateFlipVideo(videoURL, withThumbnail: thumbnailURL, forFlipWord: flipWord)
            }
            else
            {
                UIAlertView(title: "Failed", message: NSLocalizedString("Flips couldn't create your flip now. Please try again"), delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
            }
            
        })
        
    }
    
    private func didCreateFlipVideo(videoURL: NSURL?, withThumbnail thumbnailURL: NSURL?, forFlipWord flipWord: FlipText) {
        
        let newFlipPage = FlipPage(videoURL: videoURL!, thumbnailURL: thumbnailURL!, word: flipWord.text, order: flipWord.position)
        self.flipMessageManager.updateFlipPage(newFlipPage)
        
        // Update the UI
        self.updateViewForCurrentFlipWord()
        
    }
    
    
    
    ////
    // MARK: - FlipsCompositionViewDelegate
    ////
    
    func didPressRecordAudioButton() {
        
        self.view.userInteractionEnabled = false
        
        flipAudioRecorder = AudioRecorderService()
        
        if let recorder = flipAudioRecorder
        {
            recorder.delegate = self
            recorder.startManualRecording({ (error) -> Void in
                
                if let error = error
                {
                    self.view.userInteractionEnabled = true
                    
                    self.flipCompositionView.showAudioButton(true)
                    
                    UIAlertView(title: LocalizedString.MICROPHONE_ACCESS, message: LocalizedString.MICROPHONE_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
                }
                
            })
        }
        
    }
    
    func didReleaseRecordAudioButton() {
        flipAudioRecorder.stopRecording()
    }
    
    func didScrollToFlipAtIndex(index: Int) {
        moveToFlipWordAtIndex(index)
    }
    
    func didSwipeAwayFlipAtIndex(index: Int) {
        
        // Clear the current FlipText and FlipPage
        flipMessageManager.resetFlipWordAtIndex(flipMessageManager.getCurrentFlipWordIndex())
        
        // Update the UI
        updateViewForCurrentFlipWord()
        
    }
    
    
    
    ////
    // MARK: - FlipsCompositionControlsDelegate
    ////
    
    func didSelectStockFlipAtIndex(index: Int) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            let flipDataSource = FlipDataSource()
            let flipWord = self.flipMessageManager.getCurrentFlipWord()
            let userFlips = self.flipMessageManager.getUserFlipsForWord(flipWord)
            let flipID = userFlips[index]
            
            if let selectedFlip = flipDataSource.retrieveFlipWithId(flipID)
            {
                if flipWord.associatedFlipId != selectedFlip.flipID
                {
                    let flipsCache = FlipsCache.sharedInstance
                    let flipURL = NSURL(string: selectedFlip.backgroundURL)
                    
                    flipsCache.get(flipURL!,
                        success: { (url: String!, localPath: String!) -> Void in
                            
                            self.assignFlip(selectedFlip, toFlipWord: flipWord)
                        
                        },
                        failure: { (url: String!, error: FlipError) -> Void in
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                println("Downloading stock flip(id: \(selectedFlip.flipID)) error: \(error)")
                                
                                UIAlertView(title: STOCK_FLIP_DOWNLOAD_FAILED_TITLE, message: STOCK_FLIP_DOWNLOAD_FAILED_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
                                
                            })
                        
                        },
                        progress: nil
                    )
                }
                else
                {
                    self.assignFlip(selectedFlip, toFlipWord: flipWord)
                }
            }
            else
            {
                UIAlertView.showUnableToLoadFlip()
            }
            
        })
        
    }
    
    func didSelectFlipAtIndex(index: Int) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            let flipDataSource = FlipDataSource()
            let flipWord = self.flipMessageManager.getCurrentFlipWord()
            let userFlips = self.flipMessageManager.getUserFlipsForWord(flipWord)
            let flipID = userFlips[index]
            
            if let selectedFlip = flipDataSource.retrieveFlipWithId(flipID)
            {
                self.assignFlip(selectedFlip, toFlipWord: flipWord)
            }
            else
            {
                UIAlertView.showUnableToLoadFlip()
            }
            
        })
        
    }
    
    func didPressVideoButton() {
        flipCompositionView.userInteractionEnabled = false
        flipCompositionView.startVideoCapture()
    }
    
    func didReleaseVideoButton() {
        flipCompositionView.finishVideoCapture()
        flipCompositionView.userInteractionEnabled = true
    }
    
    func didTapCapturePhotoButton() {
        
        flipCompositionView.capturePhotoWithCompletion({ (image, front, landscape) -> Void in
            
            if let image = image
            {
                let capturedImage = image as UIImage!
                self.flipMessageManager.setCurrentFlipWordImage(capturedImage)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.updateViewForCurrentFlipWord()
                    
                })
            }
            else
            {
                UIAlertView(title: NO_SPACE_PHOTO_ERROR_TITLE, message: NO_SPACE_PHOTO_ERROR_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
            }
            
        }, failure: { (error) -> Void in
            
            UIAlertView(title: LocalizedString.ERROR, message: error?.localizedDescription, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
                
        })
        
    }
    
    func didTapGalleryButton() {
        
        if (UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary))
        {
            let imagePickerController = UIImagePickerControllerWithLightStatusBar()
            let textAtts = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            imagePickerController.navigationBar.barTintColor = UIColor.flipOrange()
            imagePickerController.navigationBar.translucent = false
            imagePickerController.navigationBar.tintColor = UIColor.whiteColor()
            imagePickerController.navigationBar.titleTextAttributes = textAtts
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
            
        }
        
    }
    
    func didTapDeleteButton() {
        
        // Clear the current FlipText and FlipPage
        flipMessageManager.resetFlipWordAtIndex(flipMessageManager.getCurrentFlipWordIndex())
        
        // Update the UI
        updateViewForCurrentFlipWord()
        
    }
    
    
    
    ////
    // MARK: - CameraViewDelegate
    ////
    
    func cameraView(cameraView: CameraView, cameraAvailable available: Bool)  {
        
        if available
        {
            flipControlsView.enableCameraControls()
        }
        else
        {
            flipControlsView.disableCameraControls()
        }
        
    }
    
    func cameraView(cameraView: CameraView, didFinishRecordingVideoAtURL videoURL: NSURL?, inLandscape landscape: Bool, fromFrontCamera frontCamera: Bool, withSuccess success: Bool) {
        
        if success
        {
            flipMessageManager.setCurrentFlipWordVideoURL(videoURL)
            
            moveToNextEmptyFlipWord()
        }
        else
        {
            UIAlertView(title: NO_SPACE_VIDEO_ERROR_TITLE, message: NO_SPACE_VIDEO_ERROR_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
        }
        
    }
    
    func cameraViewDidTapMicrophoneButton(cameraView: CameraView) {
        
    }
    
    
    
    ////
    // MARK: - Audio Recorder Service Delegate
    ////
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didFinishRecordingAudioURL audioURL: NSURL?, success: Bool!) {
        
        let time = MILLISECONDS_UNTIL_RECORDING_SESSION_IS_REALLY_DONE * NSEC_PER_MSEC
        let delayInMilliseconds = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        
        dispatch_after(delayInMilliseconds, dispatch_get_main_queue()) { () -> Void in
            
            self.view.userInteractionEnabled = true
            
            self.flipCompositionView.hideAudioButton()
            
            self.flipMessageManager.setCurrentFlipWordAudioURL(audioURL)
            
            self.moveToNextEmptyFlipWord()
            
        }
        
    }
    
    func audioRecorderService(audioRecorderService: AudioRecorderService!, didRequestRecordPermission: Bool) {
        
    }
    
    
    
    ////
    // MARK: - UIImagePickerControllerDelegate
    ////
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        let currentWord = flipMessageManager.getCurrentFlipWord()
        viewController.navigationItem.title = "\(currentWord.text)"
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let croppedImage = image.cropSquareThumbnail()
        
        flipMessageManager.setCurrentFlipWordImage(croppedImage)
        
        // No need to reload words for an image
        updateViewForCurrentFlipWord(reloadWords: false)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    ////
    // MARK: - FlipsCompositionViewDataSource
    ///
    
    func currentFlipWord() -> (FlipText) {
        return flipMessageManager.getCurrentFlipWord()
    }
    
    func flipWordsCount() -> (Int) {
        return flipMessageManager.getFlipWords().count
    }
    
    func flipWordAtIndex(index: Int) -> (FlipText) {
        return flipMessageManager.getFlipWords()[index]
    }
    
    func flipPageForWordAtIndex(index: Int) -> (FlipPage) {
        return flipMessageManager.getFlipPageForWordAtIndex(index)
    }
    
    func flipWordAtIndexHasImage(index: Int) -> (Bool) {
        let currentWord = flipMessageManager.getCurrentFlipWord()
        let currentWordImage = flipMessageManager.getCurrentFlipWordImage()
        return currentWord.position == index ? currentWordImage != nil : false
    }
    
    func flipImageForWordAtIndex(index: Int) -> (UIImage?) {
        return flipMessageManager.getCurrentFlipWordImage()
    }
    
    
    
    ////
    // MARK: - FlipMessageListViewDelegate
    ////
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSelectFlipWord flipWord: FlipText!) {
        moveToFlipWordAtIndex(flipWord.position)
    }
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSplitFlipWord flipWord: FlipText!) {
        // DO NOTHING - The composition controller doesn't allow for splitting words, just the builder
    }
    
    func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView) {
        // DO NOTHING - the optional mark didn't work on this delegate because of the others methods' params
    }
    
    
    
    ////
    // MARK: - Preview Bar Button
    ////
    
    internal func previewButtonTapped(sender: UIBarButtonItem) {
        
        var previewController : PreviewViewController
        
        if self.contactIDs != nil
        {
            previewController = PreviewViewController(sendOptions: sendingOptions, flipWords: flipMessageManager.getFlipWords(), contactIDs: contactIDs!)
        }
        else
        {
            previewController = PreviewViewController(sendOptions: sendingOptions, flipWords: flipMessageManager.getFlipWords(), roomID: roomID)
        }
        
        previewController.delegate = self
        previewController.fullContacts = contacts
        
        self.navigationController?.pushViewController(previewController, animated: true)
        
    }
    
    
    
    ////
    // MARK: - PreviewViewControllerDelegate
    ////
    
    func previewViewController(viewController: PreviewViewController, didSendMessageToRoom roomID: String, withExternal messageComposer: MessageComposerExternal?) {
        delegate?.didSendMessageToRoom(roomID, withExternal: messageComposer)
    }
    
}

protocol FlipsCompositionControllerDelegate : class {
    
    func didSendMessageToRoom(roomID: String, withExternal: MessageComposerExternal?)
    
}
