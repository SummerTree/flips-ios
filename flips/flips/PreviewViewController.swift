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

class PreviewViewController : FlipsViewController, PreviewViewDelegate, MessageComposerExternalDelegate, UIAlertViewDelegate {
    
    private let SEND_MESSAGE_ERROR_TITLE = NSLocalizedString("Fail", comment: "Fail")
    private let SEND_MESSAGE_ERROR_MESSAGE = NSLocalizedString("Flips couldn't send your message. Please try again.\n", comment: "Flips couldn't send your message. Please try again.")
    
    private var previewView: PreviewView!
    private var flipWords: [FlipText]!
    private var roomID: String?
    
    private var contactIDs: [String]?
    
    var fullContacts : [Contact]?
    var messageComposer : MessageComposerExternal?
    
    internal var sendOptions : [FlipsSendButtonOption] = []
    
    weak var delegate: PreviewViewControllerDelegate?
    
    private var didFindNonFlipsUsers : Bool {
        get {
            var nonFlipsUserFound = false
            if let fContacts = self.fullContacts {
                for contact : Contact in fContacts {
                    if contact.contactUser == nil {
                        nonFlipsUserFound = true
                    }
                }
            }
            return nonFlipsUserFound
        }
    }
    
    private var phoneNumbers : [String] {
        get {
            var numbers : [String] = []
            for contact : Contact in self.fullContacts! {
                numbers += [contact.phoneNumber!]
            }
            return numbers
        }
    }
    
    private var flipWordStrings : [String] {
        get {
            var strings : [String] = []
            for flipWord : FlipText in self.flipWords! {
                strings += [flipWord.text!]
            }
            return strings
        }
    }
    
    
    
    ////
    // MARK: - Init
    ////
    
    convenience init(sendOptions: [FlipsSendButtonOption], flipWords: [FlipText], roomID: String) {
        self.init(flipWords: flipWords, roomID: roomID)
        self.sendOptions = sendOptions
    }
    
    init(flipWords: [FlipText], roomID: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.flipWords = flipWords
        self.roomID = roomID
    }
    
    convenience init(sendOptions: [FlipsSendButtonOption], flipWords: [FlipText], contactIDs: [String]) {
        self.init(flipWords: flipWords, contactIDs: contactIDs)
        self.sendOptions = sendOptions
    }
    
