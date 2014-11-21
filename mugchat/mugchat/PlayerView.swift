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

class PlayerView: UIView {

    private var wordLabel: UILabel!
    private var words: Array<String>!

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
        self.player().play()
    }

    func pause() {
        self.player().play()
    }

    func setupPlayerWithFlips(flips: Array<Mug>, completion: ((player: AVQueuePlayer)  -> Void)) {
        self.words = []
        for flip in flips {
            self.words.append(flip.word)
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
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

            completion(player: videoPlayer)
        }
    }

    func videoQueueEnded(notification: NSNotification) {
        let playerItem: FlipPlayerItem = notification.object as FlipPlayerItem
        let player: AVQueuePlayer = self.player() as AVQueuePlayer

        // Set next item's word
        let wordIndex = (playerItem.order + 1) % self.words.count
        var pauseGap: UInt64 = 0
        if (wordIndex == 0) {
            pauseGap = NSEC_PER_SEC
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(pauseGap)), dispatch_get_main_queue()) { () -> Void in
            self.setWord(self.words[wordIndex])

            player.removeItem(playerItem)
            player.insertItem(playerItem, afterItem: nil)
            player.play()
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

}
