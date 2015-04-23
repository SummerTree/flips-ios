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

class AnalyticsService {
    
    class func logFlipCreated(fromVideo: Bool, fromPicture: Bool, fromBackCamera: Bool, fromFrontCamera: Bool, fromCameraRoll: Bool, fromAudio: Bool, inLandscape: Bool) {
        Flurry.logEvent("flipCreated", withParameters: ["fromVideo": fromVideo, "fromPicture": fromPicture, "fromBackCamera": fromBackCamera, "fromFrontCamera": fromFrontCamera, "fromCameraRoll": fromCameraRoll, "fromAudio": fromAudio, "inLandscape": inLandscape])
    }
    
    class func logFlipRejected(fromVideo: Bool, fromPicture: Bool, fromBackCamera: Bool, fromFrontCamera: Bool, fromCameraRoll: Bool, fromAudio: Bool, inLandscape: Bool) {
        Flurry.logEvent("flipRejected", withParameters: ["fromVideo": fromVideo, "fromPicture": fromPicture, "fromBackCamera": fromBackCamera, "fromFrontCamera": fromFrontCamera, "fromCameraRoll": fromCameraRoll, "fromAudio": fromAudio, "inLandscape": inLandscape])
    }
    
    class func logMessageSent(numOfFlips: Int, percentWordsAssigned: Int, group: Bool) {
        Flurry.logEvent("messageSent", withParameters: ["numOfFlips": numOfFlips, "percentWordsAssigned": percentWordsAssigned, "group": group])
    }
    
    class func logMessageReceived() {
        Flurry.logEvent("messageReceived")
    }
    
    class func logUserSignUp(source: String) {
        Flurry.logEvent("signUp", withParameters: ["source": source])
    }
    
    class func logUserSignIn(source: String) {
        Flurry.logEvent("signIn", withParameters: ["source": source])
    }

    class func logUserSentInvite() {
        Flurry.logEvent("inviteSent")
    }
    
    class func logThreadViewed(hasUnreadMessages: Bool) {
        Flurry.logEvent("threadViewed", withParameters: ["hasUnreadMessages": hasUnreadMessages])
    }
    
    class func logMessageViewed(messageUnread: Bool) {
        Flurry.logEvent("messageViewed", withParameters: ["messageUnread": messageUnread])
    }
    
    class func logMessagePaused(messageUnread: Bool) {
        Flurry.logEvent("messagePaused", withParameters: ["messageUnread": messageUnread])
    }
    
    class func logWordsJoined() {
        Flurry.logEvent("wordsJoined")
    }

    class func logProfileChanged() {
        Flurry.logEvent("profileChanged")
    }
    
    class func logContactsImported(numOfFriends: Int) {
        Flurry.logEvent("contactsImported", withParameters: ["numOfFriends": numOfFriends])
    }
    
    class func logOnboardingSkipped(step: String) {
        Flurry.logEvent("onboardingSkipped", withParameters: ["step": step])
    }
    
}