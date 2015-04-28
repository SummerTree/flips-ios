//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

class QueueHelper: NSObject {

    class func dispatchAsyncWithNewContext(block: (newContext: NSManagedObjectContext) -> Void) {
        dispatch_async(dispatch_queue_create("com.flips.queue.with.new.context", nil), { () -> Void in
            block(newContext: NSManagedObjectContext.MR_contextWithParent(NSManagedObjectContext.MR_defaultContext()))
        })
    }
}
