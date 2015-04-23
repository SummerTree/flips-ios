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

class PreviewViewController : FlipsViewController, PreviewViewDelegate {
    
    private let SEND_MESSAGE_ERROR_TITLE = NSLocalizedString("Fail", comment: "Fail")
    private let SEND_MESSAGE_ERROR_MESSAGE = NSLocalizedString("Flips couldn't send your message. Please try again.\n", comment: "Flips couldn't send your message. Please try again.")
    
    private var previewView: PreviewView!
    private var flipWords: [FlipText]!
    private var roomID: String?
    private var contactIDs: [String]?
    
    weak var delegate: PreviewViewControllerDelegate?
    
    convenience init(flipWords: [FlipText], roomID: String) {
        self.init()
        self.flipWords = flipWords
        self.roomID = roomID
    }
    
    convenience init(flipWords: [FlipText], contactIDs: [String]) {
        self.init()
        self.flipWords = flipWords
        self.contactIDs = contactIDs
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
        
        let result = self.parseFlipWords()
        
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
                
                let flipDataSource = FlipDataSource()
                for flipWord in self.flipWords {
                    if (flipWord.associatedFlipId == nil) {
                        dispatch_group_enter(group)
                        PersistentManager.sharedInstance.createAndUploadFlip(flipWord.text, videoURL: nil, thumbnailURL: nil, createFlipSuccessCompletion: { (flip) -> Void in
                            flipWord.associatedFlipId = flip.flipID
                            dispatch_group_leave(group)
                        }, createFlipFailCompletion: { (flipError) -> Void in
                            error = flipError
                            flipWord.associatedFlipId = "-1"
                            dispatch_group_leave(group)
                        })
                    }
                }
                
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
                
                if (error != nil) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.hideActivityIndicator()
                        
                        let message = "\(self.SEND_MESSAGE_ERROR_MESSAGE)\n\(error?.error)"
                        let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                        alertView.show()
                    })
                } else {
                    let completionBlock: SendMessageCompletion = { (success, roomID, flipError) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (success) {
                                self.delegate?.previewViewController(self, didSendMessageToRoom: roomID!)
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
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
}

protocol PreviewViewControllerDelegate: class {
    
    func previewViewController(viewController: PreviewViewController, didSendMessageToRoom roomID: String)
    
}