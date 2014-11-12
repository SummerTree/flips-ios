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
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let ALREADY_SEEN_INTRODUCTION_KEY = "builder.introduction.watched"
    
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
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let alreadySeenIntroduction = userDefaults.objectForKey(ALREADY_SEEN_INTRODUCTION_KEY) as Bool?
        if (alreadySeenIntroduction == nil || !alreadySeenIntroduction!) {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            builderView.showIntroduction()
            userDefaults.setObject(true, forKey: ALREADY_SEEN_INTRODUCTION_KEY)
        }
    }
    
    func builderViewDidTapOkSweetButton(builderView: BuilderView!) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}