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

private let _operationQueue = NSOperationQueue()

class PlayerView: UIView {

    var isPlaying = false
    var loadPlayerOnInit = false
    var useCache = true

    private var words: Array<String>!
    private var flips: Array<Flip>!

    private var wordLabel: UILabel!
    private var thumbnailView: UIImageView!
    private var playButtonView: UIImageView!

    var delegate: PlayerViewDelegate?
    
    private var videoComposeOperation: VideoComposeOperation?

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    class var videoSerialOperationQueue: NSOperationQueue {
        _operationQueue.maxConcurrentOperationCount = 1
        return _operationQueue
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
        self.preparePlayer { (player) -> Void in
            self.thumbnailView.hidden = true
            self.playButtonView.hidden = true
            
            var currentItem = player!.currentItem

            if (currentItem == nil) {
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let alertView = UIAlertView(title: LocalizedString.VIDEO_IS_NOT_READY, message: LocalizedString.VIDEO_IS_BEING_CREATED, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                }
            } else {
                let playerItem: FlipPlayerItem = player!.currentItem as FlipPlayerItem
                self.setWord(self.words[playerItem.order])
                self.isPlaying = true
                player!.volume = 1.0
                player!.play()
            }
        }
    }
    
    private func fadeOutVolume() {
        if (!self.hasPlayer()) {
            return
        }

        if (self.player().volume > 0) {
            if (self.player().volume <= 0.2) {
                self.player().volume = 0.0
            } else {
                self.player().volume -= 0.2
            }

            weak var weakSelf = self
            
            let seconds = 0.1 * Double(NSEC_PER_SEC)
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds))
            dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                weakSelf?.fadeOutVolume()
                return ()
            })
        } else {
            self.player().pause()
        }
    }

    func pause() {
        if (self.isPlaying) {
            self.isPlaying = false
            self.playButtonView.hidden = false

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.fadeOutVolume()
            })
        }
    }

    func pauseResume() {
        if (self.isPlaying) {
            self.pause()
        } else {
            self.play()
        }
    }

    func setupPlayerWithFlips(flips: Array<Flip>, completion: ((player: AVQueuePlayer?)  -> Void)) {
        self.flips = flips
        self.words = []
        let layer = self.layer as AVPlayerLayer
        layer.player = nil
        self.isPlaying = false

        for flip in flips {
            self.words.append(flip.word)
        }

        self.showThumbnail()

        if (self.loadPlayerOnInit) {
            self.preparePlayer(completion)
        } else {
            completion(player: nil)
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
			if self.isPlaying {
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

    func hasPlayer() -> Bool {
        let layer = self.layer as AVPlayerLayer
        return layer.player != nil
    }

    private func preparePlayer(completion: ((player: AVQueuePlayer?)  -> Void)) {
        if (self.hasPlayer()) {
            completion(player: self.player() as? AVQueuePlayer)
            return;
        }

        weak var weakSelf : PlayerView? = self

        if (videoComposeOperation != nil) {
            videoComposeOperation?.cancel()
        }

        // Reduce others operations' priority
        for (var i = 0; i < PlayerView.videoSerialOperationQueue.operationCount; i++) {
            if let operation = PlayerView.videoSerialOperationQueue.operations[i] as? NSOperation {
                operation.queuePriority = NSOperationQueuePriority.Low
            }
        }

        videoComposeOperation = VideoComposeOperation(flips: flips, useCache: self.useCache, queueObserver: self)
        if (!videoComposeOperation!.areFlipsCached(flips)) {
            ActivityIndicatorHelper.showActivityIndicatorAtView(self)
        }
        videoComposeOperation?.queuePriority = NSOperationQueuePriority.High
        videoComposeOperation?.completion = ( { player -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                weakSelf?.setPlayer(player)

                if (weakSelf != nil) {
                    weakSelf!.setWord(weakSelf!.words.first!)
                }

                ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                completion(player: player)
            })
        })

        PlayerView.videoSerialOperationQueue.addOperation(videoComposeOperation!)
    }


    // MARK - View lifetime

    override func layoutSubviews() {
        if (self.wordLabel == nil) {
            self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pauseResume"))

            self.thumbnailView = UIImageView()
            self.addSubview(self.thumbnailView)

            var gradientLayer = CALayer()
            gradientLayer.contents = UIImage(named: "Filter_Photo")?.CGImage
            gradientLayer.frame = self.layer.bounds
            self.layer.addSublayer(gradientLayer)

            self.wordLabel = UILabel.flipWordLabel()
            self.wordLabel.textAlignment = NSTextAlignment.Center
            self.addSubview(self.wordLabel)

            self.playButtonView = UIImageView()
            self.playButtonView.alpha = 0.6
            self.playButtonView.contentMode = UIViewContentMode.Center
            self.playButtonView.image = UIImage(named: "PlayButton")
            self.addSubview(self.playButtonView)

            self.makeConstraints()

            self.showThumbnail()
        }
        
        super.layoutSubviews()
    }

    private func firstThumbnail() -> UIImage {
        // Get the first non-blank flip
        var thumbnailFlip: Flip?
        for flip in self.flips {
            if (!flip.isBlankFlip()) {
                thumbnailFlip = flip
                break;
            }
        }

        var thumbnailImage: UIImage?
        
        if (thumbnailFlip != nil) {
            thumbnailImage = CacheHandler.sharedInstance.thumbnailForUrl(thumbnailFlip!.backgroundURL)
        }

        return thumbnailImage ?? UIImage.emptyFlipImage()
    }

    private func showThumbnail() {
        if (self.thumbnailView != nil) {
            let thumbnailImage = self.firstThumbnail()
            self.thumbnailView.image = thumbnailImage
            self.thumbnailView.hidden = false
            self.setWord(self.words.first!)
        }
    }

    private func makeConstraints() {
        self.wordLabel.mas_makeConstraints { (make) -> Void in
            make.width.equalTo()(self)
            make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self)
        }

        self.thumbnailView.mas_makeConstraints({ (make) -> Void in
            make.width.equalTo()(self)
            make.height.equalTo()(self)
            make.center.equalTo()(self)
        })
        self.playButtonView.mas_makeConstraints({ (make) -> Void in
            make.width.equalTo()(self.thumbnailView)
            make.height.equalTo()(self.thumbnailView)
            make.center.equalTo()(self.thumbnailView)
        })
    }

    func releaseResources() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if (videoComposeOperation != nil) {
            videoComposeOperation?.cancel()
        }
    }

}

protocol PlayerViewDelegate {
    
    func playerViewDidFinishPlayback(playerView: PlayerView)
    func playerViewIsVisible(playerView: PlayerView) -> Bool
    
}
