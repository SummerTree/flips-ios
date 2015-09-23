//
//  ComposeOptionsView.swift
//  flips
//
//  Created by Taylor Bell on 8/22/15.
//
//

enum CaptureButtonOption : String {
    case Video = "Video"
    case Camera = "Camera"
    case Gallery = "Gallery"
    case Delete = "Delete"
}

class ComposeCaptureControlsView : EndlessScrollView, FlipSelectionViewDelegate {
    
    private let SCROLL_DELAY = dispatch_time(DISPATCH_TIME_NOW, Int64(0.75) * Int64(NSEC_PER_SEC))
    
    weak var delegate : CaptureControlsViewDelegate?
    weak var dataSource : FlipSelectionViewDataSource? {
        set {
            flipsView.dataSource = newValue
        }
        get {
            return flipsView.dataSource!
        }
    }
    
    // Video Recording Timer
    private var videoTimer : NSTimer!
    
    // UI
    private var flipsView : FlipsSelectionView!
    private var videoView : UIView!
    private var cameraView : UIView!
    private var galleryView : UIView!
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        self.initSubviews()
    }
    
    
    
    ////
    // MARK: - Subview Initialization
    ////
    
    private func initSubviews() {
        
        // Video Button Long Press Recognizer
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleVideoButtonPress:"))
        longPressRecognizer.minimumPressDuration = 0.1
        
        // Flips Views
        
        flipsView = FlipsSelectionView()
        flipsView.delegate = self
        flipsView.backgroundColor = UIColor.lightGreyF2()
        
        // Button Containers
        
        videoView = buttonView(.Video, gestureRecognizer: longPressRecognizer)
        cameraView = buttonView(.Camera, tapSelector: Selector("handleCameraButtonTap:"))
        galleryView = buttonView(.Gallery, tapSelector: Selector("handleGalleryButtonTap:"))
        
        disableCameraControls()
        
        addViews([flipsView, videoView, cameraView, galleryView])
        
    }
    
    
    
    ////
    // MARK: - Button Setup
    ////
    
    func buttonView(option: CaptureButtonOption, gestureRecognizer: UIGestureRecognizer? = nil, tapSelector: Selector? = nil) -> (UIView) {
        
        let imageSizer = UIImageView(image: UIImage(named: "Capture")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        let sizerMult : CGFloat = 1.35
        
        let button = UIButton(type: .Custom)
        button.tintColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3.0
        button.layer.cornerRadius = (imageSizer.frame.height * sizerMult) / 2
        button.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        //button.shadowMe()
        
        switch option {
            case .Video:
                button.backgroundColor = UIColor.redColor()
                button.setImage(UIImage(named: "VideoRecord")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
                break
            case .Camera:
                button.backgroundColor = UIColor.lightGrayColor()
                button.setImage(UIImage(named: "CameraNew")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
                //button.tintColor = UIColor.grayColor()
                break
            case .Gallery:
                button.backgroundColor = UIColor.flipOrange()
                button.setImage(UIImage(named: "Gallery")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
                ////button.tintColor = UIColor.lightSemitransparentBackground()
                break
        default:
                break
        }
        
        if let gestureRec = gestureRecognizer {
            button.addGestureRecognizer(gestureRec)
        }
        
        if let tapAction = tapSelector {
            button.addTarget(self, action: tapAction, forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        let buttonContainer = UIView()
        buttonContainer.backgroundColor = UIColor.lightGreyF2()
        buttonContainer.addSubview(button)
        
        button.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(buttonContainer)
            make.centerY.equalTo()(buttonContainer)
            make.height.equalTo()(imageSizer.frame.height * sizerMult)
            make.width.equalTo()(imageSizer.frame.height * sizerMult)
        }
        
        let heightDivider : CGFloat = 3
        
        button.imageView!.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(button).offset()(imageSizer.frame.height / heightDivider)
            make.top.equalTo()(button).offset()(imageSizer.frame.height / heightDivider)
            make.right.equalTo()(button).offset()(-1 * (imageSizer.frame.height / heightDivider))
            make.bottom.equalTo()(button).offset()(-1 * (imageSizer.frame.height / heightDivider))
        }
        
        return buttonContainer
        
    }
    
    
    
    ////
    // MARK: - Camera Controls
    ////
    
    func enableCameraControls() {
        self.cameraView.userInteractionEnabled = true
        self.videoView.userInteractionEnabled = true
    }
    
    func disableCameraControls() {
        self.cameraView.userInteractionEnabled = false
        self.videoView.userInteractionEnabled = false
    }
    
    
    
    ////
    // MARK: - Scrolling
    ////
    
    func scrollToFlipsView(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.scrollToPageIndex(0, animated: true)
            }
        }
        else
        {
            scrollToPageIndex(0, animated: false)
        }
        
    }
    
    func scrollToVideoButton(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.scrollToPageIndex(1, animated: true)
            }
        }
        else
        {
            scrollToPageIndex(1, animated: false)
        }
        
    }
    
    func scrollToPhotoButton(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.scrollToPageIndex(2, animated: true)
            }
        }
        else
        {
            scrollToPageIndex(2, animated: false)
        }
        
    }
    
    func scrollToGalleryButton(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.scrollToPageIndex(3, animated: true)
            }
        }
        else
        {
            scrollToPageIndex(3, animated: false)
        }
        
    }
    
    
    
    ////
    // MARK: - FlipsView
    ////
    
    func reloadFlipsView() {
        flipsView.reloadData()
    }
   
    func showUserFlips(animated: Bool) {
        
        if animated {
            flipsView.showUserFlipsViewAnimated()
        }
        else {
            flipsView.showUserFlipsView()
        }
        
    }
    
    func dismissUserFlips(animated: Bool) {
        
        if animated {
            flipsView.dismissUserFlipsViewAnimated()
        }
        else {
            flipsView.dismissUserFlipsView()
        }
        
    }
    
    func showStockFlips(animated: Bool) {
        
        if animated {
            flipsView.showStockFlipsViewAnimated()
        }
        else {
            flipsView.showStockFlipsView()
        }
        
    }
    
    func dismissStockFlips(animated: Bool) {
        
        if animated {
            flipsView.dismissStockFlipsViewAnimated()
        }
        else {
            flipsView.dismissStockFlipsView()
        }
        
    }
    
    
    
    ////
    // MARK: - Gallery Button
    ////
    
    func handleGalleryButtonTap(sender: UIButton) {
        self.delegate?.didTapGalleryButton()
    }
    
    
    
    ////
    // MARK: - Camera Button
    ////
    
    func handleCameraButtonTap(sender: UIButton) {
        self.delegate?.didTapCapturePhotoButton()
    }
    
    
    
    ////
    // MARK: - Video Timer & Button
    ////
    
    func handleVideoButtonPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        switch(gestureRecognizer.state) {
            case .Began:
                self.delegate?.didPressVideoButton()
                startVideoTimer()
                break;
            case .Ended:
                if let timer = self.videoTimer {
                    clearVideoTimer()
                    self.delegate?.didReleaseVideoButton()
                }
                break;
            default:
                break;
        }
        
    }
    
    
    
    ////
    // MARK: - Video Timer
    ////
    
    func startVideoTimer() {
        videoTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("handleVideoTimerExpired"), userInfo: nil, repeats: false)
    }
    
    func clearVideoTimer() {
        videoTimer.invalidate()
        videoTimer = nil
    }
    
    func handleVideoTimerExpired() {
        
        if let timer = self.videoTimer {
            clearVideoTimer()
            delegate?.didReleaseVideoButton()
        }
        
    }
    
    
    
    ////
    // MARK: - FlipSelectionViewDelegate
    ////
    
    func didOpenUserFlipsView() {
        delegate?.captureControlsDidShowUserFlips()
    }
    
    func didDismissUserFlipsView() {
        delegate?.captureControlsDidDismissUserFlips()
    }
    
    func didSelectUserFlipAtIndex(index: Int) {
        delegate?.didSelectFlipAtIndex(index)
    }
    
    func didOpenStockFlipsView() {
        delegate?.captureControlsDidShowStockFlips()
    }
    
    func didDismissStockFlipsView() {
        delegate?.captureControlsDidDismissStockFlips()
    }
    
    func didSelectStockFlipAtIndex(index: Int) {
        delegate?.didSelectStockFlipAtIndex(index)
    }
    
    
}

protocol CaptureControlsViewDelegate : class {
    
    func captureControlsDidShowUserFlips()
    
    func captureControlsDidDismissUserFlips()
    
    func captureControlsDidShowStockFlips()
    
    func captureControlsDidDismissStockFlips()
    
    func didSelectStockFlipAtIndex(index: Int)
    
    func didSelectFlipAtIndex(index: Int)
    
    func didPressVideoButton()
    
    func didReleaseVideoButton()
    
    func didTapCapturePhotoButton()
    
    func didTapGalleryButton()
    
}