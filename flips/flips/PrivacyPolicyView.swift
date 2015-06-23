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

import UIKit

class PrivacyPolicyView: FlipsWebView {
    
    let PRIVACY_POLICY_URL = "http://www.flipsapp.com/privacy.html"
    
    convenience init() {
        self.init(URL: "http://www.flipsapp.com/privacy.html")
    }
    
    
    // MARK: Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
