//
//  PhoneNumberHelper.swift
//  mugchat
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

class PhoneNumberHelper {
    
    class func cleanFormattedPhoneNumber(phoneNumber: String) -> String {
        let clean = phoneNumber.stringByRemovingStringsIn([HYPHEN, LEFT_PARENTHESIS, RIGHT_PARENTHESIS, DOT_SEPARATOR])
        return clean.removeWhiteSpaces()
    }
    
    class func formatUsingUSInternational(phoneNumber: String) -> String {
        println("Formatting phone = \(phoneNumber)")
        println("Country code \(phoneNumber[0...1])")
        let countryCode = phoneNumber[0...1]
        let phoneNumberLength = countElements(phoneNumber)
        if (countryCode == "+1" && phoneNumberLength == 12) {
            return phoneNumber
        } else {
            let phone = cleanFormattedPhoneNumber(phoneNumber)
            if (countElements(phone) > 10) {
                return "+1\(phone[0...10])"
            } else {
                return phone
            }
        }
        
    }
}