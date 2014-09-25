//
//  NSDateExtension.swift
//  mugchat
//
//  Created by Ecil Teodoro on 9/24/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
//

import Foundation

extension NSDate {
    
    // example usage: var date = NSDate(dateString: "1968-12-02")

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