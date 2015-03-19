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

class FlipsView : UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    private let MY_FLIPS_LABEL_MARGIN_TOP: CGFloat = 5.0
    private let MY_FLIPS_LABEL_MARGIN_LEFT: CGFloat = 10.0
    
    private let MY_FLIPS_CELL_MARGIN_TOP: CGFloat = 5.0
    private let MY_FLIPS_CELL_MARGIN_LEFT: CGFloat = 5.0
    private let MY_FLIPS_CELL_MARGIN_RIGHT: CGFloat = 5.0
    private let MY_FLIPS_CELL_MARGIN_BOTTOM: CGFloat = 5.0
    
    private let MY_FLIPS_CELL_WIDTH: CGFloat = 83.5
    private let MY_FLIPS_CELL_HEIGHT: CGFloat = 83.5
    
    private let MY_FLIPS_TITLE = NSLocalizedString("My Flips", comment: "My Flips")
    private let STOCK_FLIPS_TITLE = NSLocalizedString("Stock Flips", comment: "Stock Flips")
    
    private let FLIP_VIEW_CELL_REUSE_IDENTIFIER = "flipCell"
    private let FLIP_VIEW_HEADER_REUSE_IDENTIFIER = "flipHeader"
    
    private var addFlipButton: UIButton!
    private var myFlipsCollectionView: UICollectionView!
    
    var flipText : FlipText!
    
    weak var delegate: FlipsViewDelegate?
    weak var dataSource: FlipsViewDataSource?
    
    override init() {
        super.init(frame: CGRect.zeroRect)
        addSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addFlipButton = UIButton()
        addFlipButton.addTarget(self, action: "addFlipButtonTapped:", forControlEvents: .TouchUpInside)
        addFlipButton.setImage(UIImage(named: "AddMediaButton"), forState: .Normal)
        addFlipButton.sizeToFit()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: self.MY_FLIPS_CELL_MARGIN_TOP, left: self.MY_FLIPS_CELL_MARGIN_LEFT, bottom: self.MY_FLIPS_CELL_MARGIN_BOTTOM, right: self.MY_FLIPS_CELL_MARGIN_RIGHT)
        layout.itemSize = CGSize(width: self.MY_FLIPS_CELL_WIDTH, height: self.MY_FLIPS_CELL_HEIGHT)
        myFlipsCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        myFlipsCollectionView!.dataSource = self
        myFlipsCollectionView!.delegate = self
        myFlipsCollectionView.registerClass(FlipsViewCell.self, forCellWithReuseIdentifier:FLIP_VIEW_CELL_REUSE_IDENTIFIER);
        myFlipsCollectionView.registerClass(FlipsHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FLIP_VIEW_HEADER_REUSE_IDENTIFIER)
        myFlipsCollectionView!.backgroundColor = self.backgroundColor
        myFlipsCollectionView!.allowsSelection = true
        self.addSubview(myFlipsCollectionView!)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        myFlipsCollectionView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self).with().offset()(self.MY_FLIPS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self).with().offset()(self.MY_FLIPS_LABEL_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MY_FLIPS_LABEL_MARGIN_LEFT)
            make.bottom.equalTo()(self).with().offset()(-self.MY_FLIPS_LABEL_MARGIN_TOP)
        }
    }
    
    func addFlipButtonTapped(sender: UIButton!) {
        delegate?.flipsViewDidTapAddFlip(self)
    }
    
    
    // MARK: - Data Handler Methods
    
    func reload() {
        myFlipsCollectionView.reloadData()
    }
    
    private func getNumberOfFlips() -> (myFlips: Int, stockFlips: Int) {
        var numberOfMyFlips = self.dataSource?.flipsViewNumberOfFlips()
        if (numberOfMyFlips == nil) {
            numberOfMyFlips = 0
        }
        
        var numberOfStockFlips = self.dataSource?.flipsViewNumberOfStockFlips()
        if (numberOfStockFlips == nil) {
            numberOfStockFlips = 0
        }
        
        return (numberOfMyFlips!, numberOfStockFlips!)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let numberOfFlips = self.getNumberOfFlips()
        
        var numberOfSections = 0
        
        if (numberOfFlips.myFlips > 0) {
            numberOfSections++
        }
        
        if (numberOfFlips.stockFlips > 0) {
            numberOfSections++
        }
        
        if (numberOfSections == 0) {
            return 1
        }
        
        return numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfFlips = self.getNumberOfFlips()
        
        if (section == 1) {
            return numberOfFlips.stockFlips
        } else {
            if (numberOfFlips.myFlips > 0) {
                return numberOfFlips.myFlips + 1 //addFlipButton
            } else {
                return numberOfFlips.stockFlips + 1 //addFlipButton
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FLIP_VIEW_CELL_REUSE_IDENTIFIER, forIndexPath: indexPath) as FlipsViewCell
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.addSubview(addFlipButton)
        } else {
            for subview in cell.subviews {
                if (subview as NSObject == addFlipButton) {
                    addFlipButton.removeFromSuperview()
                }
            }
            
            let numberOfFlips = self.getNumberOfFlips()
            
            var flipId: String!
            if (indexPath.section == 1) {
                flipId = dataSource?.flipsView(self, stockFlipIdAtIndex: indexPath.row)
            } else {
                if (numberOfFlips.myFlips > 0) {
                    flipId = dataSource?.flipsView(self, flipIdAtIndex: indexPath.row - 1)
                } else {
                    flipId = dataSource?.flipsView(self, stockFlipIdAtIndex: indexPath.row - 1)
                }
            }
            
            let flipDataSource = FlipDataSource()
            if let flip = flipDataSource.retrieveFlipWithId(flipId!) {
                cell.setFlipId(flip.flipID)
                
                var isSelected = (flip.flipID == dataSource?.flipsViewSelectedFlipId())
                cell.setSelected(isSelected)
            } else {
                UIAlertView.showUnableToLoadFlip()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let reusableView: FlipsHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
            withReuseIdentifier: FLIP_VIEW_HEADER_REUSE_IDENTIFIER,
            forIndexPath: indexPath) as FlipsHeaderView
        
        if (kind == UICollectionElementKindSectionHeader) {
            let numberOfFlips = self.getNumberOfFlips()
            
            if (indexPath.section == 1) {
                reusableView.setTitle(STOCK_FLIPS_TITLE)
            } else {
                if (numberOfFlips.myFlips > 0 || numberOfFlips.stockFlips == 0) {
                    reusableView.setTitle(MY_FLIPS_TITLE)
                } else {
                    reusableView.setTitle(STOCK_FLIPS_TITLE)
                }
            }
        }
        
        return reusableView
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(self.frame.width, 30)
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let numberOfFlips = self.getNumberOfFlips()
        
        if (indexPath.section == 1) {
            self.delegate?.flipsView(self, didTapAtIndex: indexPath.row, fromStockFlips: true)
        } else {
            if (numberOfFlips.myFlips > 0) {
                self.delegate?.flipsView(self, didTapAtIndex: indexPath.row - 1, fromStockFlips: false)
            } else {
                self.delegate?.flipsView(self, didTapAtIndex: indexPath.row - 1, fromStockFlips: true)
            }
        }
    }
}


// MARK: - View Delegate

protocol FlipsViewDelegate: class {
    
    func flipsViewDidTapAddFlip(flipsView: FlipsView!)
    func flipsView(flipsView: FlipsView!, didTapAtIndex index: Int, fromStockFlips isStockFlip: Bool)
    
}

protocol FlipsViewDataSource: class {
    
    func flipsViewNumberOfFlips() -> Int
    func flipsView(flipsView: FlipsView, flipIdAtIndex index: Int) -> String
    func flipsView(flipsView: FlipsView, stockFlipIdAtIndex index: Int) -> String
    func flipsViewSelectedFlipId() -> String?
    func flipsViewNumberOfStockFlips() -> Int
    
}
