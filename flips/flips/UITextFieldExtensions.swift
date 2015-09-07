//
//  File.swift
//  flips
//
//  Created by Noah Labhart on 9/4/15.
//
//

import UIKit

extension UITextField {
    
    func showDoneButton(target: AnyObject?, action: Selector) {
        var screenSize = UIScreen.mainScreen().bounds
        var showFrame = CGRectMake(0,0,screenSize.size.width, 50)
        
        var numberToolbar = UIToolbar()
        numberToolbar.barStyle = .BlackTranslucent
        numberToolbar.items = [UIBarButtonItem(title: "Done", style: .Done, target: target, action: action)]
        numberToolbar.sizeToFit()
        
        self.inputAccessoryView = numberToolbar
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            numberToolbar.frame = showFrame
        })
    }
    
    func hideDoneButton() {
        var screenSize = UIScreen.mainScreen().bounds
        var hideFrame = CGRectMake(0,60,screenSize.size.width, 50)
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.inputAccessoryView!.frame = hideFrame
//            self.inputAccessoryView! = nil
        })
    }
}