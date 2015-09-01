//
//  ComposeOptionsView.swift
//  flips
//
//  Created by Taylor Bell on 8/22/15.
//
//

class ComposeCaptureControlsView : UIView, UIScrollViewDelegate, FlipsViewDelegate {
    
    weak var delegate : ComposeCaptureControlsViewDelegate?
    weak var dataSource : FlipsViewDataSource? {
        set {
            self.myFlipsView!.dataSource = newValue
            self.bottomMyFlipsView!.dataSource = newValue
        }
        get { return self.myFlipsView!.dataSource }
    }
    
    // Video Recording Timer
    private var videoTimer : NSTimer!
    
    // UI
    private var optionsScrollView : UIScrollView!
    private var myFlipsView : FlipsView!
    private var cameraView : UIView!
    private var topGalleryView : UIView!
    private var galleryView : UIView!
    private var videoView : UIView!
    private var bottomMyFlipsView : FlipsView!
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        self.initSubviews()
        self.initConstraints()
    }
    
    
    
    ////
    // MARK: - Subview Initialization
    ////
    
    private func initSubviews() {
        
        // Shared Button Image
        
        var captureImage = UIImage(named: "Capture")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        // Video Button Long Press Recognizer
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleVideoButtonPress:"))
        longPressRecognizer.minimumPressDuration = 0.001
        
        // Flips Views
        
        myFlipsView = FlipsView()
        myFlipsView.delegate = self
        
        bottomMyFlipsView = FlipsView()
        bottomMyFlipsView.delegate = self
        
        // Button Containers
        
        topGalleryView = buttonView(image: captureImage, tintColor: UIColor.greenColor(), tapSelector: Selector("handleGalleryButtonTap:"))
        videoView = buttonView(image: captureImage, tintColor: UIColor.orangeColor(), gestureRecognizer: longPressRecognizer)
        cameraView = buttonView(image: captureImage, tintColor: UIColor.blueColor(), tapSelector: Selector("handleCameraButtonTap:"))
        galleryView = buttonView(image: captureImage, tintColor: UIColor.greenColor(), tapSelector: Selector("handleGalleryButtonTap:"))
        
        disableCameraControls()
        
        // ScrollView
        
        optionsScrollView = UIScrollView()
        optionsScrollView.pagingEnabled = true
        optionsScrollView.backgroundColor = UIColor.sand()
        optionsScrollView.delegate = self;
        optionsScrollView.showsHorizontalScrollIndicator = false
        optionsScrollView.showsVerticalScrollIndicator = false
        
        optionsScrollView.addSubview(topGalleryView)
        optionsScrollView.addSubview(myFlipsView)
        optionsScrollView.addSubview(videoView)
        optionsScrollView.addSubview(cameraView)
        optionsScrollView.addSubview(galleryView)
        optionsScrollView.addSubview(bottomMyFlipsView)
        
        addSubview(optionsScrollView)
        
    }
    
    private func initConstraints() {
        
        self.optionsScrollView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.top.equalTo()(self)
            make.height.equalTo()(self)
            make.width.equalTo()(self)
        }
        
        topGalleryView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.optionsScrollView)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        myFlipsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.topGalleryView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        videoView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.myFlipsView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        cameraView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.videoView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        galleryView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.cameraView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        bottomMyFlipsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.galleryView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
    }
    
    
    
    ////
    // MARK: - Lifecycle
    ////
    
    override func layoutSubviews() {
        super.layoutSubviews()
        optionsScrollView.contentSize = CGSizeMake(optionsScrollView.frame.width, optionsScrollView.frame.height * 6)
        optionsScrollView.contentOffset = CGPoint(x: 0, y: optionsScrollView.frame.height)
    }
    
    
    
    ////
    // MARK: - Button Setup
    ////
    
    func buttonView(image: UIImage? = nil, tintColor: UIColor? = nil, gestureRecognizer: UIGestureRecognizer? = nil, tapSelector: Selector? = nil) -> (UIView) {
        
        let button = UIButton()
        
        if let buttonImage = image {
            button.setImage(buttonImage, forState: .Normal)
            button.sizeToFit()
        }
        
        if let buttonColor = tintColor {
            button.tintColor = tintColor
        }
        
        if let gestureRec = gestureRecognizer {
            button.addGestureRecognizer(gestureRec)
        }
        
        if let tapAction = tapSelector {
            button.addTarget(self, action: tapAction, forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        let buttonContainer = UIView()
        buttonContainer.addSubview(button)
        
        button.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(buttonContainer)
            make.centerY.equalTo()(buttonContainer)
            make.height.equalTo()(button.frame.height)
            make.width.equalTo()(button.frame.width)
        }
        
        return buttonContainer
        
    }
    
    
    
    ////
    // MARK: - UIScrollViewDelegate
    ////
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let currentPage = scrollView.contentOffset.y / scrollView.frame.height
        
        if (currentPage == 0)
        {
            scrollView.scrollRectToVisible(CGRectMake(0, scrollView.frame.height * 4, scrollView.frame.width, scrollView.frame.height), animated: false)
        }
        else if (currentPage == 5)
        {
            scrollView.scrollRectToVisible(CGRectMake(0, scrollView.frame.height, scrollView.frame.width, scrollView.frame.height), animated: false)
        }
        
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
    
    func scrollToVideoButton() {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.75) * Int64(NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
            self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height * 2), animated: true)
        }
    }
    
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
    // MARK: - FlipsViewDelegate
    ////
    
    func flipsViewDidTapAddFlip(flipsView: FlipsView!) {
        // Ignore this, this has been phased out
    }
    
    func flipsView(flipsView: FlipsView!, didTapAtIndex index: Int, fromStockFlips isStockFlip: Bool) {
        
        if (isStockFlip) {
            delegate?.didSelectStockFlipAtIndex(index)
        }
        else {
            delegate?.didSelectFlipAtIndex(index)
        }
        
    }
    
}

protocol ComposeCaptureControlsViewDelegate : class {
    
    func didSelectStockFlipAtIndex(index: Int)
    
    func didSelectFlipAtIndex(index: Int)
    
    func didPressVideoButton()
    
    func didReleaseVideoButton()
    
    func didTapCapturePhotoButton()
    
    func didTapGalleryButton()
    
}