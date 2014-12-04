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

public typealias VideoOperationCompletionBlock = (AVQueuePlayer) -> Void

class VideoComposeOperation: NSOperation {
    
    private var flips: [Flip]!
    private var useCache = false
    private var queueObserver: AnyObject!
    
    var completion: VideoOperationCompletionBlock?
    
    init(flips: [Flip], useCache: Bool, queueObserver: AnyObject) {
        super.init()
        self.flips = flips
        self.useCache = useCache
        self.queueObserver = queueObserver
    }
    
    override func main() {
        if (self.cancelled) {
            return
        }
     
        var localFlips: Array<Flip> = []
        var localFlipIDs: Array<String> = []
        let moc = NSManagedObjectContext.MR_contextForCurrentThread();

        for flip in flips {
            let localFlip = moc.objectWithID(flip.objectID) as Flip
            localFlips.append(localFlip)

            if (localFlip.isBlankFlip()) {
                localFlipIDs.append(localFlip.word)
            } else {
                localFlipIDs.append(localFlip.flipID)
            }
        }
        
        let videoComposer = VideoComposer()
        videoComposer.renderOverlays = false

        if (self.useCache) {
            videoComposer.cacheKey = "-".join(localFlipIDs).md5()
        }
        
        if (self.cancelled) {
            return
        }
        
        var videoAssets: Array<AVAsset> = videoComposer.videoPartsFromFlips(localFlips as Array<AnyObject>) as Array<AVAsset>
        
        let videoPlayer = AVQueuePlayer()
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
        
        var i = 0
        
        if (self.cancelled) {
            return
        }
        
        for videoAsset in videoAssets {
            let playerItem: FlipPlayerItem = FlipPlayerItem(asset: videoAsset)
            
            playerItem.order = i
            
            NSNotificationCenter.defaultCenter().addObserver(queueObserver, selector:"videoQueueEnded:",
                name:AVPlayerItemDidPlayToEndTimeNotification, object:playerItem)
            
            videoPlayer.insertItem(playerItem, afterItem: nil)
            
            i++
        }
        
        if (self.cancelled) {
            return
        }
        
        if (completion != nil) {
            completion!(videoPlayer)
        }
    }
}