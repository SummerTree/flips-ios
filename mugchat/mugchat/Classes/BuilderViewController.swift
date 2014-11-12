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

class BuilderViewController : MugChatViewController, BuilderViewDelegate {
    
    private var builderView: BuilderView!
    
    override func loadView() {
        self.builderView = BuilderView()
        self.builderView.delegate = self
        self.view = builderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.deepSea()
        setupWhiteNavBarWithBackButton("Builder")
        self.setNeedsStatusBarAppearanceUpdate()
        self.builderView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        builderView.viewDidAppear()
    }
    
    func builderViewDidTapOkSweetButton(builderView: BuilderView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}