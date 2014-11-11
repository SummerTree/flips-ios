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

class ChangeNumberVerificationCodeView: VerificationCodeView {
    
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    
    var verificationCodeDelegate: ChangeNumberVerificationCodeViewDelegate?
    
    override func addNavigationBar() {
        // do nothing
    }
    
    override func createNavigationBarConstraints() {
        // do nothing
    }
    
    override func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardOnScreen:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    }
    
    override func createHintViewConstraints() {
        hintView.mas_updateConstraints { (make) in
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        self.verificationCodeDelegate?.makeConstraintToNavigationBarBottom(self.hintView)
    }
    
    override func defineBackgroundColor() -> UIColor {
        return UIColor.deepSea()
    }
}

protocol ChangeNumberVerificationCodeViewDelegate {
    func makeConstraintToNavigationBarBottom(view: UIView!)
}