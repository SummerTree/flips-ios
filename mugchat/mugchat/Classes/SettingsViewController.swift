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
        
        self.setupWhiteNavBarWithCloseButton(NSLocalizedString("Settings", comment: "Settings"))
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.settingsView.viewWillAppear()
    }
    
    
    // MARK: - Settings View Delegate
    
    func settingsViewDidTapLogOutButton(settingsView: SettingsView) {
        AuthenticationHelper.sharedInstance.logout()
        
        var navigationController: UINavigationController = self.presentingViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func settingsViewDidTapAbout(settingsView: SettingsView) {
        var aboutViewController = AboutViewController()
        self.navigationController?.pushViewController(aboutViewController, animated: true)
    }
    
    func settingsViewDidTapChangeProfile(settingsView: SettingsView) {
        println("settingsViewDidTapChangeProfile")
    }
    
    func settingsViewDidTapImportContacts(settingsView: SettingsView) {
        println("settingsViewDidTapImportContacts")
    }
    
    func settingsViewDidTapPhoneNumber(settingsView: SettingsView) {
        println("settingsViewDidTapPhoneNumber")
    }
    
    func settingsViewDidTapPrivacyPolicy(settingsView: SettingsView) {
        println("settingsViewDidTapPrivacyPolicy")
    }
    
    func settingsViewDidTapSendFeedback(settingsView: SettingsView) {
        println("settingsViewDidTapSendFeedback")
    }
    
    func settingsViewDidTapTermsOfUse(settingsView: SettingsView) {
        println("settingsViewDidTapTermsOfUse")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
}
