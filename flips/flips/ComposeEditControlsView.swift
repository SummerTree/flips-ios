//
//  ComposeEditControlsView.swift
//  flips
//
//  Created by Taylor Bell on 8/25/15.
//
//

class ComposeEditControlsView : UIView, UIScrollViewDelegate, FlipsViewDelegate {
    
    weak var delegate : ComposeEditControlsViewDelegate?
    weak var dataSource : FlipsViewDataSource? {
        set {
            self.myFlipsView!.dataSource = newValue
            self.bottomMyFlipsView!.dataSource = newValue
        }
        get { return self.myFlipsView!.dataSource }
    }
    
    // UI
    private var optionsScrollView : UIScrollView!
    private var myFlipsView : FlipsView!
    private var bottomMyFlipsView : FlipsView!
    private var deleteView : UIView!
    private var topDeleteView : UIView!
    
    
    
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
        
        myFlipsView = FlipsView()
        myFlipsView.delegate = self
        
        bottomMyFlipsView = FlipsView()
        bottomMyFlipsView.delegate = self
        
        // Button Containers
        
        deleteView = buttonView(image: captureImage, tintColor: UIColor.redColor(), tapSelector: Selector("handleDeleteButtonTap:"))
        topDeleteView = buttonView(image: captureImage, tintColor: UIColor.redColor(), tapSelector: Selector("handleDeleteButtonTap:"))
        
        // ScrollView
        
        optionsScrollView = UIScrollView()
        optionsScrollView.pagingEnabled = true
        optionsScrollView.backgroundColor = UIColor.sand()
        optionsScrollView.delegate = self;
        optionsScrollView.showsHorizontalScrollIndicator = false
        optionsScrollView.showsVerticalScrollIndicator = false
        
        optionsScrollView.addSubview(topDeleteView)
        optionsScrollView.addSubview(myFlipsView)
        optionsScrollView.addSubview(deleteView)
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
        
        topDeleteView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.optionsScrollView)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        myFlipsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.topDeleteView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        deleteView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.optionsScrollView)
            make.top.equalTo()(self.myFlipsView.mas_bottom)
            make.height.equalTo()(self.optionsScrollView)
            make.width.equalTo()(self.optionsScrollView)
        }
        
        bottomMyFlipsView.mas_makeConstraints { (make) -> Void in
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let currentPage = scrollView.contentOffset.y / scrollView.frame.height
        
        if (currentPage == 0)
        {
            scrollView.scrollRectToVisible(CGRectMake(0, scrollView.frame.height * 2, scrollView.frame.width, scrollView.frame.height), animated: false)
        }
        else if (currentPage == 3)
        {
            scrollView.scrollRectToVisible(CGRectMake(0, scrollView.frame.height, scrollView.frame.width, scrollView.frame.height), animated: false)
        }
        
    }
    
    
    
    ////
    // MARK: - Delete Button
    ////
    
    func scrollToDeleteButton() {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.75) * Int64(NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
            self.optionsScrollView.setContentOffset(CGPointMake(0, self.optionsScrollView.frame.height), animated: true)
        }
    }
    
    func handleDeleteButtonTap(sender: UIButton) {
        self.delegate?.didTapDeleteButton()
    }
    
    
    
    ////
    // MARK: - FlipsViewDelegate
    ////
    
    func flipsViewDidTapAddFlip(flipsView: FlipsView!) {
        // Ignore this, it's been phased out
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

protocol ComposeEditControlsViewDelegate : class {
    
    func didSelectStockFlipAtIndex(index: Int)
    
    func didSelectFlipAtIndex(index: Int)
    
    func didTapDeleteButton()
    
}