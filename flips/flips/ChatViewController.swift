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

class ChatViewController: FlipsViewController, ChatViewDelegate, ChatViewDataSource, FlipsCompositionControllerDelegate, UIAlertViewDelegate {
    
    private let groupTitle: String = NSLocalizedString("Group Chat")

    private let DOWNLOAD_MESSAGE_FROM_PUSH_NOTIFICATION_MAX_NUMBER_OF_RETRIES: Int = 20 // aproximately 20 seconds
    private var downloadingMessageFromNotificationRetries: Int = 0

    private var sendingView: UILabel!
    private var chatView: ChatView!
    private var groupParticipantsView: GroupParticipantsView?
    
    private var chatTitle: String!
    
    private var roomID: String!
    private var flipMessages: NSMutableOrderedSet!
    
    private var flipMessageIdFromPushNotification: String?
    

    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(room: Room, andFlipMessageIdFromPushNotification flipMessageID: String? = nil) {
        
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = room.roomName()
        self.roomID = room.roomID
        self.flipMessageIdFromPushNotification = flipMessageID

        if (room.participants.count > 2) {
            self.chatTitle = groupTitle
            self.groupParticipantsView = GroupParticipantsView(participants: Array(room.participants) as! Array<User> as [User])
        }
        
        self.flipMessages = NSMutableOrderedSet(array: room.notRemovedFlipMessagesOrderedByReceivedAt())
                        
    }
    
    // MARK - Overridden Methods
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func loadView() {
        
        var showOnboarding = false
        if (!OnboardingHelper.onboardingHasBeenShown()) {
            showOnboarding = true
        }
        
        let isOpeningFromNotification = (self.flipMessageIdFromPushNotification != nil)
        
        self.chatView = ChatView(showOnboarding: false, isOpeningFromPushNotification: isOpeningFromNotification) // Onboarding is disabled for now.
        self.chatView.delegate = self
        self.chatView.parentViewController = self
        self.view = self.chatView
        
        self.setupWhiteNavBarWithBackButton(self.chatTitle)

        if (self.groupParticipantsView != nil) {
            let participantsButton = UIBarButtonItem(image: UIImage(named: "Group_Participants_Icon") , style: .Done, target: self, action: #selector(ChatViewController.groupParticipantsButtonTapped))
            self.navigationItem.rightBarButtonItem = participantsButton

            let participantsViewInitialY: CGFloat = -self.groupParticipantsView!.calculatedHeight()
            
            self.view.addSubview(self.groupParticipantsView!)
            self.groupParticipantsView!.mas_makeConstraints( { (make: MASConstraintMaker!) -> Void in
                make.top.equalTo()(self.view).with().offset()(participantsViewInitialY)
                make.leading.equalTo()(self.view)
                make.trailing.equalTo()(self.view)
                make.height.equalTo()(self.groupParticipantsView!.calculatedHeight())
            })
            self.groupParticipantsView!.setupView()
        }
        
        self.sendingView = UILabel()
        self.sendingView.hidden = true
        self.sendingView.backgroundColor = UIColor.flipOrangeBackground()
        self.sendingView.textColor = UIColor.whiteColor()
        self.sendingView.text = "Sending Message..."
        self.sendingView.textAlignment = NSTextAlignment.Center
        self.sendingView.font = UIFont.avenirNextMedium(16.0)
        self.view.addSubview(self.sendingView)
        
        self.sendingView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.width.equalTo()(self.view)
            make.height.equalTo()(44)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if (DeviceHelper.sharedInstance.systemVersion() >= 8) {
            // It doesn't work properly on iOS7
            self.view.addKeyboardPanningWithFrameBasedActionHandler(nil, constraintBasedActionHandler: { (keyBoardFrameInView: CGRect, openning: Bool, closing: Bool) -> Void in
                self.chatView.keyboardPanningToFrame(keyBoardFrameInView)
            })
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.onFlipMessageContentDownloadedNotificationReceived(_:)), name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.onFlipMessageReceivedNotification(_:)), name: FLIP_MESSAGE_RECEIVED_NOTIFICATION, object: nil)
        
