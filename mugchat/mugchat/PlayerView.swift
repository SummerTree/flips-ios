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

import UIKit

private let _queue = dispatch_queue_create("com.flips.queue.player-view", DISPATCH_QUEUE_SERIAL)

class PlayerView: UIView {

    var playing = false
    private var wordLabel: UILabel!
    private var words: Array<String>!
    

    var delegate: PlayerViewDelegate?

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private class var videoSerialQueue: dispatch_queue_t {
        return _queue
	}

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    func player() -> AVPlayer {
        let layer = self.layer as AVPlayerLayer
        return layer.player
    }

    private func setPlayer(player: AVPlayer) {
        let layer = self.layer as AVPlayerLayer
        layer.player = player
    }

    func setWord(word: String) {
        self.wordLabel.text = word
    }

    func play() {
        let playerItem: FlipPlayerItem = self.player().currentItem as FlipPlayerItem
        self.setWord(self.words[playerItem.order])
        self.playing = true
        self.player().play()
    }

    func pause() {
        if (self.playing) {
            self.player().pause()
            self.playing = false
        }
    }

    func setupPlayerWithFlips(flips: Array<Mug>, completion: ((player: AVQueuePlayer)  -> Void)) {
        self.words = []
        for flip in flips {
            self.words.append(flip.word)
        }

        dispatch_async(PlayerView.videoSerialQueue) { () -> Void in
            var localFlips: Array<Mug> = []
            let moc = NSManagedObjectContext.MR_contextForCurrentThread();
            
            for flip in flips {
                localFlips.append(moc.objectWithID(flip.objectID) as Mug)
            }
            
            let videoComposer = VideoComposer()
            videoComposer.renderOverlays = false
            
            var videoAssets: Array<AVAsset> = videoComposer.videoPartsFromFlips(localFlips as Array<AnyObject>) as Array<AVAsset>
            
            let videoPlayer = AVQueuePlayer()
            videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
            
            var i = 0
            
            for videoAsset in videoAssets {
                let playerItem: FlipPlayerItem = FlipPlayerItem(asset: videoAsset)
                
                playerItem.order = i
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"videoQueueEnded:",
                    name:AVPlayerItemDidPlayToEndTimeNotification, object:playerItem)
                
                videoPlayer.insertItem(playerItem, afterItem: nil)
                
                i++
            }
            
            self.setPlayer(videoPlayer)

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setWord(self.words.first!)
                completion(player: videoPlayer)
            })
        }
    }

    func playerItemWithVideoAsset(videoAsset: AVAsset) -> FlipPlayerItem {
        let playerItem: FlipPlayerItem = FlipPlayerItem(asset: videoAsset)

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"videoQueueEnded:",
            name:AVPlayerItemDidPlayToEndTimeNotification, object:playerItem)

        return playerItem
    }

    func videoQueueEnded(notification: NSNotification) {
        delegate?.playerViewDidFinishPlayback(self)
        
        let player: AVQueuePlayer = self.player() as AVQueuePlayer
        let playerItem: FlipPlayerItem = notification.object as FlipPlayerItem
        let clonePlayerItem: FlipPlayerItem = self.playerItemWithVideoAsset(playerItem.asset)
        clonePlayerItem.order = playerItem.order

        // Set next item's word
        let wordIndex = (playerItem.order + 1) % self.words.count
        var pauseGap: UInt64 = 0
        if (wordIndex == 0) {
            pauseGap = NSEC_PER_SEC
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(pauseGap)), dispatch_get_main_queue()) { () -> Void in
			if self.playing {
            	self.setWord(self.words[wordIndex])

                if (self.words.count > 1) {
                    player.removeItem(playerItem)
                    NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)

                    player.insertItem(clonePlayerItem, afterItem: nil)
                } else {
                    player.seekToTime(kCMTimeZero)
                }
                
                player.play()
            }
        }
    }

    override func layoutSubviews() {
        if (self.wordLabel == nil) {
            var gradientLayer = CALayer()
            gradientLayer.contents = UIImage(named: "Filter_Photo")?.CGImage
            gradientLayer.frame = self.layer.bounds
            self.layer.addSublayer(gradientLayer)

            self.wordLabel = UILabel.flipWordLabel()
            self.wordLabel.textAlignment = NSTextAlignment.Center

            self.addSubview(self.wordLabel)

            self.makeConstraints()
        }
        
        super.layoutSubviews()
    }

    private func makeConstraints() {
        self.wordLabel.mas_makeConstraints { (make) -> Void in
            make.width.equalTo()(self)
            make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self)
        }
    }
    
    func releaseResources() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

protocol PlayerViewDelegate {
    
    func playerViewDidFinishPlayback(playerView: PlayerView)
    func playerViewIsVisible(playerView: PlayerView) -> Bool
    
}
