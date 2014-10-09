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
    
    override init() {
        super.init()
        
        let menuController = UIMenuController.sharedMenuController()
        let lookupMenu = UIMenuItem(title: "Join", action: "joinStrings")
        menuController.menuItems = NSArray(array: [lookupMenu])
        
        menuController.update();
        
        // This makes the menu item visible.
        menuController.setMenuVisible(true, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Overide, disable the "Define" contextual menu item
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
            //TODO
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func joinStrings() {
        println("Join............");
    }
    
}
