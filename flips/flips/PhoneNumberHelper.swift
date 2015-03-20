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

private let HYPHEN = "-"
private let LEFT_PARENTHESIS = "("
private let RIGHT_PARENTHESIS = ")"
private let DOT_SEPARATOR = " "
private let PERIOD = "."

@objc class PhoneNumberHelper {
    
    class func cleanFormattedPhoneNumber(phoneNumber: String) -> String {
        let clean = phoneNumber.stringByRemovingStringsIn([HYPHEN, LEFT_PARENTHESIS, RIGHT_PARENTHESIS, DOT_SEPARATOR, PERIOD])
        return clean.removeWhiteSpaces()
    }
    
    class func formatUsingUSInternational(phoneNumber: String) -> String {
        let phone = cleanFormattedPhoneNumber(phoneNumber)
        let phoneNumberLength = countElements(phone)
        
        if (phoneNumberLength >= 2) {
            let countryCode = phone[0...1]
        
            
            if (countryCode == "+1" && phoneNumberLength == 12) {
                return phone
            } else if (phoneNumberLength == 10) {
                let intPhone = phone[0...9]
                return "+1\(intPhone)"
            } else if (phoneNumberLength == 11) {
                let intPhone = phone[0...10]
                return "+\(intPhone)"
            } else {
                return phone
            }
        } else {
            return phone
        }
    }
}
