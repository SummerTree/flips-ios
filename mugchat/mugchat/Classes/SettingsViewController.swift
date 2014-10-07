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
    
    let settingsView = SettingsView()
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = settingsView
        self.settingsView.delegate = self
        self.setupWhiteNavBarWithCloseButton(NSLocalizedString("Settings", comment: "Settings"))
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    // MARK: - Settings View Delegate
    func settingsViewDidTapLogOutButton(settingsView: SettingsView) {
        AuthenticationHelper.sharedInstance.userInSession = nil
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
        FBSession.setActiveSession(nil)
        
        var navigationController: UINavigationController = self.presentingViewController as UINavigationController
        navigationController.popViewControllerAnimated(false)
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
}
