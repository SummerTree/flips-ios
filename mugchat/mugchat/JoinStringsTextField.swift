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

class JoinStringsTextField : UITextField {
    
    var joinStringsTextFieldDelegate : JoinStringsTextFieldDelegate?
    
    override init() {
        super.init()
        
        let menuController = UIMenuController.sharedMenuController()
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Join", comment: "Join"), action: "joinStrings")
        menuController.menuItems = NSArray(array: [lookupMenu])
        
        menuController.update();
        
        menuController.setMenuVisible(true, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func joinStrings() {
        var selectedRange: UITextRange = self.selectedTextRange!
        var selectedText = self.textInRange(selectedRange)
        self.joinStringsTextFieldDelegate?.didJoinedWords(self, finalString: selectedText)
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool     {
        
        if action == "cut:" {
            return false;
        }
            
        else if action == "copy:" {
            return false;
        }
            
        else if action == "paste:" {
            return false;
        }
            
        else if action == "_define:" {
            return false;
        }
        
        else if action == "Join" {
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
}

protocol JoinStringsTextFieldDelegate {
    
    func didJoinedWords(joinStringsTextField: JoinStringsTextField!, finalString: String!)
    
}
