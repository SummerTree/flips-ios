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

class ChangeNumberInfoViewController : FlipsViewController, ChangeNumberInfoViewDelegate {
    
    private var changeNumberInfoView: ChangeNumberInfoView!
    
    override func loadView() {
        changeNumberInfoView = ChangeNumberInfoView()
        changeNumberInfoView.delegate = self
        
        self.view = changeNumberInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteNavBarWithBackButton("Change Number")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    // MARK: - ChangeNumberViewDelegate
    
    func changeNumberInfoViewDidTapNextButton(changeNumberInfoView: ChangeNumberInfoView!) {
        let changeNumberInputPhoneViewController = ChangeNumberInputPhoneViewController()
        self.navigationController?.pushViewController(changeNumberInputPhoneViewController, animated: true)
    }
}