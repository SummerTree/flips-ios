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

private let USER_ID_ATTRIBUTE = "userID"

class UserDataSource {
    
    func createOrUpdateUserWithJson(json: JSON) -> User! {
        // This user won't be saved in the current context. It is temporary.
        var temporaryUser = User.createEntityInAnotherContextWithJson(json)
        
        var savedUser = self.userFromId(temporaryUser.userID)
        if (savedUser == nil) {
            savedUser = User.createEntityWithJson(json)
        } else {
            // Update User
            savedUser?.birthday = temporaryUser.birthday
            savedUser?.facebookID = temporaryUser.facebookID
            savedUser?.firstName = temporaryUser.firstName
            savedUser?.lastName = temporaryUser.lastName
            savedUser?.me = temporaryUser.me
            savedUser?.nickname = temporaryUser.nickname
            savedUser?.photoURL = temporaryUser.photoURL
            savedUser?.pubnubID = temporaryUser.pubnubID
            savedUser?.userID = temporaryUser.userID
            savedUser?.username = temporaryUser.username
        }
        User.save()
        
        return savedUser
    }
    
    func retrieveUserWithId(id: String) -> User {
        var user = self.userFromId(id)

        if (user == nil) {
            println("MugChat failed to retrive user, because User(\(id)) not found in Database. It cannot happen. You need to check why it wasn't added previously.")
        }

        return user!
    }
    
    private func userFromId(id: String?) -> User? {
        if (id == nil) {
            return nil
        }
        
        return User.findFirstByAttribute(USER_ID_ATTRIBUTE, withValue: id) as User?
    }

}