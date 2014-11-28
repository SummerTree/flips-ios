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

class PreviewViewController : MugChatViewController, PreviewViewDelegate {
    
    private let SEND_MESSAGE_ERROR_TITLE = NSLocalizedString("Error", comment: "Error")
    private let SEND_MESSAGE_ERROR_MESSAGE = NSLocalizedString("Flips couldn't send your message. Please try again.\n", comment: "Flips couldn't send your message. Please try again.")
    
    private var previewView: PreviewView!
    private var flipWords: [MugText]!
    private var roomID: String?
    private var contactIDs: [String]?
    
    var delegate: PreviewViewControllerDelegate?
    
    convenience init(flipWords: [MugText], roomID: String) {
        self.init()
        self.flipWords = flipWords
        self.roomID = roomID
    }
    
    convenience init(flipWords: [MugText], contactIDs: [String]) {
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
        
        let flips = self.createFlipsFromFlipWords()
        self.previewView.setupVideoPlayerWithFlips(flips)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView.viewDidAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.viewWillDisappear()
    }
    
    
    // MARK: - Flips Methods
    
    private func createFlipsFromFlipWords() -> [Mug] {
        var flips = Array<Mug>()
        let flipDataSource = MugDataSource()
        
        for flipWord in self.flipWords {
            if (flipWord.associatedFlipId != nil) {
                var flip = flipDataSource.retrieveMugWithId(flipWord.associatedFlipId!)
                flip.word = flipWord.text // Sometimes the saved word is in a different case. So we need to change it.
                flips.append(flip)
            } else {
                var emptyFlip = flipDataSource.createEmptyMugWithWord(flipWord.text)
                flips.append(emptyFlip)
            }
        }
        
        return flips
    }
    
    // MARK: - ComposeViewDelegate Methods
    
    func previewViewDidTapBackButton(previewView: PreviewView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func previewButtonDidTapSendButton(previewView: PreviewView!) {
        self.previewView.stopMovie()
        self.showActivityIndicator()

        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            var error: FlipError?
            var flipIds = Array<String>()
            let flipService = MugService()
            
            var group = dispatch_group_create()

            let flipDataSource = MugDataSource()
            for flipWord in self.flipWords {
                if (flipWord.associatedFlipId != nil) {
                    var flip = flipDataSource.retrieveMugWithId(flipWord.associatedFlipId!)
                    flip.word = flipWord.text // Sometimes the saved word is in a different case. So we need to change it.
                    flipIds.append(flip.mugID)
                } else {
                    // Create a Flip in the server for each empty Flip
                    dispatch_group_enter(group)
                    flipService.createMug(flipWord.text, backgroundImage: nil, soundPath: nil, isPrivate: true, createMugSuccessCallback: { (flip) -> Void in
                        flipIds.append(flip.mugID)
                        dispatch_group_leave(group);
                    }, createMugFailCallBack: { (flipError) -> Void in
                        error = flipError
                        dispatch_group_leave(group);
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
                // SEND MESSAGE
                let completionBlock: SendMessageCompletion = { (success, roomID, flipError) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.hideActivityIndicator()
                        if (success) {
                            self.delegate?.previewViewController(self, didSendMessageToRoom: roomID!)
                        } else {
                            var message = self.SEND_MESSAGE_ERROR_MESSAGE
                            if (flipError != nil) {
                                message = "\(self.SEND_MESSAGE_ERROR_MESSAGE)\n\(flipError!.error)"
                            }
                            
                            let alertView = UIAlertView(title: self.SEND_MESSAGE_ERROR_TITLE, message: message, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                            alertView.show()
                        }
                    })
                }
                
                let messageService = MessageService.sharedInstance
                if (self.roomID != nil) {
                    messageService.sendMessage(flipIds, roomID: self.roomID!, completion: completionBlock)
                } else {
                    messageService.sendMessage(flipIds, toContacts: self.contactIDs!, completion: completionBlock)
                }
            }
        })
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

protocol PreviewViewControllerDelegate {
    
    func previewViewController(viewController: PreviewViewController, didSendMessageToRoom roomID: String)
    
}