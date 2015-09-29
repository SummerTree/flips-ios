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

let SECONDS_IN_A_DAY:Double = 86400

class DateHelper {

    class func formatDateToApresentationFormat(date: NSDate) -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let currentDate = NSDate()
        var messageDate = date
        
        let currentDateString = formatter.stringFromDate(currentDate)
        var messageDateString = formatter.stringFromDate(messageDate)
        
        var daysBetweenDates = 0
        
        while !(currentDateString as NSString).isEqualToString(messageDateString) && daysBetweenDates <= 7 {
            messageDate = messageDate.dateByAddingTimeInterval(SECONDS_IN_A_DAY)
            messageDateString = formatter.stringFromDate(messageDate)
            daysBetweenDates++
        }
        
        if daysBetweenDates == 0 {
            formatter.dateFormat = "hh:mm a"
            return NSLocalizedString(formatter.stringFromDate(date), comment: formatter.stringFromDate(date))
        } else if daysBetweenDates <= 1 {
            formatter.dateFormat = "hh:mm a"
            return NSLocalizedString("Yesterday, \(formatter.stringFromDate(date))", comment: "Yesterday, \(formatter.stringFromDate(date))")
        } else if daysBetweenDates <= 7 {
            formatter.dateFormat = "EEEE hh:mm a"
            return NSLocalizedString("\(formatter.stringFromDate(date))", comment: "\(formatter.stringFromDate(date))")
        } else {
            formatter.dateFormat = "yyyy"
            let currentYear = Int(formatter.stringFromDate(currentDate))
            let dateYear = Int(formatter.stringFromDate(date))
            let yearDif = currentYear! - dateYear!
            if yearDif > 0 {
                formatter.dateFormat = "MMM dd yyyy, hh:mm a"
                return NSLocalizedString("\(formatter.stringFromDate(date))", comment: "\(formatter.stringFromDate(date))")
            } else {
                formatter.dateFormat = "EEE, MMM dd, hh:mm a"
                return NSLocalizedString("\(formatter.stringFromDate(date))", comment: "\(formatter.stringFromDate(date))")
            }
        }
    }
}
