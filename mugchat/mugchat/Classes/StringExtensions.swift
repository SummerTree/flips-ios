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

extension String {
    
    func stringByRemovingStringsIn(array: NSArray) -> String {
        var newString = self
        for stringToDelete in array {
            newString = newString.stringByReplacingOccurrencesOfString(stringToDelete as String, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        }
        return newString
    }
    
    func isValidEmail() -> Bool {
        var emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        var emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(self.lowercaseString)
    }
    
    func isValidPassword() -> Bool {
        var passwordRegex = "^\\w*(?=.{8,})(?=\\w*\\d)(?=\\w*[A-Za-z])\\w*$"
        var passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluateWithObject(self)
    }
    
    func doubleValue() -> Double? {
        return NSNumberFormatter().numberFromString(self)!.doubleValue
    }

    func dateValue(format: String = "MM/dd/yyyy") -> NSDate! {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date : NSDate? = dateStringFormatter.dateFromString(self)
        return date
    }
}
