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

let USER_DATA_SYNCED_NOTIFICATION_NAME: String = "user_data_synced_notification"

class SettingsViewController : FlipsViewController, SettingsViewDelegate, TutorialViewControllerDelegate {
    
    private let FLIPSBOYS_CHAT_TITLE: String = "Team Flips"
    
    private var settingsView: SettingsView!

    // MARK: - Overridden Methods
    
    override func loadView() {
        super.loadView()
        self.settingsView = SettingsView()
        self.settingsView.delegate = self
        self.view = settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupWhiteNavBarWithCloseButton(NSLocalizedString("Settings", comment: "Settings"))
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.settingsView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.settingsView.viewWillAppear()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDataSyncedNotificationReceived:", name: USER_DATA_SYNCED_NOTIFICATION_NAME, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.settingsView.viewDidAppear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: USER_DATA_SYNCED_NOTIFICATION_NAME, object: nil)
    }

    
    
    // MARK: - Settings View Delegate
    
    func settingsViewMakeConstraintToNavigationBarBottom(tableView: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        tableView.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
    
    func settingsViewDidTapChangeProfile(settingsView: SettingsView) {
        var updateUserProfileViewController = UpdateUserProfileViewController()
        self.navigationController?.pushViewController(updateUserProfileViewController, animated: true)
    }
    
    func settingsViewDidTapAbout(settingsView: SettingsView) {
        var aboutViewController = AboutViewController()
        self.navigationController?.pushViewController(aboutViewController, animated: true)
    }
    
    func settingsViewDidTapTermsOfUse(settingsView: SettingsView) {
        var termsOfUseViewController = TermsOfUseViewController()
        self.navigationController?.pushViewController(termsOfUseViewController, animated: true)
    }
    
    func settingsViewDidTapPrivacyPolicy(settingsView: SettingsView) {
        var privacyPolicyViewController = PrivacyPolicyViewController()
        self.navigationController?.pushViewController(privacyPolicyViewController, animated: true)
    }
    
    func settingsViewDidTapSendFeedback(settingsView: SettingsView) {
        let roomDataSource = RoomDataSource()
        let teamFlipsRoom: Room? = roomDataSource.getTeamFlipsRoom()
        
        if let room = teamFlipsRoom {
            var chatViewController = ChatViewController(room: room)
            self.navigationController?.pushViewController(chatViewController, animated: true)
        } else {
            var alertMessage = UIAlertView(title: LocalizedString.ERROR, message: LocalizedString.TEAMFLIPS_ROOM_NOT_FOUND, delegate: nil, cancelButtonTitle: LocalizedString.OK)
            alertMessage.show()
        }
    }
    
    func settingsViewDidTapChangePhoneNumber(settingsView: SettingsView) {
        var changeNumberInfoViewController = ChangeNumberInfoViewController()
        self.navigationController?.pushViewController(changeNumberInfoViewController, animated: true)
    }
    
    func settingsViewDidTapImportContacts(settingsView: SettingsView) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            if let user = User.loggedUser()? {
                let userId = user.userID
                SessionService.sharedInstance.checkSession(userId, { (success) -> Void in
                    let importContactViewController = ImportContactViewController()
                    let navigationController = UINavigationController(rootViewController: importContactViewController)
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }, failure: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let flipError: FlipError = error {
                            let alertMessage = UIAlertView(title: flipError.error, message: flipError.details, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                            alertMessage.show()
                        }
                        self.settingsView.viewWillAppear()
                    })
                })
            }
        })
    }
    
    func settingsViewDidTapTutorialButton(settingsView: SettingsView) {
        var tutorialViewController = TutorialViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        tutorialViewController.viewDelegate = self

        self.navigationController?.pushViewController(tutorialViewController, animated: true)
    }
    
    func settingsViewDidTapLogOutButton(settingsView: SettingsView) {
        var userFirstName: String? = nil
        var facebookUser = false
        if (User.loggedUser()?.facebookID != nil) {
            let user: User = User.loggedUser()!
            userFirstName = user.firstName
            facebookUser = true
        }
        
        AuthenticationHelper.sharedInstance.logout()
        
        var navigationController: UINavigationController = self.presentingViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion:nil)
        
        var userInfo: Dictionary<String, AnyObject> = [LOGOUT_NOTIFICATION_PARAM_FACEBOOK_USER_KEY: facebookUser]
        
        if (userFirstName != nil) {
            userInfo.updateValue(userFirstName!, forKey: LOGOUT_NOTIFICATION_PARAM_FIRST_NAME_KEY)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(LOGOUT_NOTIFICATION_NAME, object: nil, userInfo: userInfo)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    func userDataSyncedNotificationReceived(notification: NSNotification) {
        self.settingsView.updateUserProfileInfo()
    }


    // MARK: - TutorialViewControllerDelegate

    func tutorialViewControllerDidTapCloseButton(viewController: TutorialViewController!) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
