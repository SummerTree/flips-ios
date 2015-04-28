
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

let FlipsErrorDomain = "FlipsErrorDomain"

enum FlipsErrorCode: Int {
    case BadFlipID = 1
}

extension NSError {
    class func flipsError(#code: FlipsErrorCode, userInfo: [NSObject : AnyObject]?) -> NSError {
        return NSError(domain: FlipsErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
    
    var localizedFailureReasonOrDescription: String {
        if (self.localizedFailureReason != nil) {
            return self.localizedFailureReason!
        } else {
            return self.localizedDescription
        }
    }
}