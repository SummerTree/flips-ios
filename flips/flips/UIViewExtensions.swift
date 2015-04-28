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

extension UIView {
    
    func animateConstraintWithDuration(duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.layoutIfNeeded()
        })
    }
    
    func snapshot() -> UIImage! {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
