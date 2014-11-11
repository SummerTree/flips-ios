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

class ChangeNumberInputPhoneViewController : MugChatViewController, ChangeNumberInputPhoneViewDelegate {
    
    private var changeNumberInputPhoneView: ChangeNumberInputPhoneView!
    
    override func loadView() {
        changeNumberInputPhoneView = ChangeNumberInputPhoneView()
        changeNumberInputPhoneView.delegate = self
        
        self.view = changeNumberInputPhoneView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteNavBarWithBackButton("Change Number")
        self.changeNumberInputPhoneView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        changeNumberInputPhoneView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    
    // MARK: - ChangeNumberInputPhoneViewDelegate
    
    func makeConstraintToNavigationBarBottom(view: UIView!) {
        var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
        
        view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(topLayoutGuide.mas_bottom)
            return ()
        }
    }
    
    func changeNumberInputPhoneView(view: ChangeNumberInputPhoneView, didFinishTypingMobileNumber phone: String) {
        println("finished with \(phone)")
    }
}