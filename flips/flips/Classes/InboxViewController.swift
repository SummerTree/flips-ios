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

class InboxViewController : FlipsViewController, InboxViewDelegate, NewFlipViewControllerDelegate, InboxViewDataSource, UserDataSourceDelegate {
    var userDataSource: UserDataSource? {
        didSet {
            if userDataSource != nil {
                userDataSource?.delegate = self
            }
        }
    }
    
    private let animationDuration: NSTimeInterval = 0.25
    
    private var inboxView: InboxView!
    private var syncView: SyncView!
    private var roomIds: NSMutableOrderedSet = NSMutableOrderedSet()
    
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
        
        setupSyncView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.inboxView.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "notificationReceived:", name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
        
        syncView.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: DOWNLOAD_FINISHED_NOTIFICATION_NAME, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let userDataSource = self.userDataSource {
            if userDataSource.isDownloadingFlips == true {
                syncView.image = imageForView()
                syncView.setDownloadCount(1, ofTotal: userDataSource.flipsDownloadCount.value)
                syncView.alpha = 0
                syncView.hidden = false
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    self.syncView.alpha = 1
                })
            }
        }
        
        self.refreshRooms()
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
                syncView.hidden = true
                
                self.syncView = syncView
                
                view.addSubview(syncView)
                
                syncView.mas_makeConstraints { (make) -> Void in
                    make.top.equalTo()(self.view)
                    make.trailing.equalTo()(self.view)
                    make.leading.equalTo()(self.view)
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
        var navigationController = UINavigationController(rootViewController: settingsViewController)
        
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
        let roomDataSource = RoomDataSource()
        let room = roomDataSource.retrieveRoomWithId(roomID)
        self.navigationController?.pushViewController(ChatViewController(chatTitle: room.roomName(), roomID: roomID), animated: true)
    }
    
    
    // MARK: - Room Handlers
    
    private func refreshRooms() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let roomDataSource = RoomDataSource()
            let rooms = roomDataSource.getMyRoomsOrderedByOldestNotReadMessage()
            for (index, room) in enumerate(rooms) {
                if (self.roomIds.containsObject(room.roomID)) {
                    let indexSet = NSMutableIndexSet()
                    indexSet.addIndex(self.roomIds.indexOfObject(room.roomID))
                    self.roomIds.moveObjectsAtIndexes(indexSet, toIndex: index)
                } else {
                    self.roomIds.addObject(room.roomID)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.inboxView.reloadData()
            })
        })
    }
    
    
    // MARK: - Messages Notification Handler
    
    func notificationReceived(notification: NSNotification) {
        var userInfo: Dictionary = notification.userInfo!
        var flipID = userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FLIP_KEY] as String
        let flipDataSource = FlipDataSource()
        if let flip = flipDataSource.retrieveFlipWithId(flipID) {
            if (userInfo[DOWNLOAD_FINISHED_NOTIFICATION_PARAM_FAIL_KEY] != nil) {
                println("Download failed for flip: \(flip.flipID)")
                // TODO: show download fail state
            } else {
                self.refreshRooms()
            }
        } else {
            UIAlertView.showUnableToLoadFlip()
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
        return self.roomIds.objectAtIndex(index) as String
    }
    
    func inboxView(inboxView: InboxView, didRemoveRoomAtIndex index: Int) {
        self.roomIds.removeObjectAtIndex(index)
    }
    
    
    // MARK: - UserDataSourceDelegate
    
    func userDataSource(userDataSource: UserDataSource, didDownloadFlip: Flip) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // update sync counter
            self.syncView.setDownloadCount(userDataSource.flipsDownloadCounter.value, ofTotal: userDataSource.flipsDownloadCount.value)
        })
    }
    
    func userDataSourceDidFinishFlipsDownload(userDataSource: UserDataSource) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // dismiss sync view
            UIView.animateWithDuration(self.animationDuration, animations: { () -> Void in
                self.syncView.alpha = 0
            }, completion: { (done) -> Void in
                self.syncView.hidden = true
                self.syncView.alpha = 1
            })
        })
    }
}