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
    static let CONSECUTIVE_INCORRECT_ENTRIES = NSLocalizedString("3 incorrect entries. Check your messages for a new code", comment: "Wrong verification code message")
    static let ERROR = NSLocalizedString("Error", comment: "Error")
    static let FLIPBOYS_ROOM_NOT_FOUND = NSLocalizedString("Feedback room not found", comment: "Feedback room not found")
    static let FORGOT_PASSWORD = NSLocalizedString("Forgot Password", comment: "Forgot Password")
    static let MICROPHONE_ACCESS = NSLocalizedString("Microphone Access", comment: "Microphone access title")
    static let MICROPHONE_MESSAGE = NSLocalizedString("Flips does not have permission to use the microphone.  Please grant permission under Settings > Privacy > Microphone.  If you do not wish to record audio, tap the \"X\" to bypass the recording.", comment: "Microphone message")
    static let NO_INTERNET_CONNECTION = NSLocalizedString("Unable to connect to server.  Please try again later", comment: "No internet connection")
    static let OK = NSLocalizedString("OK", comment: "OK")
    static let WRONG_VERIFICATION_CODE = NSLocalizedString("Wrong Verification Code", comment: "Wrong verification code title")
    static let CONTACTS_ACCESS_TITLE = NSLocalizedString("Contacts")
    static let CONTACTS_ACCESS_MESSAGE = NSLocalizedString("Flips does not have access to your contacts. Please grant access under Settings > Privacy > Contacts.")
    static let VIDEO_IS_NOT_READY = NSLocalizedString("Video is not ready")
    static let VIDEO_IS_BEING_CREATED = NSLocalizedString("Video is being created")
}

func NSLocalizedString(key: String) -> String {
    return NSLocalizedString(key, comment: "")
}