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

class ChatViewController: FlipsViewController, ChatViewDelegate, ChatViewDataSource, ComposeViewControllerDelegate {
    
    private var chatView: ChatView!
    private var chatTitle: String!
    
    private var roomID: String!
    private var flipMessages = NSMutableOrderedSet()
    

    // MARK: - Initializers
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(room: Room) {
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = room.roomName()
        self.roomID = room.roomID
        
        let roomMessages: [FlipMessage] = room.flipMessages.array as [FlipMessage]
        for flipMessage in roomMessages {
            self.flipMessages.addObject(flipMessage)
        }
    }
    
    
    // MARK - Overridden Methods
    
    override func loadView() {
        var showOnboarding = false
        if (!OnboardingHelper.onboardingHasBeenShown()) {
            showOnboarding = true
        }
        
        self.chatView = ChatView(showOnboarding: false) // Onboarding is disabled for now.
        self.chatView.delegate = self
        self.view = self.chatView
        
        self.setupWhiteNavBarWithBackButton(self.chatTitle)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        
        self.chatView.delegate = self
        self.chatView.dataSource = self
        self.chatView.viewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.chatView.didLayoutSubviews()
        
        if (DeviceHelper.sharedInstance.systemVersion() < 8) {
            // Required only for iOS7
            self.chatView.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        
        self.chatView.viewWillDisappear()
        self.chatView.dataSource = nil
        self.chatView.delegate = nil
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }

    
    // MARK: - FlipMessages Load Methods
    
    func reloadFlipMessages() {
        let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource()
        let flipMessages = flipMessageDataSource.flipMessagesForRoomID(self.roomID)
        for flipMessage in flipMessages {
            self.flipMessages.addObject(flipMessage)
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
        var numberOfFlipMessages: Int!
        numberOfFlipMessages = self.flipMessages.count
        return numberOfFlipMessages
    }
    
    func chatView(chatView: ChatView, flipMessageAtIndex index: Int) -> FlipMessage {
        return self.flipMessages.objectAtIndex(index) as FlipMessage
    }
    
    func chatView(chatView: ChatView, shouldAutoPlayFlipMessageAtIndex index: Int) -> Bool {
//        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageIds[index])
//        return flipMessage.notRead.boolValue
        return true
    }
    
    
    // MARK: - Messages Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        println("notificationReceived")
        self.reloadFlipMessages()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.chatView.loadNewFlipMessages()
        })
    }
    
    
    // MARK: - ComposeViewControllerDelegate
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.reloadFlipMessages()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.popToViewController(self, animated: true)
                self.chatView.clearReplyTextField()
                self.chatView.hideTextFieldAndShowReplyButton()
                self.chatView.loadNewFlipMessages()
                self.chatView.showNewestMessage()
            })
        })
    }
    
    func composeViewController(viewController: ComposeViewController, didChangeFlipWords words: [String]) {
        self.chatView.changeFlipWords(words)
    }
}