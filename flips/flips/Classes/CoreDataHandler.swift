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

public class CoreDataHandler: NSObject {
    
    private let databaseStoreName = "flips.sqlite"
    
    public class var sharedInstance : CoreDataHandler {
    struct Static {
        static let instance : CoreDataHandler = CoreDataHandler()
        }
        return Static.instance
    }
    
    
    // MARK: - Database Handlers
    
    func setupDatabase() {
        MagicalRecord.setupCoreDataStackWithStoreNamed(databaseStoreName)
    }

    func resetDatabase() {
        var error: NSError?
        var storeURL = NSPersistentStore.MR_urlForStoreName(databaseStoreName)
        
//        MagicalRecord.cleanUp()
        
        var user: User? = User.loggedUser()
        
        if let user = user {
            let userDataSource = UserDataSource()
            user.me = false
            userDataSource.save()
        }
        
        Room.truncateAll()
    }
}