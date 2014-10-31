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
    
    var mugText : MugText!
    
    var mugDataSource = MugDataSource()
    var myMugs: [Mug] = [Mug]()
    
    var delegate: MyMugsViewDelegate?
    
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
        myMugsCollectionView.registerClass(MyMugsViewCell.self, forCellWithReuseIdentifier:"Cell");
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
    
    func setMugText(mugText: MugText) {
        self.mugText = mugText
        self.myMugs = mugDataSource.getMyMugsForWord(mugText.text)
        if (self.myMugs.count > 0) {
            self.delegate?.myMugsViewMugsForSelectedWord(self, hasMugs: true)
            myMugsCollectionView.reloadData()
        } else {
            self.delegate?.myMugsViewMugsForSelectedWord(self, hasMugs: false)
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.myMugs.count + 1 //addMugButton
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as MyMugsViewCell
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell.addSubview(addMugButton)
        } else {
            var currentMug: Mug? = self.myMugs[indexPath.row - 1]
            if (currentMug != nil) {
                cell.mug = currentMug
                cell.deselectCell()
                if (currentMug!.mugID == self.mugText.associatedMug?.mugID) {
                    cell.toggleCellState()
                }
                
                cell.cellImageView.setImageWithURL(NSURL(string: currentMug!.backgroundURL))
           }
        }
        
        return cell
    }
    
    //this delegate is called too when the user is tapping the cell to deselects it (not only for selection)
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        var selectedCell: MyMugsViewCell! = collectionView.cellForItemAtIndexPath(indexPath) as MyMugsViewCell
        
        //didDeselectItemAtIndexPath doesn't work for all situations
        for cell in self.myMugsCollectionView.visibleCells() as [MyMugsViewCell] {
            if (cell.mug?.mugID != selectedCell.mug.mugID) {
               cell.deselectCell()
            }
        }
        
        selectedCell.toggleCellState()
        self.delegate?.myMugsViewDidChangeMugSelection(self, mug: selectedCell.mug)
    }
    
}


// MARK: - View Delegate

protocol MyMugsViewDelegate {
    
    func myMugsViewDidTapAddMug(myMugsView: MyMugsView!)
    func myMugsViewDidChangeMugSelection(myMugsView: MyMugsView!, mug: Mug!)
    func myMugsViewMugsForSelectedWord(myMugsView: MyMugsView!, hasMugs: Bool!)
    
}
