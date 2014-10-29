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

class MyMugsView : UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

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
    
    var mugDataSource = MugDataSource()
    var myMugs: [Mug] = [Mug]()
    
    var delegate: MyMugsViewViewDelegate?
    
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
        myMugsLabel.text = NSLocalizedString("My Mugs", comment: "My Mugs")
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
        myMugsCollectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
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
        delegate?.myMugsViewDidTapAddMug(self)
    }
    
    func setWord(word: String) {
        self.myMugs = mugDataSource.getMyMugsForWord(word)
        myMugsCollectionView.reloadData()
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myMugs.count + 1 //addMugButton
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.addSubview(addMugButton)
        } else {
            var currentMug: Mug? = self.myMugs[indexPath.row - 1]
            if (currentMug != nil) {
                var cellImageView: UIImageView = UIImageView()
                cellImageView.setImageWithURL(NSURL(string: currentMug!.backgroundURL))
                cellImageView.frame.size = CGSizeMake(self.MY_MUGS_CELL_WIDTH, self.MY_MUGS_CELL_HEIGHT)
                cell.addSubview(cellImageView);
           }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        var cell : UICollectionViewCell! = collectionView.cellForItemAtIndexPath(indexPath)
        
        var seletedOverlayView: SelectedMugOverlayView = SelectedMugOverlayView(frame: CGRectMake(0, 0, self.MY_MUGS_CELL_WIDTH, self.MY_MUGS_CELL_WIDTH))
        
        cell.addSubview(seletedOverlayView)
        
        //TODO (story 7638): Selecting a mug from "My Mugs" or "Stock Mugs" should result in the selected mug being overlaid with a checkmark. (Check)
        //self.delegate?.myMugsViewDidSelectMug()
    }
    
    func collectionView(collectionView: UICollectionView!, didDeselectItemAtIndexPath indexPath: NSIndexPath!) {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        // TODO (story 7638): Tapping a selected mug will de-select it, and will return the upper portion of the screen to displaying the default (green) background.
        //self.delegate?.myMugsViewDidDeselectMug()
    }
    
}


// MARK: - View Delegate

protocol MyMugsViewViewDelegate {
    
    func myMugsViewDidTapAddMug(myMugsView: MyMugsView!)
    func myMugsViewDidSelectMug(myMugsView: MyMugsView!, selectedMug: Mug!)
    func myMugsViewDidDeselectMug(myMugsView: MyMugsView!, selectedMug: Mug!)
    
}
