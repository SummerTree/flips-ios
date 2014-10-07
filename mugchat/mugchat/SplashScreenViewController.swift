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

class SplashScreenViewController: UIViewController, SplashScreenViewDelegate {
    
    let splashScreenView = SplashScreenView()
    
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        splashScreenView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashScreenView.delegate = self
        
        self.view = splashScreenView
    }
    
    
    // MARK: SplashScreenViewDelegate methods
    
    func splashScreenViewAttemptLoginWithFacebook(sender: SplashScreenView) {
        var success = FBSession.openActiveSessionWithAllowLoginUI(false)
        println("User is already authenticated with Facebook? \(success)")
        if (success) {
            openInboxViewController()
        }
    }
    
    func splashScreenViewAttemptLogin(sender: SplashScreenView) {
        openLoginViewController()
    }
    
    private func openInboxViewController() {
        var inboxViewController = InboxViewController()
        self.navigationController?.pushViewController(inboxViewController, animated: true)
    }
    
    private func openLoginViewController() {
        var loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}