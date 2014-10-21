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
        
        // Just for test. Can be removed.
        let loggedUserNameLabel = UILabel()
        loggedUserNameLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h3)
        loggedUserNameLabel.textColor = UIColor.mugOrange()
        loggedUserNameLabel.numberOfLines = 2
        loggedUserNameLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(loggedUserNameLabel)
        
        loggedUserNameLabel.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self.view)
            make.trailing.equalTo()(self.view)
            make.center.equalTo()(self.view)
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let loggedUser: User! = User.loggedUser()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (loggedUser != nil) {
                    loggedUserNameLabel.text = "Logged as \n\(loggedUser.firstName) \(loggedUser.lastName)"
                }
            })
        })
    }
    
    
    // MARK: - Settings View Delegate
    
    func settingsViewDidTapLogOutButton(settingsView: SettingsView) {
        AuthenticationHelper.sharedInstance.logout()
        
        var navigationController: UINavigationController = self.presentingViewController as UINavigationController
        navigationController.popToRootViewControllerAnimated(true)
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
