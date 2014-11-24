//
//  LocalizedString.swift
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

import Foundation

/*
 * Alphabetical listing of reused localized strings
 */
struct LocalizedString {
    static let MICROPHONE_ACCESS = NSLocalizedString("Microphone Access", comment: "Microphone access title")
    static let MICROPHONE_MESSAGE = NSLocalizedString("Flips does not have permission to use the microphone.  Please grant permission under Settings > Privacy > Microphone.  If you do not wish to record audio, tap the \"X\" to bypass the recording.", comment: "Microphone message")
    static let WRONG_VERIFICATION_CODE = NSLocalizedString("Wrong Verification Code", comment: "Wrong verification code title")
    static let CONSECUTIVE_INCORRECT_ENTRIES = NSLocalizedString("3 incorrect entries. Check your messages for a new code", comment: "Wrong verification code message")
    static let OK = NSLocalizedString("OK", comment: "OK")
}
