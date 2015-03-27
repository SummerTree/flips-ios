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

    let BUTTONS_FADE_IN_OUT_ANIMATION_DURATION: NSTimeInterval = 0.25
    let BUTTONS_ALPHA: CGFloat = 0.6
    let PROGRESS_BAR_PADDING: CGFloat = 30
    let PROGRESS_BAR_HEIGHT: CGFloat = 10
    
    var isPlaying = false
    var loadPlayerOnInit = false
    var playInLoop = false
    var loadingFlips = false
    var hasDownloadError = false
    
    private var flips: Array<Flip>!
    private var words: Array<String>?
    private var playerItems: Array<FlipPlayerItem> = [FlipPlayerItem]()
    private var flipsDownloadProgress: Array<Float> = [Float]()
    private var thumbnail: UIImage?
    private var timer: NSTimer?

    private var gradientLayer: CALayer!
    private var wordLabel: UILabel!
    private var thumbnailView: UIImageView!
    private var playButtonView: UIImageView!
    private var retryButtonView: UIImageView!
    private var retryLabel: UILabel!
    private var activityIndicator: UIActivityIndicatorView!
    private var progressBarView: ProgressBar!

    weak var delegate: PlayerViewDelegate?
    
    private var contentIdentifier: String?
    
    // MARK: - Initializers

    override init() {
        super.init(frame: CGRect.zeroRect)
        self.addSubviews()
        self.makeConstraints()

        self.contentIdentifier = nil
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubviews()
        self.makeConstraints()
        
        self.contentIdentifier = nil
    }
    
    deinit {
        self.releaseResources()
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }


    // MARK: - Accessors

    private func player() -> AVQueuePlayer? {
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

    private func setWord(word: String) {
        self.wordLabel.text = word
    }
    
    private func generateRandomIdentifier() {
        self.contentIdentifier = NSUUID().UUIDString
    }


    // MARK: - Animations

    private func animateButtonsFadeOut(completion: (() -> Void)?) {
        UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
            self.thumbnailView.alpha = 0.0
            self.playButtonView.alpha = 0.0
            self.retryButtonView.alpha = 0.0
            self.retryLabel.alpha = 0.0
            self.progressBarView.alpha = 0.0
        }) { (finished) -> Void in
            completion?()
            return
        }
    }

    private func animatePlayButtonFadeIn(completion: (() -> Void)?) {
        UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
            self.playButtonView.alpha = self.BUTTONS_ALPHA
            self.progressBarView.alpha = 0.0
            self.retryButtonView.alpha = 0.0
            self.retryLabel.alpha = 0.0
        }) { (finished) -> Void in
            completion?()
            return
        }
    }

    private func animateErrorStateFadeIn(completion: (() -> Void)?) {
        UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
            self.retryButtonView.alpha = self.BUTTONS_ALPHA
            self.retryLabel.alpha = 1.0
            self.playButtonView.alpha = 0.0
            self.progressBarView.alpha = 0.0
        }) { (finished) -> Void in
            completion?()
            return
        }
    }

    private func animateProgressBarFadeIn(completion: (() -> Void)?) {
        UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
            self.progressBarView.alpha = 1.0
            self.playButtonView.alpha = 0.0
            self.retryButtonView.alpha = 0.0
            self.retryLabel.alpha = 0.0
        }) { (finished) -> Void in
            completion?()
            return
        }
    }


    // MARK: - Playback control

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
            if (self.flips != nil) {
                isPlayerReady = self.playerItems.count == self.flips.count
            }
        }

        if (isPlayerReady) {
            let currentIdentifier = self.contentIdentifier
            self.preparePlayer { (player) -> Void in
                if ((self.words != nil) && (self.words!.count == 0)) {
                    return
                }
                
                if (currentIdentifier != self.contentIdentifier) {
                    return
                }
                
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                
                if let playerItem: FlipPlayerItem = player?.currentItem as? FlipPlayerItem {
                    if ((self.words != nil) && (self.words?.count > playerItem.order)) {
                        self.setWord(self.words![playerItem.order])
                    }
                    
                    self.animateButtonsFadeOut({ () -> Void in
                        if (currentIdentifier != self.contentIdentifier) {
                            return
                        }
                        
                        // Since it needs to wait the animation, the user can press back button, so it won't exist.
                        if (player != nil) {
                            self.isPlaying = true
                            player!.volume = 1.0
                            player!.play()
                        }
                    })
                }
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
                self.animatePlayButtonFadeIn(nil)
                self.fadeOutVolume()
            })
        } else {
            self.isPlaying = false
            self.animatePlayButtonFadeIn(nil)
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
    
    private func onFlipMessagePlaybackFinishedWithCompletion(completionBlock: (() -> Void)?) {
        delegate?.playerViewDidFinishPlayback(self)
        
        let currentIdentifier = self.contentIdentifier
        
        // Change the thumbnail
        if (self.flips != nil) {
            if let firstFlip = self.flips.first {
                if (firstFlip.thumbnailURL != nil && !firstFlip.thumbnailURL.isEmpty) {
                    if let remoteURL: NSURL = NSURL(string: firstFlip.thumbnailURL) {
                        ThumbnailsCache.sharedInstance.get(remoteURL, success: { (url: String!, localThumbnailPath: String!) -> Void in
                            if (currentIdentifier != self.contentIdentifier) {
                                completionBlock?()
                                return
                            }
                            
                            var thumbnail: UIImage? = UIImage(contentsOfFile: localThumbnailPath)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if (currentIdentifier != self.contentIdentifier) {
                                    completionBlock?()
                                    return
                                }
                                
                                self.thumbnailView.image = thumbnail
                                
                                UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
                                    self.thumbnailView.alpha = 1
                                    return
                                }, completion: { (finished: Bool) -> Void in
                                    completionBlock?()
                                    return
                                })
                            })
                        }, failure: { (url: String!, flipError: FlipError) -> Void in
                            println("Failed to get resource from cache, error: \(error)")
                            completionBlock?()
                        })
                        return
                    }
                }
            }
        }
        completionBlock?()
    }


    // MARK: - View update

    private func updateDownloadProgress(progress: Float, of: Float, animated: Bool, duration: NSTimeInterval = 0.3, completion:(() -> Void)? = nil) {
        let progressRatio = progress / of

        // Avoid going back in the progress bar
        if (progressRatio < self.progressBarView.progress) {
            return
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.progressBarView.setProgress(progressRatio,
                animated: animated,
                duration: duration,
                completion: completion
            )
        })
    }

    private func showErrorState() {
        self.loadingFlips = false
        self.hasDownloadError = true
        self.playerItems.removeAll(keepCapacity: true)
        self.progressBarView.progress = 0

        self.animateErrorStateFadeIn(nil)
    }


    // MARK: - Resource loading

    private func loadFlipsResourcesForPlayback(completion: () -> Void) {
        let currentIdentifier = self.contentIdentifier
        
        self.loadingFlips = true
        self.hasDownloadError = false
        
        self.playerItems.removeAll(keepCapacity: true)
        
        var isWordsPreInitialized: Bool = true
        if (self.words == nil) {
            self.words = []
            isWordsPreInitialized = false
        }
        
        for (index, flip) in enumerate(self.flips) {
            if (!isWordsPreInitialized) {
                self.words!.append(flip.word)
            }
            
            if (flip.backgroundURL == nil || flip.backgroundURL.isEmpty) {
                let emptyVideoPath = NSBundle.mainBundle().pathForResource("empty_video", ofType: "mov")
                let videoAsset = AVURLAsset(URL: NSURL(fileURLWithPath: emptyVideoPath!), options: nil)
                let playerItem = self.playerItemWithVideoAsset(videoAsset)
                playerItem.order = index
                self.playerItems.append(playerItem)
                
                self.flipsDownloadProgress[index] = 1.0
                
                var animated = self.flips.count > 1
                
                self.updateDownloadProgress(Float(self.playerItems.count),
                    of: Float(self.flips.count),
                    animated: animated,
                    completion: { () -> Void in
                        if (currentIdentifier != self.contentIdentifier) {
                            return
                        }
                        
                        if (self.playerItems.count == self.flips.count) {
                            self.loadingFlips = false
                            self.sortPlayerItems()
                            completion()
                        }
                    }
                )
                
            } else {
                let response = FlipsCache.sharedInstance.videoForFlip(flip,
                    success: { (url: String!, localPath: String!) in
                        if (self.hasDownloadError) {
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (currentIdentifier != self.contentIdentifier) {
                                return
                            }
                            
                            if (self.flips == nil) {
                                return
                            }
                            
                            let videoAsset = AVURLAsset(URL: NSURL(fileURLWithPath: localPath), options: nil)
                            let playerItem = self.playerItemWithVideoAsset(videoAsset)
                            playerItem.order = index
                            self.playerItems.append(playerItem)
                            
                            self.flipsDownloadProgress[index] = 1.0
                            
                            if (self.playerItems.count == self.flips.count) {
                                self.loadingFlips = false
                                self.sortPlayerItems()
                                completion()
                            }
                        })
                    },
                    failure: { (url: String!, error: FlipError) in
                        println("Failed to get resource from cache, error: \(error)")
                        if (currentIdentifier != self.contentIdentifier) {
                            return
                        }
                        
                        self.showErrorState()
                    },
                    progress: { (p: Float) -> Void in
                        if (currentIdentifier != self.contentIdentifier) {
                            return
                        }
                        
                        self.flipsDownloadProgress[index] = p
                        
                        var progressPosition: Float = 0.0
                        for ratio in self.flipsDownloadProgress {
                            progressPosition += ratio
                        }

                        self.updateDownloadProgress(progressPosition,
                            of: Float(self.flipsDownloadProgress.count),
                            animated: true,
                            completion: nil
                        )
                    }
                )
                
                if (response == StorageCache.CacheGetResponse.DOWNLOAD_WILL_START) {
                    self.animateProgressBarFadeIn(nil)
                }
            }
        }
    }

    private func sortPlayerItems() {
        self.playerItems.sort { (itemOne: FlipPlayerItem, itemTwo: FlipPlayerItem) -> Bool in
            return itemOne.order < itemTwo.order
        }
    }

    func setupPlayerWithFlips(flips: Array<Flip>, andFormattedWords formattedWords: Array<String>? = nil, blurringThumbnail: Bool = false) {
        self.generateRandomIdentifier()
        
        let currentIdentifier = self.contentIdentifier
        
        self.flips = flips
        self.flipsDownloadProgress = [Float]()
        for (var i = 0; i < flips.count; i++) {
            self.flipsDownloadProgress.append(0.0);
        }

        self.words = formattedWords
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.progressBarView.progress = 0
        })
            
        let firstFlip = flips.first
        if (firstFlip != nil) {

            var word = firstFlip!.word
            if (formattedWords != nil) {
                word = formattedWords!.first
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.wordLabel.text = word
            })

            if (firstFlip!.thumbnailURL != nil && !firstFlip!.thumbnailURL.isEmpty) {
                if let remoteURL: NSURL = NSURL(string: firstFlip!.thumbnailURL) {
                    
                    var cacheInstance: ThumbnailsDataSource!
                    if (blurringThumbnail) {
                        cacheInstance = BlurredThumbnailsCache.sharedInstance
                    } else {
                        cacheInstance = ThumbnailsCache.sharedInstance
                    }
                    
                    cacheInstance.get(remoteURL, success: { (url: String!, localThumbnailPath: String!) -> Void in
                        if (currentIdentifier != self.contentIdentifier) {
                            return
                        }

                        var thumbnail: UIImage? = UIImage(contentsOfFile: localThumbnailPath)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if (currentIdentifier != self.contentIdentifier) {
                                return
                            }

                            self.thumbnailView.image = thumbnail
                            self.thumbnailView.alpha = 0
                            UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
                                self.thumbnailView.alpha = 1
                            })
                            self.thumbnailView.hidden = self.isPlaying
                        })
                    }, failure: { (url: String!, flipError: FlipError) -> Void in
                        println("Failed to get resource from cache, error: \(error)")
                    })
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (currentIdentifier != self.contentIdentifier) {
                        return
                    }

                    self.thumbnailView.image = UIImage(named: "Empty_Flip_Thumbnail")
                    self.thumbnailView.alpha = 0
                    UIView.animateWithDuration(self.BUTTONS_FADE_IN_OUT_ANIMATION_DURATION, animations: { () -> Void in
                        self.thumbnailView.alpha = 1
                    })
                    self.thumbnailView.hidden = self.isPlaying
                })
            }
        }

        if (self.loadPlayerOnInit) {
            self.play()
        }
    }
    
    func setupPlayerWithWord(word: String, videoURL: NSURL, thumbnailURL: NSURL?) {
        self.generateRandomIdentifier()
        
        self.words = [word]
        
        var videoAsset: AVURLAsset = AVURLAsset(URL: videoURL, options: nil)
        var flipPlayerItem = playerItemWithVideoAsset(videoAsset)
        flipPlayerItem.order = 0
        self.playerItems = [flipPlayerItem]
        
        if (thumbnailURL != nil) {
            let response = ThumbnailsCache.sharedInstance.get(thumbnailURL!,
                success: { (url: String!, localThumbnailPath: String!) in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.thumbnailView.image = UIImage(contentsOfFile: localThumbnailPath)
                    })
                },
                failure: { (url: String!, error: FlipError) in
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
                self.onFlipMessagePlaybackFinishedWithCompletion(nil)
                
                if (!self.playInLoop) {
                    self.pause()
                }
            } else {
                let advanceBlock = { () -> Void in
                    player.advanceToNextItem()
                    
                    let clonedPlayerItem = self.playerItemWithVideoAsset(currentItem.asset)
                    clonedPlayerItem.order = currentItem.order
                    player.insertItem(clonedPlayerItem, afterItem: nil)
                    
                    // Set next item's word
                    let nextWordIndex = (currentItem.order + 1) % self.words!.count
                    self.setWord(self.words![nextWordIndex])
                }
                
                if (currentItem.order == self.playerItems.count - 1) {
                    if (self.playInLoop) {
                        player.pause()
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector:Selector("play"), userInfo:nil, repeats:false)
                    } else {
                        self.pause()
                    }
                    self.onFlipMessagePlaybackFinishedWithCompletion(advanceBlock)
                } else {
                    advanceBlock()
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
   

    // MARK: - View lifecycle

    private func addSubviews() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pauseResume"))

        self.gradientLayer = CALayer()
        self.gradientLayer.contents = UIImage(named: "Filter_Photo")?.CGImage
        self.gradientLayer.frame = self.layer.bounds
        self.layer.addSublayer(self.gradientLayer)
        
        self.wordLabel = UILabel.flipWordLabel()
        self.wordLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.wordLabel)
        
        self.thumbnailView = UIImageView()
        self.thumbnailView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.thumbnailView)
    
        self.playButtonView = UIImageView()
        self.playButtonView.alpha = self.BUTTONS_ALPHA
        self.playButtonView.contentMode = UIViewContentMode.Center
        self.playButtonView.image = UIImage(named: "PlayButton")
        self.addSubview(self.playButtonView)

        self.retryButtonView = UIImageView()
        self.retryButtonView.alpha = 0.0
        self.retryButtonView.contentMode = UIViewContentMode.Center
        self.retryButtonView.image = UIImage(named: "RetryButton")
        self.addSubview(self.retryButtonView)

        self.retryLabel = UILabel()
        self.retryLabel.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: BUTTONS_ALPHA)
        self.retryLabel.textColor = UIColor.whiteColor()
        self.retryLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        self.retryLabel.textAlignment = NSTextAlignment.Center
        self.retryLabel.text = LocalizedString.DOWNLOAD_FAILED_RETRY
        self.retryLabel.sizeToFit()
        self.retryLabel.alpha = 0.0
        self.addSubview(self.retryLabel)

        self.progressBarView = ProgressBar()
        self.progressBarView.alpha = 0.0
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
            make.centerX.equalTo()(self.thumbnailView)
            make.centerY.equalTo()(self.thumbnailView)
        })

        self.retryLabel.mas_makeConstraints({ (make) -> Void in
            make.top.equalTo()(self.retryButtonView.mas_bottom)
            make.centerX.equalTo()(self.thumbnailView)
        })

        self.progressBarView.mas_makeConstraints({ (make) -> Void in
            make.center.equalTo()(self.thumbnailView)
            make.width.equalTo()(self.thumbnailView.mas_height).with().offset()(-(self.PROGRESS_BAR_PADDING * 2))
            make.height.equalTo()(self.PROGRESS_BAR_HEIGHT)
        })
    }

    func releaseResources() {
        self.contentIdentifier = nil
        
        NSNotificationCenter.defaultCenter().removeObserver(self)

        self.loadingFlips = false
        self.thumbnailView.image = nil
        self.wordLabel.text = ""
        self.flips = nil
        self.playerItems = [FlipPlayerItem]()
        self.words = []
        
        self.playButtonView.alpha = 1
        self.progressBarView.alpha = 0

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
