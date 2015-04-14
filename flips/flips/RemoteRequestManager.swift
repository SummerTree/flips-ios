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

public typealias RemoteRequestBlock = ((completionBlock: ((Bool) -> Void)) -> Void)

public class RemoteRequestManager: NSObject {
    
    private let RUN_INTERVAL: Double = 30 // 30 seconds
    private let FIRST_RUN_DELAY: Double = 5 // 5 seconds

    private var blocksQueue: [Int : RemoteRequestBlock]!
    private var currentIndex: Int!
    private var privateQueue: dispatch_queue_t!
    
    private var isRunning: Bool = false
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : RemoteRequestManager {
        struct Static {
            static let instance : RemoteRequestManager = RemoteRequestManager()
        }
        return Static.instance
    }

    
    // MARK: - Initializers
    
    override init() {
        super.init()
        println("RemoteRequestManager.init()")
        self.currentIndex = 0
        self.blocksQueue = Dictionary<Int, RemoteRequestBlock>()
        self.privateQueue = dispatch_queue_create("RemoteRequestManagerQueue", DISPATCH_QUEUE_SERIAL)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onNetworkReachabilityChangedNotificationReceived",
            name: NETWORK_REACHABILITY_CHANGED_NOTIFICATION_KEY,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Queue Handler
    
    func executeBlock(block: RemoteRequestBlock) {
        println("RemoteRequestManager.addBlockToRetryQueue()")
        block { (success: Bool) -> Void in
            if (!success) {
                dispatch_async(self.privateQueue, { () -> Void in
                    self.currentIndex = self.currentIndex + 1
                    self.blocksQueue[self.currentIndex] = block
                    
                    if (!self.isRunning) {
                        self.run(delay: self.RUN_INTERVAL) // Just a delay to make sure that all blocks were added
                    }
                })
            }
        }
    }
    
    func cleanQueue() {
        println("RemoteRequestManager.cleanQueue()")
        dispatch_sync(self.privateQueue, { () -> Void in
            self.blocksQueue.removeAll(keepCapacity: false)
            self.isRunning = false
        })
    }
    
    
    // MARK: - Private Methods
    
    private func run(delay: Double = 0.0) {
        println("RemoteRequestManager.run(\(delay))")
        self.isRunning = true
        let time = delay * Double(NSEC_PER_SEC)
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(time))
        
        if (self.blocksQueue.count > 0) {
            dispatch_after(delay, self.privateQueue, { () -> Void in
                println("   RemoteRequestManager - dispatched after delay")
                for (key, block) in self.blocksQueue {
                    block(completionBlock: { (success: Bool) -> Void in
                        println("   RemoteRequestManager - Queued block completion called with \(success)")
                        if (success) {
                            self.removeFromQueueBlockWithKey(key)
                        }
                    })
                }
                self.run(delay: self.RUN_INTERVAL)
            })
        } else {
            println("RemoteRequestManager stopped")
            self.isRunning = false
        }
    }
    
    private func removeFromQueueBlockWithKey(key: Int) {
        println("removeFromQueueBlockWithKey(\(key))")
        dispatch_async(self.privateQueue, { () -> Void in
            self.blocksQueue.removeValueForKey(key)
            return
        })
    }
    
    
    // MARK: - Notification Handlers
    
    private func onNetworkReachabilityChangedNotificationReceived(notification: NSNotification) {
        println("onNetworkReachabilityChangedNotificationReceived")
        if (NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            if ((!self.isRunning) && (self.blocksQueue.count > 0)) {
                self.run()
            }
        } else {
            self.isRunning = false
        }
    }
}
