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
    
    // MARK: - UIViewController overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.initInboxView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (AuthenticationHelper.sharedInstance.userInSession != nil) {
            println("inbox - viewDidAppear")
            
            var userDataSource = UserDataSource()
            var contactDataSource = ContactDataSource()
            var mugDataSource = MugDataSource()
            var roomDataSource = RoomDataSource()
            
            var myUserContacts = userDataSource.getMyUserContacts()
            println("My Contacts on MugChat(\(myUserContacts.count))")
            for user in myUserContacts {
                println("   \(user.firstName) \(user.lastName)")
            }
            
            var myContacts = contactDataSource.getMyContacts()
            println("   ")
            println("My Contacts not MugChat(\(myContacts.count))")
            for contact in myContacts {
                println("   \(contact.firstName) \(contact.lastName)")
            }
            
            println("   ")
            var myRooms = roomDataSource.getMyRooms()
            println("My rooms (\(myRooms.count))")
            for room in myRooms {
                println("   RoomID: \(room.roomID)")
                println("     Participants(\(room.participants.count))")
                for user in room.participants {
                    println("   \(user.firstName) \(user.lastName)")
                }
                println("    Messages (\(room.mugMessages.count))")
                for (var i = 0; i < room.mugMessages.count; i++) {
                    var mugMessage: MugMessage = room.mugMessages.objectAtIndex(i) as MugMessage
                    println("       from: \(mugMessage.from.firstName)")
                }
            }
            
            println("   ")
            var myMugs = mugDataSource.getMyMugs()
            println("My Mugs (\(myMugs.count))")
            for mug in myMugs {
                Downloader.sharedInstance.downloadDataForMug(mug, isTemporary: true) // should be false. But since it is only for tests lets use it as temporary
                println("   id: \(mug.mugID)")
                println("   backgroundContentType: \(mug.backgroundContentType)")
            }
            
            println("   ")
            var myMugsFiltered = mugDataSource.getMyMugsForWords(["I", "Love"])
            println("My Mugs Filtered (\(myMugsFiltered.count))")
            for (word, mugs) in myMugsFiltered {
                println("   \(word) count: \(mugs.count)")
            }
            println("   ")
            println("   ")
        }
    }
    
    
    //MARK: - Private methods
    
    private func initInboxView() {
        var inboxView = InboxView()
        inboxView.delegate = self
        self.view.addSubview(inboxView)
        
        inboxView.mas_makeConstraints { (maker) -> Void in
            maker.top.equalTo()(self.view)
            maker.bottom.equalTo()(self.view)
            maker.leading.equalTo()(self.view)
            maker.trailing.equalTo()(self.view)
        }
    }
    
    
    // MARK: - InboxViewDelegate
    
    func inboxViewDidTapComposeButton(inboxView : InboxView) {
        self.navigationController?.pushViewController(ComposeViewController(), animated: true)
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
}

