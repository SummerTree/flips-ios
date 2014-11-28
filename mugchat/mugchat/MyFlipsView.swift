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

    private let MY_MUGS_LABEL_MARGIN_TOP: CGFloat = 5.0
    private let MY_MUGS_LABEL_MARGIN_LEFT: CGFloat = 10.0
    
    private let MY_MUGS_CELL_MARGIN_TOP: CGFloat = 10.0
    private let MY_MUGS_CELL_MARGIN_LEFT: CGFloat = 5.0
    private let MY_MUGS_CELL_MARGIN_RIGHT: CGFloat = 5.0
    private let MY_MUGS_CELL_MARGIN_BOTTOM: CGFloat = 10.0
    
    private let MY_MUGS_CELL_WIDTH: CGFloat = 83.5
    private let MY_MUGS_CELL_HEIGHT: CGFloat = 83.5
    
    private var myMugsLabel: UILabel!
    private var addMugButton: UIButton!
    private var myMugsCollectionView: UICollectionView!
    
    var mugText : MugText!
    
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
        myMugsLabel = UILabel()
        myMugsLabel.numberOfLines = 1
        myMugsLabel.sizeToFit()
        myMugsLabel.text = NSLocalizedString("My Flips", comment: "My Flips")
        myMugsLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h3)
        myMugsLabel.textColor = UIColor.plum()
        self.addSubview(myMugsLabel)
        
        addMugButton = UIButton()
        addMugButton.addTarget(self, action: "addMugButtonTapped:", forControlEvents: .TouchUpInside)
        addMugButton.setImage(UIImage(named: "AddMediaButton"), forState: .Normal)
        addMugButton.sizeToFit()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: self.MY_MUGS_CELL_MARGIN_TOP, left: self.MY_MUGS_CELL_MARGIN_LEFT, bottom: self.MY_MUGS_CELL_MARGIN_BOTTOM, right: self.MY_MUGS_CELL_MARGIN_RIGHT)
        layout.itemSize = CGSize(width: self.MY_MUGS_CELL_WIDTH, height: self.MY_MUGS_CELL_HEIGHT)
        myMugsCollectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        myMugsCollectionView!.dataSource = self
        myMugsCollectionView!.delegate = self
        myMugsCollectionView.registerClass(MyFlipsViewCell.self, forCellWithReuseIdentifier:"Cell");
        myMugsCollectionView!.backgroundColor = self.backgroundColor
        myMugsCollectionView!.allowsSelection = true
        self.addSubview(myMugsCollectionView!)
        
        makeConstraints()
    }
    
    private func makeConstraints() {
        myMugsLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self).with().offset()(self.MY_MUGS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self).with().offset()(self.MY_MUGS_LABEL_MARGIN_LEFT)
        }

        myMugsCollectionView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.myMugsLabel.mas_bottom).with().offset()(self.MY_MUGS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self).with().offset()(self.MY_MUGS_LABEL_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.MY_MUGS_LABEL_MARGIN_LEFT)
            make.bottom.equalTo()(self).with().offset()(-self.MY_MUGS_LABEL_MARGIN_TOP)
        }
    }
    
    func addMugButtonTapped(sender: UIButton!) {
        delegate?.myFlipsViewDidTapAddFlip(self)
    }
    
    
    // MARK: - Data Handler Methods
    
    func reload() {
        myMugsCollectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfFlips = self.dataSource?.myFlipsViewNumberOfFlips()
        if (numberOfFlips == nil) {
            numberOfFlips = 0
        }
        return numberOfFlips! + 1 //addMugButton
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as MyFlipsViewCell
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.addSubview(addMugButton)
        } else {
            var flipId = dataSource?.myFlipsView(self, flipIdAtIndex: indexPath.row - 1)
            
            let flipDataSource = MugDataSource()
            var flip = flipDataSource.retrieveMugWithId(flipId!)
            
            cell.setMug(flip)
            
            var isSelected = (flip.mugID == dataSource?.myFlipsViewSelectedFlipId())
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
