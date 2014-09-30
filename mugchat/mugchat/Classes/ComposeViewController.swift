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

class ComposeViewController : MugChatViewController, CustomNavigationBarDelegate {
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Example
        // self.setupWhiteNavBarWithCloseButton(NSLocalizedString("Compose", comment: "Compose"))
        // self.view.backgroundColor = UIColor.whiteColor()
        
        // Example
        // var navBar = CustomNavigationBar.CustomNormalNavigationBar("Compose", showBackButton: true)
        
        // Example
        var navBar = CustomNavigationBar.CustomLargeNavigationBar(UIImage(named: "tmp_homer"), showBackButton: true, showSaveButton: true)
        
        navBar.delegate = self
        self.view.addSubview(navBar)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        navBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.view)
            make.leading.equalTo()(self.view)
            make.trailing.equalTo()(self.view)
            make.height.equalTo()(navBar.frame.size.height)
        }
    }
    
    
    // MARK: -
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        // Do nothing
        println("customNavigationBarDidTapRightButton")
    }
    
}