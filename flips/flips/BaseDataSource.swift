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

public typealias SaveBlock = (NSManagedObjectContext!) -> Void

class BaseDataSource: NSObject {
    
    let currentContext: NSManagedObjectContext!
    
    override init() {
        super.init()
        currentContext = NSManagedObjectContext.MR_defaultContext()
    }
    
    init(context: NSManagedObjectContext) {
        super.init()
        currentContext = context
    }
    
//    func save() {
//        if (NSThread.currentThread() == NSThread.mainThread()) {
//            println("   ")
//            println("   SAVING IN MAIN THREAD!! FIX IT!")
//            println("   INCLUDING DISPATCH BACKGROUND!")
//            println("   ")
//        } else {
//            println("   ")
//            println("   SAVING IN BACKGROUND TASK")
//            println("   ")
//        }
//        
//        NSManagedObjectContext.MR_contextForCurrentThread().MR_saveToPersistentStoreAndWait()
//    }
    
//    func saveDataInBackground(saveBlock: SaveBlock, completionBlock: CompletionBlock) {
//        println("   saveDataInBackground with completion")
//        MagicalRecord.saveWithBlock(saveBlock, completion: { (success: Bool, error: NSError!) -> Void in
//            completionBlock(success)
//        })
//    }
//    
//    func saveDataInBackground(saveBlock: SaveBlock) {
//        println("   saveDataInBackground")
//        MagicalRecord.saveWithBlock(saveBlock)
//    }
//    
//    func saveDataAndWait(saveBlock: SaveBlock) {
//        println("   saveDataAndWait")
//        MagicalRecord.saveWithBlockAndWait(saveBlock)
//    }
//    + (void)saveDataInBackgroundWithContext:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void(^)(void))completion
//    {
//    dispatch_async(coredata_background_save_queue(), ^{
//    [self saveDataInContext:saveBlock];
//    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//    completion();
//    });
//    });
//    }
}