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

import UIKit

class TermsOfUseViewController: UIViewController {

    var termsOfUseView: TermsOfUseView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        termsOfUseView = TermsOfUseView()

        self.view = termsOfUseView
        
        self.setupWhiteNavBarWithBackButton(NSLocalizedString("Terms of Use", comment: "Terms of Use"))
    }
    
}
