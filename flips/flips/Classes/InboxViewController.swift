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

let RESYNC_INBOX_NOTIFICATION_NAME: String = "resync_inbox_notification"

class InboxViewController : FlipsViewController, InboxViewDelegate, NewFlipViewControllerDelegate, InboxViewDataSource {
    
    private let DOWNLOAD_MESSAGE_FROM_PUSH_NOTIFICATION_MAX_NUMBER_OF_RETRIES: Int = 20 // aproximately 20 seconds
    private var downloadingMessageFromNotificationRetries: Int = 0
    
    private let ANIMATION_DURATION: NSTimeInterval = 0.25
    
    private var inboxView: InboxView!
    private var syncView: SyncView?
    private var roomIds: NSMutableOrderedSet = NSMutableOrderedSet()
    
    private var roomIdToShow: String?
    private var flipMessageIdToShow: String?
    
    private var syncMessageHistoryBlock: (() -> Void)?
    
    private var shouldInformPubnubNotConnected: Bool = false
    
    
    // MARK: - Initialization Methods
    
    init(roomID: String? = nil, flipMessageID: String? = nil) {
        super.init()
        self.roomIdToShow = roomID
        self.flipMessageIdToShow = flipMessageID
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - UIViewController overridden methods

    override func loadView() {
        var showOnboarding = false
        if (!OnboardingHelper.onboardingHasBeenShown()) {
            showOnboarding = true
        }
        
        inboxView = InboxView(showOnboarding: false) // Onboarding is disabled for now.
        inboxView.delegate = self
        inboxView.dataSource = self
        self.view = inboxView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resyncNotificationReceived:", name: RESYNC_INBOX_NOTIFICATION_NAME, object: nil)
        
        let didShowSyncView: Bool = DeviceHelper.sharedInstance.didShowSyncView()
        if (PubNubService.sharedInstance.isConnected() && !didShowSyncView) {
            self.setupSyncView()
        } else {
            // We don't need to show the Sync in this case. So, we need to mark it as seen.
            DeviceHelper.sharedInstance.setSyncViewShown(true)
            self.shouldInformPubnubNotConnected = true
            
            weak var weakSelf = self
            PubNubService.sharedInstance.subscribeOnMyChannels({ (success: Bool) -> Void in
                println("   InboxViewController subscribeOnMyChannels completion called")
                if (weakSelf?.roomIdToShow != nil) {
                    weakSelf?.openRoomForPushNotificationIfMessageReceived()
                } else {
                    weakSelf?.refreshRooms()
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inboxView.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onFlipMessageContentDownloadedNotificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "messageHistoryReceivedNotificationReceived:", name: PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onFlipMessageReceivedNotification:", name: FLIP_MESSAGE_RECEIVED_NOTIFICATION, object: nil)
        
        syncView?.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PUBNUB_DID_FETCH_MESSAGE_HISTORY, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: FLIP_MESSAGE_RECEIVED_NOTIFICATION, object: nil)
        
        self.roomIdToShow = nil
        self.flipMessageIdToShow = nil
        self.hideActivityIndicator()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.refreshRooms()
        
        if (PubNubService.sharedInstance.isConnected()) {
            self.shouldInformPubnubNotConnected = false
            self.syncMessageHistoryBlock?()
            
            if (self.roomIdToShow != nil) {
                if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
                    let alertView: UIAlertView = UIAlertView(title: nil, message: NSLocalizedString("Unable to retrieve message. Please check your connection and try again."), delegate: nil, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                } else {
                    self.showActivityIndicator(userInteractionEnabled: true, message: NSLocalizedString("Downloading message"))
                    self.openRoomForPushNotificationIfMessageReceived()
                }
            }
        } else {
            if (self.shouldInformPubnubNotConnected) {
                self.shouldInformPubnubNotConnected = false
                let alertView = UIAlertView(title: "", message: NSLocalizedString("Unable to reach the server. You can still use the app while we try to reconnect."), delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
        }
    }
    
    private func openRoomForPushNotificationIfMessageReceived() {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            self.hideActivityIndicator()
            self.roomIdToShow = nil
            self.flipMessageIdToShow = nil
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alertView: UIAlertView = UIAlertView(title: "", message: NSLocalizedString("Unable to retrieve message. Please check your connection and try again."), delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            })
        } else {
            if let roomID = self.roomIdToShow {
                QueueHelper.dispatchAsyncWithNewContext({ (newContext) -> Void in
                    var flipMessageAlreadyReceived = false
                    let flipMessageDataSource: FlipMessageDataSource = FlipMessageDataSource(context: newContext)
                    if let flipMessageID: String = self.flipMessageIdToShow {
                        if let flipMessage: FlipMessage = flipMessageDataSource.getFlipMessageById(flipMessageID) {
                            flipMessageAlreadyReceived = true
                        }
                        
                        if (flipMessageAlreadyReceived) {
                            self.openThreadViewControllerWithRoomID(roomID)
                            self.hideActivityIndicator()
                            self.roomIdToShow = nil
                            self.flipMessageIdToShow = nil
                        } else {
                            self.retryToOpenRoomForPushNotification()
                        }
                    } else if (flipMessageDataSource.flipMessagesForRoomID(roomID).count > 0) {
                        self.openThreadViewControllerWithRoomID(roomID)
                        self.hideActivityIndicator()
                        self.roomIdToShow = nil
                        self.flipMessageIdToShow = nil
                    }
                })
            }
        }
    }
    
    private func retryToOpenRoomForPushNotification() {
        let time = 1 * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            if let roomID = self.roomIdToShow { // Just to make sure that the user didn't close this screen.
                self.downloadingMessageFromNotificationRetries++
                if (self.downloadingMessageFromNotificationRetries < self.DOWNLOAD_MESSAGE_FROM_PUSH_NOTIFICATION_MAX_NUMBER_OF_RETRIES) {
                    self.openRoomForPushNotificationIfMessageReceived()
                } else {
                    self.hideActivityIndicator()
                    self.roomIdToShow = nil
                    self.flipMessageIdToShow = nil
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        var alertView = UIAlertView(title: nil, message: NSLocalizedString("Download failed. Please try again later."), delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    })
                }
            }
        })
    }
    
    func imageForView() -> UIImage {
        UIGraphicsBeginImageContext(view.bounds.size)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setupSyncView() {
        if let views = NSBundle.mainBundle().loadNibNamed("SyncView", owner: self, options: nil) {
            if let syncView = views[0] as? SyncView {
                self.syncView = syncView
                self.syncView?.hidden = true
                
                self.view.addSubview(self.syncView!)
                syncView.mas_makeConstraints { (make) -> Void in
                    make.top.equalTo()(self.view)
                    make.trailing.equalTo()(self.view)
                    make.leading.equalTo()(self.view)
                }
                
                self.syncMessageHistoryBlock = { () -> Void in
                    self.syncView?.image = self.imageForView()
                    self.syncView?.alpha = 0
                    self.syncView?.hidden = false
                    
                    PubNubService.sharedInstance.subscribeOnMyChannels({ (success: Bool) -> Void in
                        DeviceHelper.sharedInstance.setSyncViewShown(true)
                        self.syncMessageHistoryBlock = nil
                        
                        self.refreshRooms()
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            UIView.animateWithDuration(self.ANIMATION_DURATION, animations: { () -> Void in
                                self.syncView?.alpha = 0
                                return
                            }, completion: { (finished: Bool) -> Void in
                                self.syncView?.hidden = true
                                return
                            })
                        })
                    }, progress: { (received: Int, total: Int) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.syncView?.setDownloadCount(received, ofTotal: total)
                            if (self.syncView?.alpha == 0) {
                                UIView.animateWithDuration(self.ANIMATION_DURATION, animations: { () -> Void in
                                    self.syncView?.alpha = 1
                                    return
                                })
                            }
                        })
                    })
                }
            }
        }
    }
    
    
    // MARK: - InboxViewDelegate
    
    func inboxViewDidTapComposeButton(inboxView : InboxView) {
        var newFlipViewNavigationController = NewFlipViewController.instantiateNavigationController()
        var viewController = newFlipViewNavigationController.topViewController as NewFlipViewController
        viewController.delegate = self
        self.navigationController?.presentViewController(newFlipViewNavigationController, animated: true, completion: nil)
    }
    
    func inboxViewDidTapSettingsButton(inboxView : InboxView) {
        var settingsViewController = SettingsViewController()
        var navigationController = FlipsUINavigationController(rootViewController: settingsViewController)
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxViewDidTapBuilderButton(inboxView : InboxView) {
        var builderViewController = BuilderViewController()
        self.navigationController?.pushViewController(builderViewController, animated:true)
    }
    
    func inboxView(inboxView : InboxView, didTapAtItemAtIndex index: Int) {
        var roomID: String!
        roomID = self.roomIds.objectAtIndex(index) as String
        self.openThreadViewControllerWithRoomID(roomID)
    }
    
    
    // MARK: - Room Handlers
    
    private func refreshRooms() {
        QueueHelper.dispatchAsyncWithNewContext { (newContext) -> Void in
            let roomDataSource = RoomDataSource(context: newContext)
            let rooms = roomDataSource.getMyRoomsOrderedByMostRecentMessage()
            
            var shouldReloadTableView: Bool = false
            if (self.roomIds.count != rooms.count) {
                shouldReloadTableView = true
            } else {
                for (var i: Int = 0; i < rooms.count; i++) {
                    if (self.roomIds[i] as NSString != rooms[i].roomID) {
                        shouldReloadTableView = true
                    }
                }
            }
            
            if (!shouldReloadTableView) {
                // reload cells internally
                self.inboxView.reloadCells()
            } else {
                var ids: Array<String> = Array<String>()
                for room in rooms {
                    ids.append(room.roomID)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.roomIds.removeAllObjects()
                    self.roomIds.addObjectsFromArray(ids)
                    self.inboxView.reloadData()
                })
            }
        }
    }
    
    private func openThreadViewControllerWithRoomID(roomID: String) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let roomDataSource = RoomDataSource()
            let room = roomDataSource.retrieveRoomWithId(roomID)
            
            let chatViewController: ChatViewController = ChatViewController(room: room)
            self.navigationController?.pushViewController(chatViewController, animated: true)

            // log thread viewed analytics
            var hasUnreadMessages: Bool = false
            
            if let roomFlipMessages: NSOrderedSet = room.valueForKey("flipMessages") as? NSOrderedSet {
                for (var i: Int = roomFlipMessages.count - 1; i >= 0; i--) {
                    let flipMessage: FlipMessage = roomFlipMessages[i] as FlipMessage
                    if (flipMessage.notRead.boolValue) {
                        hasUnreadMessages = true
                        break
                    }
                }
            }

            AnalyticsService.logThreadViewed(hasUnreadMessages)
        })
    }
    
    
    // MARK: - Messages Notification Handler

    func messageHistoryReceivedNotificationReceived(notification: NSNotification) {
        self.refreshRooms()
    }
    
    func onFlipMessageReceivedNotification(notification: NSNotification) {
        self.refreshRooms()
        if let userInfo: Dictionary<String, String> = notification.userInfo as? Dictionary<String, String> {
            var receivedFlipMessageID: String = userInfo[FLIP_MESSAGE_RECEIVED_NOTIFICATION_PARAM_MESSAGE_KEY]!
            
            if let roomID: String = self.roomIdToShow {
                if let flipMessageID: String = self.flipMessageIdToShow {
                    if (flipMessageID == receivedFlipMessageID) {
                        self.hideActivityIndicator()
                        self.roomIdToShow = nil
                        self.flipMessageIdToShow = nil
                        self.openThreadViewControllerWithRoomID(roomID)
                    }
                } else {
                    self.hideActivityIndicator()
                    self.roomIdToShow = nil
                    self.flipMessageIdToShow = nil
                    self.openThreadViewControllerWithRoomID(roomID)
                }
            }
        }
    }

    func onFlipMessageContentDownloadedNotificationReceived(notification: NSNotification) {
        self.refreshRooms()
    }
    
    func resyncNotificationReceived(notification: NSNotification) {
        PersistentManager.sharedInstance.syncUserData({ (success, flipError) -> Void in
            self.syncMessageHistoryBlock?()
            return
        })
    }
    
    
    // MARK: - NewFlipViewControllerDelegate
    
    func newFlipViewController(viewController: NewFlipViewController, didSendMessageToRoom roomID: String) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            let roomDataSource = RoomDataSource()
            let room = roomDataSource.retrieveRoomWithId(roomID)
            self.navigationController?.pushViewController(ChatViewController(room: room), animated: true)
        })
    }
    
    
    // MARK: - InboxViewDataSource

    func numberOfRooms() -> Int {
        return self.roomIds.count
    }
    
    func inboxView(inboxView: InboxView, roomAtIndex index: Int) -> String {
        return self.roomIds.objectAtIndex(index) as String
    }
    
    func inboxView(inboxView: InboxView, didRemoveRoomAtIndex index: Int) {
        self.roomIds.removeObjectAtIndex(index)
    }
    
    
    // MARK: - Push Notification Methods
    
    func prepareToLoadPushNotificationForRoomId(roomId: String, andFlipMessageId flipMessageId: String?) {
        self.roomIdToShow = roomId
        self.flipMessageIdToShow = flipMessageId
        self.showActivityIndicator(userInteractionEnabled: true)
    }
}