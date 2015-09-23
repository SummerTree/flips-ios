//
//  FlipsSelectionView.swift
//  flips
//
//  Created by Taylor Bell on 9/1/15.
//
//

import Foundation

class FlipsSelectionView : UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private let VIEW_INSET : CGFloat = 20.0
    private let VIEW_SPACING : CGFloat = 10.0
    private let CELL_WIDTH : CGFloat = 83.5
    private let CELL_HEIGHT : CGFloat = 83.5
    
    internal weak var delegate : FlipSelectionViewDelegate?
    internal weak var dataSource : FlipSelectionViewDataSource?
    
    private var emptyLabel : UILabel!
    private var userFlipsButton : UIButton!
    private var stockFlipsButton : UIButton!
    private var flipsCollectionView : UICollectionView!
    
    private var isShowingUserFlips : Bool = false
    private var isShowingStockFlips : Bool = false
    
    ////
    // MARK: - Init
    ////
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    
    
    ////
    // MARK: - Subview Initialization
    ////
    
    func initSubviews() {
        
        userFlipsButton = UIButton(type: .System)
        userFlipsButton.layer.cornerRadius = 3.0
        userFlipsButton.layer.borderWidth = 1.0
        userFlipsButton.layer.borderColor = UIColor.flipOrange().CGColor
        userFlipsButton.setTitle("My Flips", forState: .Normal)
        userFlipsButton.setTitleColor(UIColor.flipOrange(), forState: .Normal)
        userFlipsButton.titleLabel!.font = UIFont.avenirNextDemiBold(15.0)
        userFlipsButton.addTarget(self, action: Selector("didTapUserFlipsButton"), forControlEvents: UIControlEvents.TouchUpInside)
        userFlipsButton.backgroundColor = UIColor.whiteColor()
        addSubview(userFlipsButton)
        
        stockFlipsButton = UIButton(type: .System)
        stockFlipsButton.layer.cornerRadius = 3.0
        stockFlipsButton.layer.borderWidth = 1.0
        stockFlipsButton.layer.borderColor = UIColor.flipOrange().CGColor
        stockFlipsButton.setTitle("Stock Flips", forState: .Normal)
        stockFlipsButton.setTitleColor(UIColor.flipOrange(), forState: .Normal)
        stockFlipsButton.titleLabel!.font = UIFont.avenirNextDemiBold(15.0)
        stockFlipsButton.addTarget(self, action: Selector("didTapStockFlipsButton"), forControlEvents: UIControlEvents.TouchUpInside)
        stockFlipsButton.backgroundColor = UIColor.whiteColor()
        addSubview(stockFlipsButton)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT)
        layout.scrollDirection = .Horizontal
        flipsCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        flipsCollectionView.backgroundColor = self.backgroundColor
        flipsCollectionView.delegate = self
        flipsCollectionView.dataSource = self
        flipsCollectionView.registerClass(FlipsViewCell.self, forCellWithReuseIdentifier: "FlipCell")
        flipsCollectionView.allowsSelection = true
        flipsCollectionView.alpha = 0
        addSubview(flipsCollectionView)
        
        emptyLabel = UILabel()
        emptyLabel.alpha = 0
        emptyLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h4)
        emptyLabel.text = "No Flips Available"
        emptyLabel.textAlignment = .Center
        emptyLabel.textColor = UIColor.darkGrayColor()
        addSubview(emptyLabel)
        
    }
    
    func initConstriants() {
        
        userFlipsButton.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.right.equalTo()(self.mas_centerX).with().offset()(-self.VIEW_SPACING)
            make.width.equalTo()(self.CELL_WIDTH)
            make.height.equalTo()(self.CELL_HEIGHT)
        }
        
        stockFlipsButton.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.left.equalTo()(self.mas_centerX).with().offset()(self.VIEW_SPACING)
            make.width.equalTo()(self.CELL_WIDTH)
            make.height.equalTo()(self.CELL_HEIGHT)
        }
        
        flipsCollectionView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.left.equalTo()(self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING)
            make.width.equalTo()(self.frame.width - self.VIEW_INSET - self.CELL_WIDTH - self.VIEW_SPACING - self.VIEW_INSET)
            make.height.equalTo()(self.CELL_HEIGHT)
        }
        
        emptyLabel.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self)
            make.left.equalTo()(self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING)
            make.width.equalTo()(self.frame.width - self.VIEW_INSET - self.CELL_WIDTH - self.VIEW_SPACING - self.VIEW_INSET)
        }
        
    }
    
    
    
    ////
    // MARK: - Lifecycle Overrides
    ////
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initConstriants()
    }
    
    
    
    ////
    // MARK: - Data Updates
    ////
    
    internal func reloadData() {
        flipsCollectionView.reloadData()
    }
    
    
    
    ////
    // MARK: - User Flips View State
    ////
    
    func isUserFlipsViewActive() -> (Bool) {
        return isShowingUserFlips
    }
    
    func showUserFlipsView() {
        
        isShowingUserFlips = true
        
        flipsCollectionView.reloadData()
        
        // Hide the stock flips button
        self.stockFlipsButton.alpha = 0
        
        self.userFlipsButton.alpha = 1
        self.userFlipsButton.frame.origin.x = self.VIEW_INSET
        
        let userFlipsCount = dataSource?.userFlipsCount() ?? 0
        let isUserFlipsViewEmpty = userFlipsCount == 0
        
        if isUserFlipsViewEmpty
        {
            self.emptyLabel.alpha = 1
            self.emptyLabel.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
        }
        else
        {
            self.flipsCollectionView.alpha = 1
            self.flipsCollectionView.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
        }
        
    }
    
    func showUserFlipsViewAnimated() {
        
        isShowingUserFlips = true
        
        flipsCollectionView.reloadData()
        
        let userFlipsCount = dataSource?.userFlipsCount() ?? 0
        let isUserFlipsViewEmpty = userFlipsCount == 0
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
                
            self.stockFlipsButton.alpha = 0
            
        }, completion: { (success) -> Void in
            
            self.emptyLabel.frame.origin.x = self.userFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
            self.flipsCollectionView.frame.origin.x = self.userFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.userFlipsButton.frame.origin.x = self.VIEW_INSET
                
                if isUserFlipsViewEmpty
                {
                    self.emptyLabel.alpha = 1
                    self.emptyLabel.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
                }
                else
                {
                    self.flipsCollectionView.alpha = 1
                    self.flipsCollectionView.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
                }
                
            })
        
        })
        
    }
    
    func dismissUserFlipsView() {
        
        isShowingUserFlips = false
        
        self.stockFlipsButton.alpha = 1
        
        self.userFlipsButton.frame.origin.x = self.center.x - self.CELL_WIDTH - self.VIEW_SPACING
            
        self.emptyLabel.alpha = 0
        self.emptyLabel.frame.origin.x = self.center.x + self.VIEW_SPACING
        
        self.flipsCollectionView.alpha = 0
        self.flipsCollectionView.frame.origin.x = self.center.x + self.VIEW_SPACING
        
    }
    
    func dismissUserFlipsViewAnimated() {
        
        isShowingUserFlips = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                
            self.userFlipsButton.frame.origin.x = self.center.x - self.CELL_WIDTH - self.VIEW_SPACING
            
            self.emptyLabel.alpha = 0
            self.emptyLabel.frame.origin.x = self.center.x + self.VIEW_SPACING
            
            self.flipsCollectionView.alpha = 0
            self.flipsCollectionView.frame.origin.x = self.center.x + self.VIEW_SPACING
            
        }, completion: { (success) -> Void in
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.stockFlipsButton.alpha = 1
                
            })
        
        })
        
    }
    
    
    
    ////
    // MARK: - User Flips View State
    ////
    
    func isStockFlipsViewActive() -> (Bool) {
        return isShowingStockFlips
    }
    
    func showStockFlipsView() {
        
        isShowingStockFlips = true
        
        flipsCollectionView.reloadData()
        
        let stockFlipsCount = dataSource?.stockFlipsCount() ?? 0
        let isStockFlipsViewEmpty = stockFlipsCount == 0
        
        self.userFlipsButton.alpha = 0
        
        self.stockFlipsButton.alpha = 1
        self.stockFlipsButton.frame.origin.x = self.VIEW_INSET
        
        self.emptyLabel.frame.origin.x = self.stockFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
        self.flipsCollectionView.frame.origin.x = self.stockFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
        
        if isStockFlipsViewEmpty
        {
            self.emptyLabel.alpha = 1
            self.emptyLabel.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
        }
        else
        {
            self.flipsCollectionView.alpha = 1
            self.flipsCollectionView.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
        }
        
    }
    
    func showStockFlipsViewAnimated() {
        
        isShowingStockFlips = true
        
        flipsCollectionView.reloadData()
        
        let stockFlipsCount = dataSource?.stockFlipsCount() ?? 0
        let isStockFlipsViewEmpty = stockFlipsCount == 0
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.userFlipsButton.alpha = 0
            
        }, completion: { (success) -> Void in
            
            self.emptyLabel.frame.origin.x = self.stockFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
            self.flipsCollectionView.frame.origin.x = self.stockFlipsButton.frame.origin.x + self.CELL_WIDTH + self.VIEW_SPACING
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                
                self.stockFlipsButton.frame.origin.x = self.VIEW_INSET
                
                if isStockFlipsViewEmpty
                {
                    self.emptyLabel.alpha = 1
                    self.emptyLabel.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
                }
                else
                {
                    self.flipsCollectionView.alpha = 1
                    self.flipsCollectionView.frame.origin.x = self.VIEW_INSET + self.CELL_WIDTH + self.VIEW_SPACING
                }
                
            })   
            
        })
        
    }
    
    func dismissStockFlipsView() {
        
        isShowingStockFlips = false
        
        self.userFlipsButton.alpha = 1
        
        self.stockFlipsButton.frame.origin.x = self.center.x + self.VIEW_SPACING
                
        self.emptyLabel.alpha = 0
        self.emptyLabel.frame.origin.x = self.center.x + self.VIEW_SPACING + self.CELL_WIDTH + self.VIEW_SPACING
        
        self.flipsCollectionView.alpha = 0
        self.flipsCollectionView.frame.origin.x = self.center.x + self.VIEW_SPACING + self.CELL_WIDTH + self.VIEW_SPACING
        
    }
    
    func dismissStockFlipsViewAnimated() {
        
        isShowingStockFlips = false
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
                
            self.stockFlipsButton.frame.origin.x = self.center.x + self.VIEW_SPACING
            
            self.emptyLabel.alpha = 0
            self.emptyLabel.frame.origin.x = self.center.x + self.VIEW_SPACING + self.CELL_WIDTH + self.VIEW_SPACING
            
            self.flipsCollectionView.alpha = 0
            self.flipsCollectionView.frame.origin.x = self.center.x + self.VIEW_SPACING + self.CELL_WIDTH + self.VIEW_SPACING
            
        }, completion: { (success) -> Void in
            
             UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.userFlipsButton.alpha = 1
                
            })   
            
        })
        
    }
    
    
    
    ////
    // MARK: - Button Callbacks
    ////
    
    func didTapUserFlipsButton() {
        
        if !isShowingUserFlips
        {
            showUserFlipsViewAnimated()
            delegate?.didOpenUserFlipsView()
        }
        else
        {
            dismissUserFlipsViewAnimated()
            delegate?.didDismissUserFlipsView()
        }
        
    }
    
    func didTapStockFlipsButton() {
        
        if !isShowingStockFlips
        {
            showStockFlipsViewAnimated()
            delegate?.didOpenStockFlipsView()
        }
        else
        {
            dismissStockFlipsViewAnimated()
            delegate?.didDismissStockFlipsView()
        }
        
    }
    
    
    
    ////
    // MARK: - UICollectionViewDataSource
    ////
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isShowingUserFlips
        {
            return dataSource?.userFlipsCount() ?? 0
        }
        else if isShowingStockFlips
        {
            return dataSource?.stockFlipsCount() ?? 0
        }
        else
        {
            return 0
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlipCell", forIndexPath: indexPath) as! FlipsViewCell
        
        if isShowingUserFlips
        {
            if let flipId = dataSource?.userFlipIdForIndex(indexPath.row) {
                let selectedId = dataSource?.selectedFlipId()
                cell.setFlipId(flipId)
                cell.setSelected(selectedId != nil && selectedId == flipId)
            }
        }
        else
        {
            if let flipId = dataSource?.stockFlipIdForIndex(indexPath.row) {
                let selectedId = dataSource?.selectedFlipId()
                cell.setFlipId(flipId)
                cell.setSelected(selectedId != nil && selectedId == flipId)
            }
        }
        
        return cell
        
    }
    
    
    ////
    // MARK: - UICollectionViewDelegate
    ////
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if isShowingUserFlips
        {
            delegate?.didSelectUserFlipAtIndex(indexPath.row)
        }
        else
        {
            delegate?.didSelectStockFlipAtIndex(indexPath.row)
        }
        
        for var i = 0; i < collectionView.numberOfItemsInSection(0); i++ {
            
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! FlipsViewCell
            
            if i == indexPath.row
            {
                cell.setSelected(cell.isSelected ?? true)
            }
            else
            {
                cell.setSelected(false)
            }
            
        }
        
    }
    
}

protocol FlipSelectionViewDelegate : class {
    
    func didOpenUserFlipsView()
    
    func didDismissUserFlipsView()
    
    func didSelectUserFlipAtIndex(index: Int)
    
    func didOpenStockFlipsView()
    
    func didDismissStockFlipsView()
    
    func didSelectStockFlipAtIndex(index: Int)
    
}

protocol FlipSelectionViewDataSource : class {
    
    func selectedFlipId() -> (String!)
    
    func userFlipsCount() -> (Int)
    
    func userFlipIdForIndex(index: Int) -> (String!)
    
    func stockFlipsCount() -> (Int)
    
    func stockFlipIdForIndex(index: Int) -> (String!)
    
}