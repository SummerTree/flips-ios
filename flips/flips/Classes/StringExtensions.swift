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

extension String {
    
    func stringByRemovingStringsIn(array: NSArray) -> String {
        var newString = self
        for stringToDelete in array {
            newString = newString.stringByReplacingOccurrencesOfString(stringToDelete as! String, withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        }
        return newString
    }
    
    func isValidEmail() -> Bool {
        let emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
        
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(self.lowercaseString)
    }
    
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
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
    
    func removeWhiteSpaces() -> String! {
        return self.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch)
    }

    func md5() -> String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CUnsignedInt(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)

        CC_MD5(str!, strLen, result)

        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()
        
        return String(format: hash as String)
    }

    func hasPathExtension(extensions: Array<String>) -> Bool {
        let pathExtension = (self.pathExtension as NSString).lowercaseString

        for ext in extensions {
            if (ext == pathExtension) {
                return true
            }
        }

        return false
    }

    func isImagePath() -> Bool {
        return self.hasPathExtension(["jpg", "jpeg", "png", "gif", "bmp"])
    }

    func isVideoPath() -> Bool {
        return self.hasPathExtension(["mov"])
    }
    
    // Allow to use text[0...5] to get substring
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = startIndex.advancedBy(r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func toFormattedPhoneNumber() -> String {
        if (self.characters.count != 12) {
            return self
        }
        
        return "\(self[2..<5])-\(self[5..<8])-\(self[8...11])"
    }
    
    static func stringFromValue(value: AnyObject?) -> String? {
        if let stringValue: String = value as? String {
            return stringValue
        }
        
        if let stringValue: String = value?.stringValue {
            return stringValue
        }
        
        return nil
    }
    
    func formatWithDashes() -> String {
        let newNumber = self as NSString
        let len = newNumber.length - 1
        
        var firstPart = ""
        var secondPart = ""
        var thirdPart = ""
        
        if len < 2 {
            firstPart = newNumber.substringWithRange(NSRange(location: 0, length: len+1))
        }
        else {
            firstPart = newNumber.substringWithRange(NSRange(location: 0, length: 3))
            firstPart = self.addDashToString(firstPart)
            
            if len < 5 {
                secondPart = newNumber.substringWithRange(NSRange(location: 3, length: (len+1) - 3))
            }
            else
            {
                secondPart = newNumber.substringWithRange(NSRange(location: 3, length: 3))
                secondPart = self.addDashToString(secondPart)
                
                thirdPart = newNumber.substringWithRange(NSRange(location: 6, length: (len+1) - 6))
            }
        }
        
        return "\(firstPart)\(secondPart)\(thirdPart)"
    }
    
    func addDashToString(str: String) -> String {
        return "\(str)-"
    }
    
    func removeDashes() -> String {
        return self.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }

    
}

extension NSString {
    
    func toFormattedPhoneNumber() -> NSString {
        return NSString(string: (self as String).toFormattedPhoneNumber())
    }
    
    
    
}
