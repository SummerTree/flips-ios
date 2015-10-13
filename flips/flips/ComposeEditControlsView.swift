//
//  ComposeEditControlsView.swift
//  flips
//
//  Created by Taylor Bell on 8/25/15.
//
//

class ComposeEditControlsView : EndlessScrollView, FlipSelectionViewDelegate {
    
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
    private var flipsView : FlipsSelectionView!
    private var deleteView : UIView!
    
    
    
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
        
        // Flips Views
        
        flipsView = FlipsSelectionView()
        flipsView.delegate = self
        flipsView.backgroundColor = UIColor.lightGreyF2()
        
        // Button Containers
        
        deleteView = buttonView(.Delete, tapSelector: Selector("handleDeleteButtonTap:"))
        
        addViews([flipsView, deleteView])
        
    }
    
    
    
    ////
    // MARK: - Button Setup
    ////
    
    func buttonView(option: CaptureButtonOption, gestureRecognizer: UIGestureRecognizer? = nil, tapSelector: Selector? = nil) -> (UIView) {
        
        let imageSizer = UIImageView(image: UIImage(named: "Capture")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate))
        
        let button = UIButton(type: .Custom)
        button.tintColor = UIColor.whiteColor()
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 3.0
        button.layer.cornerRadius = 5.0
        button.titleLabel!.font = UIFont.avenirNextMedium(15.0)
        //button.shadowMe()
        
        switch option {
            case .Delete:
                button.backgroundColor = UIColor.flipOrange()
                button.setTitle("Epic Fail? Try again.", forState: .Normal)
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
            make.center.equalTo()(buttonContainer)
            make.height.equalTo()(imageSizer.frame.height)
            make.left.equalTo()(buttonContainer).offset()(50)
            make.right.equalTo()(buttonContainer).offset()(-50)
        }
        
//        let heightDivider : CGFloat = 3
//        
//        button.imageView!.mas_makeConstraints { (make) -> Void in
//            make.left.equalTo()(button).offset()(imageSizer.frame.height / heightDivider)
//            make.top.equalTo()(button).offset()(imageSizer.frame.height / heightDivider)
//            make.right.equalTo()(button).offset()(-1 * (imageSizer.frame.height / heightDivider))
//            make.bottom.equalTo()(button).offset()(-1 * (imageSizer.frame.height / heightDivider))
//        }
        
        return buttonContainer
        
    }

    
    
    ////
    // MARK: - Update Delete Button
    ////
    
    func updateDeleteButton() {
        
        let button : UIButton? = deleteView.subviews[0] as? UIButton
        
        if let dataSource = flipsView.dataSource, let _ = dataSource.selectedFlipId() {
            button?.setTitle("Create a new Flip", forState: .Normal)
        }
        else {
            button?.setTitle("Epic Fail? Try again.", forState: .Normal)
        }
        
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
    
    func scrollToDeleteButton(animated: Bool) {
        
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