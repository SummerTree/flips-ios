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

class MyFlipsView : UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private let MY_FLIPS_LABEL_MARGIN_TOP: CGFloat = 5.0
    private let MY_FLIPS_LABEL_MARGIN_LEFT: CGFloat = 10.0
    
    private let MY_FLIPS_CELL_MARGIN_TOP: CGFloat = 10.0
    private let MY_FLIPS_CELL_MARGIN_LEFT: CGFloat = 5.0
    private let MY_FLIPS_CELL_MARGIN_RIGHT: CGFloat = 5.0
    private let MY_FLIPS_CELL_MARGIN_BOTTOM: CGFloat = 10.0
    
    private let MY_FLIPS_CELL_WIDTH: CGFloat = 83.5
    private let MY_FLIPS_CELL_HEIGHT: CGFloat = 83.5
    
    private var myFlipsLabel: UILabel!
    private var addFlipButton: UIButton!
    private var myFlipsCollectionView: UICollectionView!
    
    var flipText : FlipText!
    
    var delegate: MyFlipsViewDelegate?
    var dataSource: MyFlipsViewDataSource?
    
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
        myFlipsLabel = UILabel()
        myFlipsLabel.numberOfLines = 1
        myFlipsLabel.sizeToFit()
        myFlipsLabel.text = NSLocalizedString("My Flips", comment: "My Flips")
        myFlipsLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h3)
        myFlipsLabel.textColor = UIColor.plum()
        self.addSubview(myFlipsLabel)
        
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
        myFlipsCollectionView.registerClass(MyFlipsViewCell.self, forCellWithReuseIdentifier:"Cell");
        myFlipsCollectionView!.backgroundColor = self.backgroundColor
        myFlipsCollectionView!.allowsSelection = true
        self.addSubview(myFlipsCollectionView!)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        myFlipsLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self).with().offset()(self.MY_FLIPS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self).with().offset()(self.MY_FLIPS_LABEL_MARGIN_LEFT)
        }

        myFlipsCollectionView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.myFlipsLabel.mas_bottom).with().offset()(self.MY_FLIPS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self).with().offset()(self.MY_FLIPS_LABEL_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MY_FLIPS_LABEL_MARGIN_LEFT)
            make.bottom.equalTo()(self).with().offset()(-self.MY_FLIPS_LABEL_MARGIN_TOP)
        }
    }
    
    func addFlipButtonTapped(sender: UIButton!) {
        delegate?.myFlipsViewDidTapAddFlip(self)
    }
    
    
    // MARK: - Data Handler Methods
    
    func reload() {
        myFlipsCollectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfFlips = self.dataSource?.myFlipsViewNumberOfFlips()
        if (numberOfFlips == nil) {
            numberOfFlips = 0
        }
        return numberOfFlips! + 1 //addFlipButton
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as MyFlipsViewCell
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.addSubview(addFlipButton)
        } else {
            var flipId = dataSource?.myFlipsView(self, flipIdAtIndex: indexPath.row - 1)
            
            let flipDataSource = FlipDataSource()
            var flip = flipDataSource.retrieveFlipWithId(flipId!)
            
            cell.setFlip(flip)
            
            var isSelected = (flip.flipID == dataSource?.myFlipsViewSelectedFlipId())
            cell.setSelected(isSelected)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        self.delegate?.myFlipsView(self, didTapAtIndex: indexPath.row - 1)
    }
}


// MARK: - View Delegate

protocol MyFlipsViewDelegate {
    
    func myFlipsViewDidTapAddFlip(myFlipsView: MyFlipsView!)
    func myFlipsView(myFlipsView: MyFlipsView!, didTapAtIndex index: Int)
    
}

protocol MyFlipsViewDataSource {
    
    func myFlipsViewNumberOfFlips() -> Int
    func myFlipsView(myFlipsView: MyFlipsView, flipIdAtIndex index: Int) -> String
    func myFlipsViewSelectedFlipId() -> String?
    
}
