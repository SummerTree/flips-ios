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

class PreviewViewController : FlipsViewController, PreviewViewDelegate {
    
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
    
    // The reason for two of essentially the same
    // variable answers is a timing issue - we must
    // check for this before the message is sent. 
    // Otherwise, the contact ID will have been 
    // invited to Flips, and will not be a Non Flips
    // member anymore
    
    private var foundNonFlipsUsers : Bool = false
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

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.previewView = PreviewView()
        self.previewView.delegate = self
        self.view = previewView
    }
    
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(NSLocalizedString("Preview", comment: "Preview"))
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.previewView.viewDidLoad()
        
//        let result = self.parseFlipWords()
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

    
    // MARK: - Notification Handler

    internal func onPubNubDidConnectNotificationReceived() {
        self.hideActivityIndicator()
    }
    
    // MARK: - Flips Methods
    
    private func parseFlipWords() -> (flips: [Flip], formattedWords: [String]) {
        var flips = Array<Flip>()
        var formattedWords = Array<String>()
        
        let flipDataSource = FlipDataSource()
        
        for flipWord in self.flipWords {
            if (flipWord.associatedFlipId != nil) {
                var flip = flipDataSource.retrieveFlipWithId(flipWord.associatedFlipId!)
                flips.append(flip)
                
            } else {
                var emptyFlip = flipDataSource.createEmptyFlipWithWord(flipWord.text)
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
                var flip = flipDataSource.retrieveFlipWithId(flipID)
                flips.append(flip)
            }
            else if let videoURL = flipPage.videoURL {
                flips.append(flipPage.createFlip())
            }
            
            formattedWords.append(flipPage.word)
        }
        
        return (flips, formattedWords)
    }
    
    // MARK: - ComposeViewDelegate Methods
    
    func previewViewDidTapBackButton(previewView: PreviewView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func previewViewDidTapSendButton(previewView: PreviewView!) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        } else {
            self.previewView.stopMovie()
            self.showActivityIndicator()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                var error: FlipError?
                
                var group = dispatch_group_create()
                
                // Flips 2.0 - confirm reject removed
                // Upload all flipPages that were created locally
                
                for flipPage in self.draftingTable!.flipBook.flipPages {
                    if flipPage.pageID == nil {
                        dispatch_group_enter(group)
                        PersistentManager.sharedInstance.createAndUploadFlip(flipPage.word, videoURL: flipPage.videoURL, thumbnailURL: flipPage.thumbnailURL, createFlipSuccessCompletion: { (flip) -> Void in
                            flipPage.pageID = flip.flipID
                            dispatch_group_leave(group)
                            }, createFlipFailCompletion: { (flipError) -> Void in
                                error = flipError
                                flipPage.pageID = "-1"
                                dispatch_group_leave(group)
                        })
                    }
                }
                
                
//                //Flips 1.0 - relying on Confirm/Reject
//                
//                for flipWord in self.flipWords {
//                    if (flipWord.associatedFlipId == nil) {
//                        dispatch_group_enter(group)
//                        PersistentManager.sharedInstance.createAndUploadFlip(flipWord.text, videoURL: nil, thumbnailURL: nil, createFlipSuccessCompletion: { (flip) -> Void in
//                            flipWord.associatedFlipId = flip.flipID
//                            dispatch_group_leave(group)
//                        }, createFlipFailCompletion: { (flipError) -> Void in
//                            error = flipError
//                            flipWord.associatedFlipId = "-1"
//                            dispatch_group_leave(group)
//                        })
//                    }
//                }
                
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
                
                if (error != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.hideActivityIndicator()
                        
                        var message = self.SEND_MESSAGE_ERROR_MESSAGE
                        if (error != nil) {
                            message = "\(self.SEND_MESSAGE_ERROR_MESSAGE)\n\(error!.error)"
                        }

                        let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    })
                } else {
                    let completionBlock: SendMessageCompletion = { (success, roomID, flipError) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (success) {
                                
                                if self.sendOptions.count > 0 {
                                    
                                    // Export Movie
                                    var movieExport = MovieExport.sharedInstance
                                    movieExport.exportFlipForMMS(self.previewView.retrievePlayerItems(), words: self.flipWordStrings,
                                        completion: { (url: NSURL?, error: FlipError?) -> Void in
                                            
                                            //Attach movie to native text message
                                            self.messageComposer = MessageComposerExternal()
                                            self.messageComposer!.videoUrl = url
                                            self.messageComposer!.contacts = self.phoneNumbers
                                            self.messageComposer!.containsNonFlipsUsers = self.foundNonFlipsUsers
                                            
                                            self.delegate?.previewViewController(self, didSendMessageToRoom: roomID!, withExternal: self.messageComposer)
                                        }
                                    )
                                    
                                }
                                else {
                                    self.delegate?.previewViewController(self, didSendMessageToRoom: roomID!, withExternal: self.messageComposer)
                                }
                                
                                // log message sent analytics
                                let numOfWords = self.flipWords.count
                                var numOfWordsAssigned = 0
                                
                                let flipDataSource = FlipDataSource()
                                for word in self.flipWords {
                                    if let associatedFlipId = word.associatedFlipId {
                                        var flip = flipDataSource.retrieveFlipWithId(associatedFlipId)
                                        if (!flip.backgroundURL.isEmpty) {
                                            numOfWordsAssigned++
                                        }
                                    }
                                }
                                
                                var isGroupRoom = false
                                
                                if let contacts = self.contactIDs {
                                    isGroupRoom = self.contactIDs?.count > 1
                                } else if let roomID = self.roomID {
                                    let roomDataSource = RoomDataSource()
                                    isGroupRoom = roomDataSource.retrieveRoomWithId(roomID).participants.count > 2
                                }
                                
                                AnalyticsService.logMessageSent(numOfWords, percentWordsAssigned: (numOfWordsAssigned / numOfWords) * 100, group: isGroupRoom)
                            } else {
                                if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
                                    self.hideActivityIndicator()
                                    let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: LocalizedString.NO_INTERNET_CONNECTION, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                                    alertView.show()
                                } else if (!PubNubService.sharedInstance.isConnected()) {
                                    self.showActivityIndicator(userInteractionEnabled: true, message: NSLocalizedString("Reconnecting\nPlease Wait"))
                                } else {
                                    self.hideActivityIndicator()
                                    var message = self.SEND_MESSAGE_ERROR_MESSAGE
                                    if (flipError != nil) {
                                        message = "\(self.SEND_MESSAGE_ERROR_MESSAGE)\n\(flipError!.error)"
                                    }
                                    
                                    let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                                    alertView.show()
                                }
                            }
                        })
                    }
                    
                    self.foundNonFlipsUsers = self.didFindNonFlipsUsers
                    
                    let messageService = MessageService.sharedInstance
                    if (self.roomID != nil) {
                        messageService.sendMessage(self.flipWords, roomID: self.roomID!, completion: completionBlock)
                    } else {
                        messageService.sendMessage(self.flipWords, toContacts: self.contactIDs!, completion: completionBlock)
                    }
                }
            })
        }
    }
    
    func previewViewMakeConstraintToNavigationBarBottom(container: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        container.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: AnyObject = self.topLayoutGuide
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}

protocol PreviewViewControllerDelegate: class {
    
    func previewViewController(viewController: PreviewViewController, didSendMessageToRoom roomID: String, withExternal messageComposer: MessageComposerExternal?)
    
}