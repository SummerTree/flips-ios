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


class InboxViewController : FlipsViewController, InboxViewDelegate, NewFlipViewControllerDelegate, InboxViewDataSource {

    private var inboxView: InboxView!
    private var roomIds: [String]!
    
    
    // MARK: - UIViewController overridden methods

    override func loadView() {
        var showOnboarding = false
        if (!OnboardingHelper.onboardingHasBeenShown()) {
            showOnboarding = true
        }

//        inboxView = InboxView(showOnboarding: showOnboarding) // TODO: remove line below and uncoment this. I don't wanna block anyone when I merge it to master.
        inboxView = InboxView(showOnboarding: false)
        inboxView.delegate = self
        inboxView.dataSource = self
        self.view = inboxView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.roomIds = Array<String>()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inboxView.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshRooms()
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
        var navigationController = UINavigationController(rootViewController: settingsViewController)
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxViewDidTapBuilderButton(inboxView : InboxView) {
        var builderViewController = BuilderViewController()
        self.navigationController?.pushViewController(builderViewController, animated:true)
    }
    
    func inboxView(inboxView : InboxView, didTapAtItemAtIndex index: Int) {
        let roomID = roomIds[index]
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.retrieveRoomWithId(roomID)
        self.navigationController?.pushViewController(ChatViewController(chatTitle: room.roomName(), roomID: roomID), animated: true)
    }
    
    
    // MARK: - Room Handlers
    
    private func refreshRooms() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let roomDataSource = RoomDataSource()
            let rooms = roomDataSource.getMyRoomsOrderedByOldestNotReadMessage()
            self.roomIds.removeAll(keepCapacity: false)
            for room in rooms {
                self.roomIds.append(room.roomID)
            }
            self.inboxView.reloadData()
        })
    }
    
    
    // MARK: - Messages Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var flipID = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY] as String
        let flipDataSource = FlipDataSource()
        let flip = flipDataSource.retrieveFlipWithId(flipID)

        if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
            println("Download failed for flip: \(flip.flipID)")
            // TODO: show download fail state
        } else {
            if (flip.hasAllContentDownloaded()) {
                self.refreshRooms()
            }
        }
    }
    
    
    // MARK: - NewFlipViewControllerDelegate
    
    func newFlipViewController(viewController: NewFlipViewController, didSendMessageToRoom roomID: String) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            let roomDataSource = RoomDataSource()
            let room = roomDataSource.retrieveRoomWithId(roomID)
            self.navigationController?.pushViewController(ChatViewController(chatTitle: room.roomName(), roomID: roomID), animated: true)
        })
    }
    
    
    // MARK: - InboxViewDataSource

    func numberOfRooms() -> Int {
        return self.roomIds.count
    }
    
    func inboxView(inboxView: InboxView, roomAtIndex index: Int) -> String {
        return self.roomIds[index]
    }
    
    func inboxView(inboxView: InboxView, didRemoveRoomAtIndex index: Int) {
        self.roomIds.removeAtIndex(index)
    }
}