        self.chatView.delegate = self
        self.chatView.dataSource = self
        self.chatView.viewWillAppear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let flipMessageID = self.flipMessageIdFromPushNotification {
            if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
                self.flipMessageIdFromPushNotification = nil
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let alertView: UIAlertView = UIAlertView(title: "", message: NSLocalizedString("Unable to retrieve message. Please check your connection and try again."), delegate: nil, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                })
            } else {
                let flipMessagesArray: [FlipMessage] = self.flipMessages.array as! [FlipMessage]
                let alreadyReceivedMessage: Bool = false
                for flipMessage in flipMessagesArray {
                    if (flipMessage.flipMessageID == flipMessageID) {
                        return
                    }
                }
                
                if (!alreadyReceivedMessage) {
                    self.showActivityIndicator(true, message: NSLocalizedString("Downloading message"))
                    self.showMessageFromReceivedPushNotificationWhenDownloaded()
                }
            }
        }
        
        self.groupParticipantsView?.mas_updateConstraints( { (update: MASConstraintMaker!) -> Void in
            update.removeExisting = true
            update.top.equalTo()(self.view).with().offset()(CGRectGetMaxY(self.navigationController!.navigationBar.frame))
            update.leading.equalTo()(self.view)
            update.trailing.equalTo()(self.view)
            update.height.equalTo()(0)
        })
        self.groupParticipantsView?.updateConstraintsIfNeeded()
        self.groupParticipantsView?.layoutIfNeeded()
       
        updateMessageSubmissionState()
        registerForMessageSubmissionNotifications()
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FLIP_MESSAGE_RECEIVED_NOTIFICATION, object: nil)
        
        self.chatView.viewWillDisappear()
        self.chatView.dataSource = nil
        self.chatView.delegate = nil
        
        if (DeviceHelper.sharedInstance.systemVersion() >= 8) {
            self.chatView.removeKeyboardControl()
        }
        
        unregisterMessageSubmissionNotifications()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    // MARK: - FlipMessages Load Methods
    
    func reloadFlipMessages() {
        let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource()
        let flipMessages = flipMessageDataSource.flipMessagesForRoomID(self.roomID)
        for flipMessage in flipMessages {
            self.flipMessages.addObject(flipMessage)
        }
    }
    
    
    // MARK: - jump to newest message
    
    func showChatViewNewestMessage(shouldScrollAnimated: Bool) {
        if (self.chatView != nil) {
            self.chatView.showNewestMessage(shouldScrollAnimated: shouldScrollAnimated)
        }
    }
    
    
    // MARK: - Delegate methods
    
    func chatViewDidTapBackButton(chatView: ChatView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func chatView(chatView: ChatView, didTapNextButtonWithWords words : [String]) {
        let composeViewController = FlipMessageCompositionVC(roomID: self.roomID, compositionTitle: self.chatTitle, words: words)
        composeViewController.delegate = self
        self.navigationController?.pushViewController(composeViewController, animated: true)
    }
    
    func groupParticipantsButtonTapped() {
        if (self.groupParticipantsView?.frame.height == 0) {
            // show
            self.groupParticipantsView?.mas_updateConstraints({ (update: MASConstraintMaker!) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self.view).with().offset()(CGRectGetMaxY(self.navigationController!.navigationBar.frame))
                update.leading.equalTo()(self.view)
                update.trailing.equalTo()(self.view)
                update.height.equalTo()(self.groupParticipantsView?.calculatedHeight())
            })
        } else {
            // dismiss
            self.groupParticipantsView?.mas_updateConstraints({ (update: MASConstraintMaker!) -> Void in
                update.removeExisting = true
                update.top.equalTo()(self.view).with().offset()(CGRectGetMaxY(self.navigationController!.navigationBar.frame))
                update.leading.equalTo()(self.view)
                update.trailing.equalTo()(self.view)
                update.height.equalTo()(0)
            })
        }

        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    
    // MARK: - ChatViewDataSource
    
    func numberOfFlipMessages(chatView: ChatView) -> Int {
        var numberOfFlipMessages: Int!
        numberOfFlipMessages = self.flipMessages.count
        return numberOfFlipMessages
    }
    
    func chatView(chatView: ChatView, flipMessageAtIndex index: Int) -> FlipMessage {
        return self.flipMessages.objectAtIndex(index) as! FlipMessage
    }
    
    func chatView(chatView: ChatView, shouldAutoPlayFlipMessageAtIndex index: Int) -> Bool {
//        let flipMessage = flipMessageDataSource.retrieveFlipMessageById(flipMessageIds[index])
//        return flipMessage.notRead.boolValue
        return true
    }
    
    
    // MARK: - Messages Notification Handler
    
    func onFlipMessageReceivedNotification(notification: NSNotification) {
        self.reloadFlipMessages()
        
        var scrollToReceivedMessage: Bool = false
        if (self.flipMessageIdFromPushNotification != nil) {
            if let flipMessageIdReceived: String = notification.userInfo?[FLIP_MESSAGE_RECEIVED_NOTIFICATION_PARAM_MESSAGE_KEY] as? String {
                if (flipMessageIdReceived == self.flipMessageIdFromPushNotification) {
                    scrollToReceivedMessage = true
                    self.flipMessageIdFromPushNotification = nil
                }
            }
        }
        
        self.refreshThreadView(scrollToReceivedMessage)
    }
    
    func onFlipMessageContentDownloadedNotificationReceived(notification: NSNotification) {
        self.reloadFlipMessages()
    }
    
    private func refreshThreadView(scrollToReceivedMessage: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.chatView.loadNewFlipMessages()
            self.showChatViewNewestMessage(scrollToReceivedMessage)
            if (scrollToReceivedMessage) {
                self.hideActivityIndicator()
            }
        })
    }
    
    
    // MARK: - Message From Push Notification Handlers
    
    private func showMessageFromReceivedPushNotificationWhenDownloaded() {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            self.flipMessageIdFromPushNotification = nil
            self.hideActivityIndicator()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alertView: UIAlertView = UIAlertView(title: "", message: NSLocalizedString("Unable to retrieve message. Please check your connection and try again."), delegate: self, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            })
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let flipMessageID = self.flipMessageIdFromPushNotification {
                    var flipMessageAlreadyReceived = false
                    let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource()
                    if let _: FlipMessage = flipMessageDataSource.getFlipMessageById(flipMessageID) {
                        flipMessageAlreadyReceived = true
                        self.flipMessageIdFromPushNotification = nil
                    }
                    
                    if (flipMessageAlreadyReceived) {
                        self.refreshThreadView(true)
                        self.hideActivityIndicator()
                    } else {
                        self.retryToShowMessageFromPushNotification()
                    }
                }
            })
        }
    }
    
    private func retryToShowMessageFromPushNotification() {
        let time = 1 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            if (self.flipMessageIdFromPushNotification) != nil { // Just to make sure that the user didn't close this screen.
                self.downloadingMessageFromNotificationRetries += 1
                if (self.downloadingMessageFromNotificationRetries < self.DOWNLOAD_MESSAGE_FROM_PUSH_NOTIFICATION_MAX_NUMBER_OF_RETRIES) {
                    self.showMessageFromReceivedPushNotificationWhenDownloaded()
                } else {
                    self.hideActivityIndicator()
                    self.flipMessageIdFromPushNotification = nil
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let alertView = UIAlertView(title: nil, message: NSLocalizedString("Download failed. Please try again later."), delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    })
                }
            }
        })
    }
    
    
    // MARK: - FlipsCompositionControllerDelegate
    
    func showSendingView() {
        
        if sendingView.hidden == true {
            
            self.sendingView.mas_updateConstraints { (update) -> Void in
                update.top.equalTo()(self.view)
            }
            
            self.sendingView.hidden = false
            
        }
        
    }
    
    func hideSendingView() {
        
        if sendingView.hidden == false {
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.sendingView.frame.origin.y -= self.sendingView.frame.height
                self.view.layoutIfNeeded()
                
            }, completion:{ (finished) -> Void in
                    
                self.sendingView.hidden = true
                
            })
            
        }
        
    }
    
    func didBeginSendingMessageToRoom(roomID: String!) {
        
        self.navigationController?.popToViewController(self, animated: true)
        self.chatView.clearReplyTextField()
        self.chatView.hideTextFieldAndShowReplyButton()
        
        showSendingView()
        
    }
    
    
    ////
    // MARK: - SubmissionManager Notifications
    ////
    
    func submissionManagerDidFinishSendingMessage(notification: NSNotification) {
        
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            
            self.reloadFlipMessages()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.updateMessageSubmissionState()
                
                self.chatView.loadNewFlipMessages()
                
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                
            })
            
        })
        
    }
    
    func submissionManagerDidFailToSendMessage(notification: NSNotification) {
        
        let payload = notification.userInfo as [NSObject : AnyObject]?
        var alertTitle = "Error Sending Message"
        var alertMessage = "Flips was unable to send your message."
        
        if let payload = payload {
            
            if let error = payload["error"] as? String {
                alertTitle = error
            }
            
            if let details = payload["details"] as? String {
                alertMessage = details
            }
            
        }
        
        showMessageSubmissionFailedAlert(alertTitle, message: alertMessage)
        
    }
    
    
    
    ////
    // MARK: - Message Submission State Handling
    ////
    
    private func registerForMessageSubmissionNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.submissionManagerDidFinishSendingMessage(_:)), name: FlipMessageSubmissionManager.Notifications.SEND_COMPLETE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.submissionManagerDidFailToSendMessage(_:)), name: FlipMessageSubmissionManager.Notifications.SEND_ERROR, object: nil)
    }
    
    private func unregisterMessageSubmissionNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FlipMessageSubmissionManager.Notifications.SEND_ERROR, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FlipMessageSubmissionManager.Notifications.SEND_COMPLETE, object: nil)
    }
    
    private func updateMessageSubmissionState() {
        
        let submissionManager = FlipMessageSubmissionManager.sharedInstance
        
        switch submissionManager.getState() {
            case .Sending:
                if submissionManager.hasPendingMessageForRoom(self.roomID) {
                    showSendingView()
                }
                else {
                    hideSendingView()
                }
            case .Waiting:
                hideSendingView()
            case .Error:
                showMessageSubmissionFailedAlert("Message Submission Failed", message: "An error occurred while sending your message.")
        }
        
    }
    
    private func showMessageSubmissionFailedAlert(title: String, message: String) {
        
        if #available(iOS 8.0, *)
        {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.retryMessageSubmission()
                
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
                self.cancelMessageSubmission()
                
            }))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Retry").show()
        }
        
    }
    
    
    
    ////
    // Local Notification Handler Methods
    ////
    
    private func retryMessageSubmission() {
        
        self.showSendingView()
        
        NSNotificationCenter.defaultCenter().postNotificationName(FlipMessageSubmissionManager.Notifications.RETRY_SUBMISSION, object: nil)
        
    }
    
    private func cancelMessageSubmission() {
        
        if FlipMessageSubmissionManager.sharedInstance.hasAdditionalPendingMessagesForRoom(self.roomID) {
            self.showSendingView()
        }
        else {
            self.hideSendingView()
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(FlipMessageSubmissionManager.Notifications.CANCEL_SUBMISSION, object: nil)
        
    }
    
    
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        switch (alertView.buttonTitleAtIndex(buttonIndex)!) {
            case LocalizedString.OK:
                 self.navigationController?.popViewControllerAnimated(true)
            case "Retry":
                self.retryMessageSubmission()
            case "Cancel":
                self.cancelMessageSubmission()
            default:
                return
        }
    }
    
}