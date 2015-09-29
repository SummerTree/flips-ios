//
//  FlipCompositionPlayerView.swift
//  flips
//
//  Created by Taylor Bell on 8/27/15.
//
//

import Foundation

class FlipCompositionPlayerView : UIView, PlayerViewDelegate, UIGestureRecognizerDelegate {
    
    private enum PreviewType {
        case None
        case Camera
        case Image
        case Flip
    }
    
    private var currentPreviewType : PreviewType = .None
    
    // UI
    private var flipImageView : UIImageView!
    private var flipPlayerView : PlayerView!
    private var flipWordLabel : UILabel!
    
    // Content
    internal var flip : Flip?
    internal var flipImage : UIImage?
    internal var flipText : String?
    
    // Autoplay Flip
    private var shouldAutoPlayFlip : Bool! = false
    
    // Delegate
    weak var delegate : FlipCompositionPlayerViewDelegate?
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(flip: Flip?, autoPlay: Bool = false) {
        super.init(frame: CGRectZero)
        self.flip = flip
        self.currentPreviewType = .Flip
        self.backgroundColor = UIColor.blackColor()
        self.shouldAutoPlayFlip = autoPlay
        initSubviews()
        initConstraints()
        initContent()
    }
    
    init(image: UIImage, text: String) {
        super.init(frame: CGRectZero)
        self.flipImage = image
        self.flipText = text
        self.currentPreviewType = .Image
        self.backgroundColor = UIColor.blackColor()
        initSubviews()
        initConstraints()
        initContent()
    }
    
    private func initSubviews() {
        
        if (currentPreviewType == .Image)
        {
            flipImageView = UIImageView()
            flipImageView.contentMode = .ScaleAspectFill
            flipImageView.image = flipImage
            self.addSubview(flipImageView)
            
            flipWordLabel = UILabel.flipWordLabel()
            flipWordLabel.text = flipText
            flipWordLabel.sizeToFit()
            self.addSubview(flipWordLabel)
        }
        else
        {
            flipPlayerView = PlayerView()
            flipPlayerView.loadPlayerOnInit = shouldAutoPlayFlip
            flipPlayerView.delegate = self
            self.addSubview(flipPlayerView)
        }
        
    }
    
    private func initConstraints() {
        
        if (currentPreviewType == .Image)
        {
            flipWordLabel.mas_makeConstraints({ (make) -> Void in
                make.bottom.equalTo()(self).with().offset()(FLIP_WORD_LABEL_MARGIN_BOTTOM)
                make.centerX.equalTo()(self)
            })
            
            flipImageView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self)
                make.left.equalTo()(self)
                make.right.equalTo()(self)
                make.height.equalTo()(self)
            }
        }
        else
        {
            flipPlayerView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self)
                make.left.equalTo()(self)
                make.right.equalTo()(self)
                make.height.equalTo()(self.mas_width)
            }
        }
        
    }
    
    private func initContent() {
        
        if currentPreviewType == .Flip && self.flip != nil
        {
            self.flipPlayerView.setupPlayerWithFlips([self.flip!], andFormattedWords: [self.flip!.word])
        }
        
    }
    
    
    
    ////
    // MARK: - Public Interface
    ////
    
    internal func playFlip() {
        
        if let currentFlip = flip
        {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if self.flipPlayerView.isSetupWithFlips([currentFlip], andFormattedWords: [currentFlip.word])
                {
                    self.flipPlayerView.play()
                }
                else
                {
                    self.flipPlayerView.loadPlayerOnInit = false
                    self.flipPlayerView.setupPlayerWithFlips([currentFlip], andFormattedWords: [currentFlip.word])
                }
                
            })
        }
        else
        {
            UIAlertView.showUnableToLoadFlip()
        }
        
    }
    
    
    
    ////
    // MARK: - PlayerViewDelegate
    ////
    
    func playerViewDidFinishPlayback(playerView: PlayerView) {
        delegate?.flipPlayerViewDidFinishPlayback()
    }
    
    func playerViewIsVisible(playerView: PlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowPlayButtonOnInitialState(playerView: PlayerView) -> Bool {
        return true
    }   
    
}

protocol FlipCompositionPlayerViewDelegate : class {
    
    func flipPlayerViewDidFinishPlayback()
    
}