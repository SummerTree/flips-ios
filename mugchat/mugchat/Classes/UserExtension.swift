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

struct UserAttributes {
	static let USER_ID = "userID"
	static let FIRST_NAME = "firstName"
	static let LAST_NAME = "lastName"
	static let ME = "me"
	static let CONTACTS = "contacts"
}

private let LOGGED_USER_ATTRIBUTE = "me"

extension User {
    
    class func loggedUser() -> User? {
        var loggedAttributeUser: User? = User.MR_findFirstByAttribute(LOGGED_USER_ATTRIBUTE, withValue: true) as? User
        return loggedAttributeUser
    }

    class func isUserLoggedIn() -> Bool {
        var loggedUser = User.loggedUser() as User?
        return (loggedUser != nil)
    }
    
    func fullName() -> String! {
        return self.firstName + " " + self.lastName
    }
}