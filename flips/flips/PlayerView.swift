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

    var isPlaying = false
    var loadPlayerOnInit = false
    var playInLoop = false

    private var words: Array<String>!
    private var playerItems: Array<FlipPlayerItem>!
    private var thumbnail: UIImage?
    private var timer: NSTimer?

    private var gradientLayer: CALayer!
    private var wordLabel: UILabel!
    private var thumbnailView: UIImageView!
    private var playButtonView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!

    var delegate: PlayerViewDelegate?

    override init() {
        super.init(frame: CGRect.zeroRect)
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubviews()
        self.makeConstraints()
    }
    
    deinit {
        self.releaseResources()
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    func player() -> AVQueuePlayer {
        let layer = self.layer as AVPlayerLayer
        return layer.player as AVQueuePlayer
    }

    private func setPlayer(player: AVPlayer?) {
        let layer = self.layer as AVPlayerLayer
        layer.player = player
    }

    func setWord(word: String) {
        self.wordLabel.text = word
    }

    func play() {
        self.timer?.invalidate()
        
        self.preparePlayer { (player) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
            self.thumbnailView.hidden = true
            self.playButtonView.hidden = true

            let playerItem: FlipPlayerItem = player!.currentItem as FlipPlayerItem
            self.setWord(self.words[playerItem.order])
            self.isPlaying = true
            player!.volume = 1.0
            player!.play()
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

    func pause(fadeOutVolume: Bool = false) {
        self.timer?.invalidate()
        
        if (!self.isPlaying) {
            return
        }
        
        if (fadeOutVolume) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isPlaying = false
                self.playButtonView.hidden = false
                self.fadeOutVolume()
            })
        } else {
            self.isPlaying = false
            self.playButtonView.hidden = false
            self.player().pause()
        }
    }

    func pauseResume() {
        self.timer?.invalidate()
        
        if (self.isPlaying) {
            self.pause()
        } else {
            self.play()
        }
    }

    func setupPlayerWithFlips(flips: Array<Flip>) {
        self.playerItems = [FlipPlayerItem]()
        self.words = []

        for (index, flip) in enumerate(flips) {
            var videoURL = NSURL(string: flip.backgroundURL)
            var videoAsset = AVURLAsset(URL: videoURL, options: nil)
            let playerItem = playerItemWithVideoAsset(videoAsset)
            playerItem.order = index
            self.playerItems.append(playerItem)
            
            self.words.append(flip.word)
        }

        let thumbnailURL = flips.first!.thumbnailURL
        if (thumbnailURL != nil || !thumbnailURL.isEmpty) {
            self.thumbnailView.image = CacheHandler.sharedInstance.thumbnailForUrl(thumbnailURL)
        }

        if (self.loadPlayerOnInit) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.preparePlayer { (player) -> Void in
                    self.play()
                }
            })
        }
    }
    
    func setupPlayerWithWord(word: String, videoURL: NSURL, thumbnailURL: NSURL?) {
        self.words = [word]
        
        var videoAsset: AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        var flipPlayerItem = playerItemWithVideoAsset(videoAsset)
        flipPlayerItem.order = 0
        self.playerItems = [flipPlayerItem]
        
        if (thumbnailURL != nil) {
            self.thumbnailView.image = CacheHandler.sharedInstance.thumbnailForUrl(thumbnailURL!.absoluteString!)
        }
        
        if (self.loadPlayerOnInit) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.preparePlayer { (player) -> Void in
                    self.play()
                }
            })
        }
    }

    func playerItemWithVideoAsset(videoAsset: AVAsset) -> FlipPlayerItem {
        let playerItem: FlipPlayerItem = FlipPlayerItem(asset: videoAsset)

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"videoPlayerItemEnded:",
            name:AVPlayerItemDidPlayToEndTimeNotification, object:playerItem)

        return playerItem
    }

    func videoPlayerItemEnded(notification: NSNotification) {
        let player = self.player()
        let currentItem = player.currentItem as FlipPlayerItem
 
        if (self.playerItems.count == 1) {
            player.seekToTime(kCMTimeZero)
            
            if (!self.playInLoop) {
                self.pause()
            }
        } else {
            player.advanceToNextItem()
            
            let clonedPlayerItem = self.playerItemWithVideoAsset(currentItem.asset)
            clonedPlayerItem.order = currentItem.order
            player.insertItem(clonedPlayerItem, afterItem: nil)

            // Set next item's word
            let nextWordIndex = (currentItem.order + 1) % self.words.count
            self.setWord(self.words[nextWordIndex])
            
            if (currentItem.order == self.playerItems.count - 1) {
                delegate?.playerViewDidFinishPlayback(self)
            
                if (self.playInLoop) {
                    player.pause()
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("play"), userInfo:nil, repeats:false)
                } else {
                    self.pause()
                }
            }
        }
    }

    func hasPlayer() -> Bool {
        let layer = self.layer as AVPlayerLayer
        return layer.player != nil
    }

    private func preparePlayer(completion: ((player: AVQueuePlayer?)  -> Void)) {
        if (self.hasPlayer()) {
            completion(player: self.player())
            return
        }

        let videoPlayer = AVQueuePlayer(items: self.playerItems)
        videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        self.setPlayer(videoPlayer)
        
        completion(player: videoPlayer)
    }


    // MARK - View lifecycle

    private func addSubviews() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pauseResume"))
        
        self.thumbnailView = UIImageView()
        self.addSubview(self.thumbnailView)
        
        self.gradientLayer = CALayer()
        self.gradientLayer.contents = UIImage(named: "Filter_Photo")?.CGImage
        self.gradientLayer.frame = self.layer.bounds
        self.layer.addSublayer(self.gradientLayer)
        
        self.wordLabel = UILabel.flipWordLabel()
        self.wordLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.wordLabel)
        
        self.playButtonView = UIImageView()
        self.playButtonView.alpha = 0.6
        self.playButtonView.contentMode = UIViewContentMode.Center
        self.playButtonView.image = UIImage(named: "PlayButton")
        self.addSubview(self.playButtonView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.layer.bounds
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
        
        if (self.hasPlayer()) {
            self.player().removeAllItems()
        }
        
        let layer = self.layer as AVPlayerLayer
        layer.player = nil
    }

}

protocol PlayerViewDelegate {
    
    func playerViewDidFinishPlayback(playerView: PlayerView)
    func playerViewIsVisible(playerView: PlayerView) -> Bool
    
}
