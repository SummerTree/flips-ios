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
        MagicalRecord.saveWithBlockAndWait { (context: NSManagedObjectContext!) -> Void in
            Contact.truncateAllInContext(context)
            Flip.truncateAllInContext(context)
            FlipMessage.truncateAllInContext(context)
            FlipEntry.truncateAllInContext(context)
            BuilderWord.truncateAllInContext(context)
            Device.truncateAllInContext(context)
            User.truncateAllInContext(context)
            Room.truncateAllInContext(context)
            ReadFlipMessage.truncateAllInContext(context)
            DeletedFlipMessage.truncateAllInContext(context)
        }
    }
}