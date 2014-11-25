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
        return phoneNumber.stringByRemovingStringsIn([HYPHEN, LEFT_PARENTHESIS, RIGHT_PARENTHESIS, DOT_SEPARATOR])
    }
}
