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

class SettingsViewController : MugChatViewController, SettingsViewDelegate {
    
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
        println("settingsViewDidTapSendFeedback")
    }
    
    func settingsViewDidTapChangePhoneNumber(settingsView: SettingsView) {
        println("settingsViewDidTapChangePhoneNumber")
    }
    
    func settingsViewDidTapImportContacts(settingsView: SettingsView) {
        println("settingsViewDidTapImportContacts")
    }
    
    func settingsViewDidTapLogOutButton(settingsView: SettingsView) {
        AuthenticationHelper.sharedInstance.logout()
        
        var navigationController: UINavigationController = self.presentingViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
}
