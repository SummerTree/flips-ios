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
    var loadingFlips = false
    var hasDownloadError = false

    private var flips: Array<Flip>!
    private var words: Array<String>!
    private var playerItems: Array<FlipPlayerItem>!
    private var thumbnail: UIImage?
    private var timer: NSTimer?

    private var gradientLayer: CALayer!
    private var wordLabel: UILabel!
    private var thumbnailView: UIImageView!
    private var playButtonView: UIImageView!
    private var retryButtonView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView!
    private var progressBarView: UIProgressView!

    weak var delegate: PlayerViewDelegate?

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

    func player() -> AVQueuePlayer? {
        let layer = self.layer as AVPlayerLayer
        if let player = layer.player {
            return player as? AVQueuePlayer
        }
        return nil
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
        
        if (self.loadingFlips) {
            return
        }

        var isPlayerReady = false

        // Single word
        if ((self.flips == nil) && (self.playerItems.count > 0)) {
            isPlayerReady = true

        } else {
            isPlayerReady = self.progressBarView.progress == 1
        }

        if (isPlayerReady) {
            self.preparePlayer { (player) -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                self.thumbnailView.hidden = true
                self.playButtonView.hidden = true
                self.retryButtonView.hidden = true
                self.progressBarView.hidden = true

                let playerItem: FlipPlayerItem = player!.currentItem as FlipPlayerItem
                self.setWord(self.words[playerItem.order])
                self.isPlaying = true
                player!.volume = 1.0
                player!.play()
            }

        } else {
            self.loadFlipsResourcesForPlayback({ () -> Void in
                self.play()
            })
        }
    }
    
    private func fadeOutVolume() {
        if let player = self.player() {
            if (player.volume > 0) {
                if (player.volume <= 0.2) {
                    player.volume = 0.0
                } else {
                    player.volume -= 0.2
                }
                
                weak var weakSelf = self
                
                let seconds = 0.1 * Double(NSEC_PER_SEC)
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds))
                dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                    weakSelf?.fadeOutVolume()
                    return ()
                })
            } else {
                player.pause()
            }
        }
    }

    func pause(fadeOutVolume: Bool = false) {
        self.timer?.invalidate()
        self.loadPlayerOnInit = false
        
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
            if let player = self.player() {
                player.pause()
            }
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

    private func loadFlipsResourcesForPlayback(completion: () -> Void) {
        self.loadingFlips = true
        self.hasDownloadError = false

        self.playerItems = [FlipPlayerItem]()
        self.words = []

        var pendingFlips = self.flips.count
        var numOfFlips = self.flips.count

        self.progressBarView.hidden = false
        self.playButtonView.hidden = true
        self.retryButtonView.hidden = true

        for (index, flip) in enumerate(self.flips) {
            self.words.append(flip.word)

            if (flip.backgroundURL == nil || flip.backgroundURL.isEmpty) {
                let emptyVideoPath = NSBundle.mainBundle().pathForResource("empty_video", ofType: "mov")
                let videoAsset = AVURLAsset(URL: NSURL(fileURLWithPath: emptyVideoPath!), options: nil)
                let playerItem = self.playerItemWithVideoAsset(videoAsset)
                playerItem.order = index
                self.playerItems.append(playerItem)

                pendingFlips--

                self.updateDownloadProgress(numOfFlips - pendingFlips, of:numOfFlips);

                if (pendingFlips <= 0) {
                    self.loadingFlips = false
                    self.sortPlayerItems()
                    completion()
                }

            } else {
                FlipsCache.sharedInstance.videoForFlip(flip,
                    success: { (localPath: String!) in
                        if (self.hasDownloadError) {
                            return
                        }

                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (self.flips == nil) {
                                return
                            }
                            
                            let videoAsset = AVURLAsset(URL: NSURL(fileURLWithPath: localPath), options: nil)
                            let playerItem = self.playerItemWithVideoAsset(videoAsset)
                            playerItem.order = index
                            self.playerItems.append(playerItem)

                            pendingFlips--

                            self.updateDownloadProgress(numOfFlips - pendingFlips, of:numOfFlips);

                            if (pendingFlips <= 0) {
                                self.loadingFlips = false
                                self.sortPlayerItems()
                                completion()
                            }
                        })
                    },
                    failure: { (error: FlipError) in
                        println("Failed to get resource from cache, error: \(error)")
                        self.showErrorState()
                    }
                )
            }
        }
    }

    private func showErrorState() {
        self.loadingFlips = false
        self.hasDownloadError = true

        self.playerItems.removeAll(keepCapacity: true)

        self.progressBarView.hidden = true
        self.progressBarView.progress = 0;

        self.retryButtonView.hidden = false
    }

    private func sortPlayerItems() {
        self.playerItems.sort { (itemOne: FlipPlayerItem, itemTwo: FlipPlayerItem) -> Bool in
            return itemOne.order < itemTwo.order
        }
    }

    private func updateDownloadProgress(progress: Int, of: Int) {
        self.progressBarView.progress = Float(progress) / Float(of);
    }

    func setupPlayerWithFlips(flips: Array<Flip>) {
        self.flips = flips
        self.updateDownloadProgress(0, of:flips.count);

        let firstFlip = flips.first
        if (firstFlip != nil) {

            self.wordLabel.text = firstFlip!.word

            if (firstFlip!.thumbnailURL != nil && !firstFlip!.thumbnailURL.isEmpty) {
                let response = ThumbnailsCache.sharedInstance.get(NSURL(string: firstFlip!.thumbnailURL)!,
                    success: { (localThumbnailPath: String!) in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let thumbnail = UIImage(contentsOfFile: localThumbnailPath)

                            self.thumbnailView.image = thumbnail
                            self.thumbnailView.hidden = self.isPlaying
                        })
                    },
                    failure: { (error: FlipError) in
                        println("Failed to get resource from cache, error: \(error)")
                })
            }
        }

        if (self.loadPlayerOnInit) {
            self.play()
        }
    }
    
    func setupPlayerWithWord(word: String, videoURL: NSURL, thumbnailURL: NSURL?) {
        self.words = [word]
        
        var videoAsset: AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        var flipPlayerItem = playerItemWithVideoAsset(videoAsset)
        flipPlayerItem.order = 0
        self.playerItems = [flipPlayerItem]
        
        if (thumbnailURL != nil) {
            let response = ThumbnailsCache.sharedInstance.get(thumbnailURL!,
                success: { (localThumbnailPath: String!) in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.thumbnailView.image = UIImage(contentsOfFile: localThumbnailPath)
                    })
                },
                failure: { (error: FlipError) in
                    println("Failed to get resource from cache, error: \(error)")
                })
        }
        
        if (self.loadPlayerOnInit) {
            self.play()
        }
    }

    func playerItemWithVideoAsset(videoAsset: AVAsset) -> FlipPlayerItem {
        let playerItem: FlipPlayerItem = FlipPlayerItem(asset: videoAsset)

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"videoPlayerItemEnded:",
            name:AVPlayerItemDidPlayToEndTimeNotification, object:playerItem)

        return playerItem
    }

    func videoPlayerItemEnded(notification: NSNotification) {
        if let player = self.player() {
            let currentItem = player.currentItem as FlipPlayerItem
            
            if (self.playerItems.count == 1) {
                player.seekToTime(kCMTimeZero)
                delegate?.playerViewDidFinishPlayback(self)
                
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
    }

    func hasPlayer() -> Bool {
        let layer = self.layer as AVPlayerLayer
        return layer.player != nil
    }

    private func preparePlayer(completion: ((player: AVQueuePlayer?) -> Void)) {
        if let player = self.player() {
            completion(player: player)
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

        self.retryButtonView = UIImageView()
        self.retryButtonView.alpha = 0.6
        self.retryButtonView.contentMode = UIViewContentMode.Center
        self.retryButtonView.image = UIImage(named: "RetryButton")
        self.retryButtonView.hidden = true
        self.addSubview(self.retryButtonView)

        self.progressBarView = UIProgressView()
        self.progressBarView.hidden = true
        self.addSubview(self.progressBarView)
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
        self.retryButtonView.mas_makeConstraints({ (make) -> Void in
            make.width.equalTo()(self.thumbnailView)
            make.height.equalTo()(self.thumbnailView)
            make.center.equalTo()(self.thumbnailView)
        })

        self.progressBarView.mas_makeConstraints({ (make) -> Void in
            make.left.equalTo()(self.thumbnailView)
            make.right.equalTo()(self.thumbnailView)
            make.bottom.equalTo()(self.thumbnailView)
            make.height.equalTo()(10)
        })
    }

    func releaseResources() {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        self.thumbnailView.image = nil
        self.wordLabel.text = ""
        self.flips = nil
        self.playerItems = [FlipPlayerItem]()
        self.words = []

        if let player = self.player() {
            player.removeAllItems()
        }
        
        let layer = self.layer as AVPlayerLayer
        layer.player = nil
    }

}

protocol PlayerViewDelegate: class {
    
    func playerViewDidFinishPlayback(playerView: PlayerView)
    func playerViewIsVisible(playerView: PlayerView) -> Bool
    
}
