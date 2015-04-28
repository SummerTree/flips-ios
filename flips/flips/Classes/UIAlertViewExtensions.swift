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

extension UIAlertView {
    class func showUnableToLoadFlip() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let alertView = UIAlertView(title: NSLocalizedString("Flip Error"),
                message: NSLocalizedString("Unable to load Flip."),
                delegate: nil,
                cancelButtonTitle: LocalizedString.OK)
            alertView.show()
        })
    }
}