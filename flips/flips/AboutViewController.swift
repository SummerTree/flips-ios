//
// Copyright 2015 ArcTouch, Inc.
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

class AboutViewController : FlipsViewController, AboutViewDelegate {
    
    private var aboutView: AboutView!

    override func loadView() {
        aboutView = AboutView()
        aboutView.delegate = self
        
        self.view = aboutView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aboutView.viewDidLoad()
    }
    
    
    // MARK: - AboutViewDelegate
    
    func aboutViewMakeConstraintToNavigationBarBottom(logoContainer: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        logoContainer.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_topLayoutGuideBottom)
        }
    }
    
    func aboutViewDidTapBackButton(aboutView: AboutView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}