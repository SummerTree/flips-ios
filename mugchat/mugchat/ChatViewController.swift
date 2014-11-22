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

class ChatViewController: MugChatViewController, ChatViewDelegate, ChatViewDataSource, ComposeViewControllerDelegate {
    
    private var chatView: ChatView!
    private var chatTitle: String!
    
    private var roomID: String!
    private var flipMessageIds: [String]!
    
    private let flipMessageDataSource = MugMessageDataSource()
    
    
    // MARK: - Initializers
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(chatTitle: String, roomID: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = chatTitle
        self.roomID = roomID
    }
    
    
    // MARK - Overridden Methods
    
    override func loadView() {
        self.chatView = ChatView()
        self.chatView.delegate = self
        self.view = self.chatView
        
        self.setupWhiteNavBarWithBackButton(self.chatTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flipMessageIds = Array<String>()
        self.reloadFlipMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        
        self.chatView.dataSource = self
        self.chatView.viewWillAppear()

        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.chatView.reloadFlipMessages()
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.chatView)
            })
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        
        self.chatView.dataSource = nil
        self.chatView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }

    
    // MARK: - FlipMessages Load Methods
    
    func reloadFlipMessages() {
        flipMessageIds.removeAll(keepCapacity: false)
        let flipMessages = flipMessageDataSource.flipMessagesForRoomID(self.roomID)
        for flipMessage in flipMessages {
            flipMessageIds.append(flipMessage.mugMessageID)
        }
    }
    
    
    // MARK: - Delegate methods
    
    func chatViewDidTapBackButton(chatView: ChatView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func chatView(chatView: ChatView, didTapNextButtonWithWords words : [String]) {
        var composeViewController = ComposeViewController(roomID: self.roomID, composeTitle: self.chatTitle, words: words)
        composeViewController.delegate = self
        self.navigationController?.pushViewController(composeViewController, animated: true)
    }
    

    // MARK: - ChatViewDataSource
    
    func numberOfFlipMessages(chatView: ChatView) -> Int {
        return self.flipMessageIds.count
    }
    
    func chatView(chatView: ChatView, flipMessageIdAtIndex index: Int) -> String {
        return self.flipMessageIds[index]
    }
    
    func chatView(chatView: ChatView, shouldAutoPlayFlipMessageAtIndex index: Int) -> Bool {
        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageIds[index])
        return flipMessage.notRead.boolValue
    }
    
    
    // MARK: - Messages Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        self.reloadFlipMessages()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.chatView.reloadFlipMessages()
        })
    }
    
    
    // MARK: - ComposeViewControllerDelegate
    
    func composeViewControllerDidSendMessage(viewController: ComposeViewController) {
        self.navigationController?.popToViewController(self, animated: true)
    }
}