    init(flipWords: [FlipText], contactIDs: [String]) {
        super.init(nibName: nil, bundle: nil)
        
        self.flipWords = flipWords
        self.contactIDs = contactIDs
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    ////
    // MARK: - Lifecycle
    ////
    
    override func loadView() {
        self.previewView = PreviewView()
        self.previewView.delegate = self
        self.view = previewView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(NSLocalizedString("Preview", comment: "Preview"))
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.previewView.viewDidLoad()
        
        let result = self.parseFlipWordsFromDraftingTable()
        
        self.previewView.setupVideoPlayerWithFlips(result.flips, formattedWords: result.formattedWords)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onPubNubDidConnectNotificationReceived", name: PUBNUB_DID_CONNECT_NOTIFICATION, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.hideActivityIndicator()
    }

    
    
    ////
    // MARK: - Notification Handler
    ////

    internal func onPubNubDidConnectNotificationReceived() {
        self.hideActivityIndicator()
    }
    
    
    
    ////
    // MARK: - Flips Utility Methods
    ////
    
    private func parseFlipWords() -> (flips: [Flip], formattedWords: [String]) {
        var flips = Array<Flip>()
        var formattedWords = Array<String>()
        
        let flipDataSource = FlipDataSource()
        
        for flipWord in self.flipWords {
            if (flipWord.associatedFlipId != nil) {
                let flip = flipDataSource.retrieveFlipWithId(flipWord.associatedFlipId!)
                flips.append(flip)
                
            } else {
                let emptyFlip = flipDataSource.createEmptyFlipWithWord(flipWord.text)
                flips.append(emptyFlip)
            }
            formattedWords.append(flipWord.text)
        }
        
        return (flips, formattedWords)
    }
    
    private func parseFlipWordsFromDraftingTable() -> (flips: [Flip], formattedWords: [String]) {
        
        var flips = Array<Flip>()
        var formattedWords = Array<String>()
        
        let flipDataSource = FlipDataSource()
        
        for flipPage in self.draftingTable!.flipBook.flipPages {
            
            if let flipID = flipPage.pageID {
                let flip = flipDataSource.retrieveFlipWithId(flipID)
                flips.append(flip)
            }
            else if let _ = flipPage.videoURL {
                flips.append(flipPage.createFlip())
            }
            else {
                let flip = flipDataSource.createEmptyFlipWithWord(flipPage.word)
                flips.append(flip)
                flipPage.pageID = flip.flipID
            }
            
            formattedWords.append(flipPage.word)
        }
        
        return (flips, formattedWords)
    }
    
    
    
    ////
    // MARK: - Message Submission
    ////
    
    private func submitMessageRequest() {
        
        delegate?.didBeginMessageSubmissionToRoom(self.roomID)
        
        let request = FlipMessageSubmissionManager.SubmissionRequest(
            flipWords: self.flipWords,
            flipPages: self.draftingTable!.flipBook.flipPages,
            roomID: self.roomID,
            contacts: self.fullContacts)
        
        FlipMessageSubmissionManager.sharedInstance.submitRequest(request)
        
    }
    
    private func submitMMSMessage() {
        
        let movieExport = MovieExport.sharedInstance
                    
        movieExport.exportFlipForMMS(self.previewView.retrievePlayerItems(), words: self.flipWordStrings,
            completion: { (url: NSURL?, error: FlipError?) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    //Attach movie to native text message
                    self.messageComposer = MessageComposerExternal()
                    self.messageComposer!.delegate = self
                    self.messageComposer!.videoUrl = url
                    self.messageComposer!.contacts = self.phoneNumbers
                    self.messageComposer!.containsNonFlipsUsers = self.didFindNonFlipsUsers
                    
                    let messageComposerController = self.messageComposer?.configuredMessageComposeViewController()
                    
                    if let messageComposerController = messageComposerController
                    {
                        self.presentViewController(messageComposerController, animated: true, completion: nil)
                    }
                    else
                    {
                        self.showExternalComposerErrorAlert()
                    }
                
                })
                
            }
        )
        
    }
    
    
    
    ////
    // MARK: - Error Handling
    ////
    
    private func showMMSUnsupportedErrorAlert() {
        
        let errorTitle = "Error Sending MMS"
        let errorMessage = "This device does not support SMS."
        
        if #available(iOS 8.0, *)
        {
            let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.submitMessageRequest()
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            UIAlertView(title: errorTitle, message: errorMessage, delegate: self, cancelButtonTitle: "Dismiss").show()
        }
        
    }
    
    private func showExternalComposerErrorAlert() {
        
        let errorTitle = "Error Sending MMS"
        let errorMessage = "Flips was unable to send your message at this time."
        
        if #available(iOS 8.0, *)
        {
            let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.submitMessageRequest()
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            UIAlertView(title: errorTitle, message: errorMessage, delegate: self, cancelButtonTitle: "Dismiss").show()
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if alertView.buttonTitleAtIndex(buttonIndex)! == "Dismiss" {
            self.submitMessageRequest()
        }
        
    }
    
    
    
    ////
    // MARK: - ComposeViewDelegate Methods
    ////
    
    func previewViewDidTapBackButton(previewView: PreviewView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func previewViewDidTapSendButton(previewView: PreviewView!) {
        
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection())
        {
            UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK).show()
        }
        else
        {
            self.previewView.stopMovie()
            self.showActivityIndicator()
            
            if sendOptions.count > 0
            {
                if MessageComposerExternal.canSendText()
                {
                    submitMMSMessage()
                }
                else
                {
                    showMMSUnsupportedErrorAlert()
                }
            }
            else
            {
                submitMessageRequest()
            }
        }
        
    }
    
    
    
    ////
    // MARK: - Utility
    ////
    
    func previewViewMakeConstraintToNavigationBarBottom(container: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        container.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_topLayoutGuideBottom)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    
    ////
    // MARK: - MessageComposerExternalDelegate
    ////
    
    func didFinishSendingTextMessage(success: Bool) {
        
        if success
        {
            submitMessageRequest()
        }
        else
        {
            showExternalComposerErrorAlert()
        }
        
    }
    
    func didCancelSendingTextMessage() {
        submitMessageRequest()
    }
    
}

protocol PreviewViewControllerDelegate: class {
    func didBeginMessageSubmissionToRoom(roomID: String!)
}