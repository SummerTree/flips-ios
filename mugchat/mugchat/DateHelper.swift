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

class DateHelper {

    class func formatDateToApresentationFormat(date: NSDate) -> String {
        let now = NSDate()
        let formatter = NSDateFormatter()
        
        formatter.dateFormat = "yyyy"
        let todayYear = formatter.stringFromDate(now).toInt()
        let dateYear = formatter.stringFromDate(date).toInt()
        var yearDif = todayYear! - dateYear!
        if (yearDif > 0) {
            if (yearDif == 1) {
                return NSLocalizedString("last year", comment: "last year")
            } else {
                return NSLocalizedString("\(yearDif) years ago", comment: "\(yearDif) years ago")
            }
        }
        
        formatter.dateFormat = "MM"
        let todayMonth = formatter.stringFromDate(now).toInt()
        let dateMonth = formatter.stringFromDate(date).toInt()
        var monthDif = todayMonth! - dateMonth!
        if (monthDif > 0) {
            if (monthDif == 1) {
                return NSLocalizedString("last month", comment: "last month")
            } else {
                return NSLocalizedString("\(monthDif) months ago", comment: "\(monthDif) months ago")
            }
        }
        
        formatter.dateFormat = "dd"
        let todayDay = formatter.stringFromDate(now).toInt()
        let dateDay = formatter.stringFromDate(date).toInt()
        var dayDif = todayDay! - dateDay!
        if (dayDif > 0) {
            if (dayDif == 1) {
                return NSLocalizedString("yesterday", comment: "yesterday")
            } else {
                return NSLocalizedString("\(dayDif) days ago", comment: "\(dayDif) days ago")
            }
        }

        formatter.dateFormat = "hh:mm a"
        return formatter.stringFromDate(date)
    }
}
