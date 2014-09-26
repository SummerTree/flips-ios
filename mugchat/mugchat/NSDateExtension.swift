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

extension NSDate {
    
    convenience init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
    
    // example usage: var date = NSDate(dateTimeString: "2014-09-24T21:02:49.020Z"
    // time is always GMT

    convenience init(dateTimeString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let gmt = NSTimeZone(abbreviation: "GMT")
        dateStringFormatter.timeZone = gmt
        let d = dateStringFormatter.dateFromString(dateTimeString)
        self.init(timeInterval:0, sinceDate:d!)
    }
}