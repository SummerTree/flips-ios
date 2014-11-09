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

class InboxViewController : MugChatViewController, InboxViewDelegate {

    var inboxView: InboxView!
    var roomDataSource: RoomDataSource!
    
    // MARK: - UIViewController overridden methods

    override func loadView() {
        inboxView = InboxView()
        inboxView.delegate = self
        self.view = inboxView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        roomDataSource = RoomDataSource()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
//        self.navigationController?.pushViewController(ComposeViewController(), animated: true)
    }
    
    func inboxViewDidTapSettingsButton(inboxView : InboxView) {
        var settingsViewController = SettingsViewController()
        var navigationController = UINavigationController(rootViewController: settingsViewController)
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxViewDidTapBuilderButton(inboxView : InboxView) {
        var builderViewController = BuilderViewController()
        var navigationController = UINavigationController(rootViewController: builderViewController)
        
        builderViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxView(inboxView : InboxView, didTapAtItemAtIndex index: Int) {
        println("tap at cell \(index)")
        self.navigationController?.pushViewController(ChatViewController(chatTitle: "MugBoys"), animated: true)
    }
    
    
    // MARK: - Room Handlers
    
    private func refreshRooms() {
        inboxView.setRooms(roomDataSource.getMyRoomsOrderedByOldestNotReadMessage())
    }
    
    
    // MARK: - Messages Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var mug = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_MUG_KEY] as Mug
        if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
            println("Download failed for mug: \(mug.mugID)")
            // TODO: show download fail state
        } else {
            if (mug.hasAllContentDownloaded()) {
                self.refreshRooms()
            }
        }
    }
}

