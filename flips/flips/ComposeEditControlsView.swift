//
//  ComposeEditControlsView.swift
//  flips
//
//  Created by Taylor Bell on 8/25/15.
//
//

class ComposeEditControlsView : UIView, UIScrollViewDelegate, FlipSelectionViewDelegate {
    
    let SCROLL_DELAY = dispatch_time(DISPATCH_TIME_NOW, Int64(0.75) * Int64(NSEC_PER_SEC));
    
    weak var delegate : EditControlsViewDelegate?
    weak var dataSource : FlipSelectionViewDataSource? {
        set {
            flipsView.dataSource = newValue
        }
        get {
            return flipsView.dataSource!
        }
    }
    
    // UI
    private var optionsScrollView : UIScrollView!
    
    private var flipsView : FlipsSelectionView!
    
    private var overflowFlipsView : UIImageView!
    
    private var deleteView : UIView!
    private var overflowDeleteView : UIView!
    
    
    
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
        
        // Flips Views
        
        flipsView = FlipsSelectionView()
        flipsView.delegate = self
        flipsView.backgroundColor = UIColor.lightGreyF2()
        
        overflowFlipsView = UIImageView()
        
        // Button Containers
        
        deleteView = buttonView(image: captureImage, tintColor: UIColor.redColor(), tapSelector: Selector("handleDeleteButtonTap:"))
        overflowDeleteView = buttonView(image: captureImage, tintColor: UIColor.redColor(), tapSelector: Selector("handleDeleteButtonTap:"))
        
        // ScrollView
        
        optionsScrollView = UIScrollView()
        optionsScrollView.pagingEnabled = true
        optionsScrollView.backgroundColor = UIColor.lightGreyF2()
        optionsScrollView.delegate = self;
        optionsScrollView.showsHorizontalScrollIndicator = false
        optionsScrollView.showsVerticalScrollIndicator = false
        
        optionsScrollView.addSubview(overflowDeleteView)
        optionsScrollView.addSubview(flipsView)
        optionsScrollView.addSubview(deleteView)
        optionsScrollView.addSubview(overflowFlipsView)
        
        addSubview(optionsScrollView)
        
    }
    
    private func initConstraints() {
        
        optionsScrollView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.top.equalTo()(self)
            make.height.equalTo()(self)
            make.width.equalTo()(self)
        }
        
        overflowDeleteView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.optionsScrollView)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        flipsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.overflowDeleteView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        deleteView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.flipsView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        overflowFlipsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.deleteView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
    }
    
    
    
    ////
    // MARK: - Lifecycle Overrides
    ////
    
    override func layoutSubviews() {
        super.layoutSubviews()
        optionsScrollView.contentSize = CGSizeMake(optionsScrollView.frame.width, optionsScrollView.frame.height * 4)
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
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        UIGraphicsBeginImageContextWithOptions(flipsView.bounds.size, flipsView.opaque, 0.0)
        
        flipsView.layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        overflowFlipsView.image = screenshot
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let currentPage = scrollView.contentOffset.y / scrollView.frame.height
        
        switch currentPage
        {
            case 0:
                scrollToDeleteButton(false)
            case 3:
                scrollToFlipsView(false)
            default:
                break
        }
        
    }
    
    
    
    ////
    // MARK: - Scrolling
    ////
    
    func scrollToFlipsView(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height), animated: true)
            }
        }
        else
        {
            self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height), animated: false)
        }
    }
    
    func scrollToDeleteButton(animated: Bool) {
        
        if animated
        {
            dispatch_after(SCROLL_DELAY, dispatch_get_main_queue()) { () -> Void in
                self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height * 2), animated: true)
            }
        }
        else
        {
            self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height * 2), animated: false)
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
            
            if !flipsView.isUserFlipsViewActive() {
                flipsView.showUserFlipsViewAnimated()
            }
            
        }
        else {
            
            if !flipsView.isUserFlipsViewActive() {
                flipsView.showUserFlipsView()
            }
            
        }
        
    }
    
    func dismissUserFlips(animated: Bool) {
        
        if animated {
            
            if flipsView.isUserFlipsViewActive() {
                flipsView.dismissUserFlipsViewAnimated()
            }
            
        }
        else {
            
            if flipsView.isUserFlipsViewActive() {
                flipsView.dismissUserFlipsView()
            }
            
        }
        
    }
    
    func showStockFlips(animated: Bool) {
        
        if animated {
            
            if !flipsView.isStockFlipsViewActive() {
                flipsView.showStockFlipsViewAnimated()
            }
            
        }
        else {
            
            if !flipsView.isStockFlipsViewActive() {
                flipsView.showStockFlipsView()
            }
            
        }
        
    }
    
    func dismissStockFlips(animated: Bool) {
        
        if animated {
            
            if flipsView.isStockFlipsViewActive() {
                flipsView.dismissStockFlipsViewAnimated()
            }
            
        }
        else {
            
            if flipsView.isStockFlipsViewActive() {
                flipsView.dismissStockFlipsView()
            }
            
        }
        
    }
    
    
    
    ////
    // MARK: - Delete Button
    ////
    
    func handleDeleteButtonTap(sender: UIButton) {
        self.delegate?.didTapDeleteButton()
    }
    
    
    
    ////
    // MARK: - FlipSelectionViewDelegate
    ////
    
    func didOpenUserFlipsView() {
        delegate?.editControlsDidShowUserFlips()
    }
    
    func didDismissUserFlipsView() {
        delegate?.editControlsDidDismissUserFlips()
    }
    
    func didSelectUserFlipAtIndex(index: Int) {
        delegate?.didSelectFlipAtIndex(index)
    }
    
    func didOpenStockFlipsView() {
        delegate?.editControlsDidShowStockFlips()
    }
    
    func didDismissStockFlipsView() {
        delegate?.editControlsDidDismissStockFlips()
    }
    
    func didSelectStockFlipAtIndex(index: Int) {
        delegate?.didSelectStockFlipAtIndex(index)
    }
    
}

protocol EditControlsViewDelegate : class {
    
    func editControlsDidShowUserFlips()
    
    func editControlsDidDismissUserFlips()
    
    func editControlsDidShowStockFlips()
    
    func editControlsDidDismissStockFlips()
    
    func didSelectStockFlipAtIndex(index: Int)
    
    func didSelectFlipAtIndex(index: Int)
    
    func didTapDeleteButton()
    
}