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

public typealias CompletionBlock = (Bool) -> Void

class BaseDataSource: NSObject {
    
    func save() {
        if (NSThread.currentThread() == NSThread.mainThread()) {
            println("   ")
            println("   SAVING IN MAIN THREAD!! FIX IT!")
            println("   INCLUDING DISPATCH BACKGROUND!")
            println("   ")
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
            })
        } else {
            NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
        }
    }
}