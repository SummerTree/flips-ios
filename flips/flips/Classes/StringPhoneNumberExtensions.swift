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

private let US_CODE = "+1"


extension String {
    
    var trimmedPhoneNumber: String {
        return stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }

    var intlPhoneNumberUSOnly: String {
        return "\(US_CODE)\(trimmedPhoneNumber)"
    }
    
    func intlPhoneNumberWithCountryCode(countryCode: String) -> String {
        return "\(countryCode)\(trimmedPhoneNumber)"
    }
}
