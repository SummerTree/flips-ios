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

private let MIN_BUTTON_WIDTH : CGFloat = 70.0
private let MUG_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
private let MUG_TEXT_HEIGHT : CGFloat = 40.0
private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0

class MugTextsContainer : UICollectionView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MugTextViewDelegate {
    
    var mugTextViews: [MugTextView]! = [MugTextView]()
    
    private var mugTexts : [MugText]!
    private var tappedMugTextView: MugTextView?
    
    
    // MARK: - Initialization Methods
    
    convenience init(texts : [MugText]) {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0.0, left: SPACE_BETWEEN_MUG_TEXTS, bottom: 0.0, right: SPACE_BETWEEN_MUG_TEXTS)
        layout.headerReferenceSize = CGSizeMake(0, 0)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        self.init(frame: CGRect.zeroRect, collectionViewLayout: layout)
        
        self.mugTexts = texts
        
        //self.pagingEnabled = true
        self.dataSource = self
        self.delegate = self
        self.registerClass(MugTextView.self, forCellWithReuseIdentifier: "Cell")

        self.backgroundColor = UIColor.whiteColor()
        
        self.becomeFirstResponder()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, referenceSizeForHeaderInSection section: Int) -> CGSize  {
//        let size: CGSize = CGSizeMake(0, 0)
//        return size
//    }
    
    
    // NOTE: This delegate method requires you to disable UICollectionView's `pagingEnabled` property.
//    func scrollViewWillEndDragging(scrollView: UIScrollView!, withVelocity velocity: CGPoint, targetContentOffset: UnsafePointer<CGPoint>) {
//        //targetContentOffset.memory = CGPointMake( CGFloat( 156.0 ) , CGFloat( 0.0 ) )
//        //scrollView.setContentOffset( CGPointMake( CGFloat( 156.0 ) , CGFloat( 0.0 ) ), animated: false )
//    
//        var targetContentOffset2 : CGPoint = targetContentOffset.memory
//        
//        var point : CGPoint = targetContentOffset.memory;
//    
//        var layout : UICollectionViewFlowLayout = self.collectionViewLayout as UICollectionViewFlowLayout;
//    
//        // This assumes that the values of `layout.sectionInset.left` and
//        // `layout.sectionInset.right` are the same with `layout.minimumInteritemSpacing`.
//        // Remember that we're trying to snap to one item at a time. So one
//        // visible item comprises of its width plus the left margin.
//        var visibleWidth : CGFloat = layout.minimumInteritemSpacing + layout.itemSize.width;
//    
//        // It's either we go forwards or backwards.
//        var indexOfItemToSnap : Int = Int(point.x / visibleWidth) //round(point.x / visibleWidth);
//    
//        // The only exemption is the last item.
//        if (indexOfItemToSnap + 1 == self.numberOfItemsInSection(0) ) { // last item
//            targetContentOffset2 = CGPointMake(self.contentSize.width - self.bounds.size.width, 0);
//        } else {
//            targetContentOffset2 = CGPointMake(CGFloat(indexOfItemToSnap) * visibleWidth, 0);
//        }
//    }
    
    
    //Mark: UICollectionViewDataSource protocol
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView?) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mugTexts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mugTextViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as MugTextView
        mugTextViewCell.delegate = self
        self.mugTextViews.append(mugTextViewCell)
        
        mugTextViewCell.setMugText(mugTexts[indexPath.item])

        return mugTextViewCell
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        //println(self.mugTexts[indexPath.row].sizeWithAttributes(nil))

        var mugText: MugText = self.mugTexts[indexPath.row]
        
        var requiredWidth = self.getTextWidth(mugText) + MUG_TEXT_ADDITIONAL_WIDTH
        var buttonWidth = requiredWidth > MIN_BUTTON_WIDTH ? requiredWidth : MIN_BUTTON_WIDTH
        
        return CGSizeMake(buttonWidth, MUG_TEXT_HEIGHT);
    }
    
    func getTextWidth(mugText: MugText) -> CGFloat{
        let myString: NSString = mugText.text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }
    
    func didTapMugText(mugText : MugText!) {
        let menuController = UIMenuController.sharedMenuController()
        
        var mugTextView : MugTextView
        for mugTextView in mugTextViews {
            if (mugTextView.mugText.mugId == mugText.mugId) {
                self.tappedMugTextView = mugTextView;
                var selectionRect : CGRect = CGRectMake(mugTextView.frame.origin.x, mugTextView.frame.origin.y + 10, mugTextView.frame.size.width, mugTextView.frame.size.height);
                menuController.setTargetRect(selectionRect, inView: self)
                break;
            }
        }
    
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Split", comment: "Split"), action: NSSelectorFromString("splitText"))
        menuController.menuItems = NSArray(array: [lookupMenu])
    
        menuController.update();
    
        menuController.setMenuVisible(true, animated: true)
    }
    
    //TODO: under construction
    func splitText() {
        let text = self.tappedMugTextView?.mugText.text

        println(">>>>> splitText: \(text!)")
       
        var texts : [String] = MugStringsUtil.splitMugString(text!);
        
        var lastMugText: MugTextView!
        var mugTextView: MugTextView
        var foundMug: Bool = false
        for mugTextView in self.mugTextViews {
            if (mugTextView.mugText.text == text) {
                foundMug = true
                
                //Update the original MugText with the first string and a smaller size
                mugTextView.mugText.text = texts[0]
                
                var textWidth : CGFloat = mugTextView.getTextWidth()
                var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                mugTextView.mas_updateConstraints { (make) -> Void in
                    make.height.equalTo()(MUG_TEXT_HEIGHT)
                    make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                    make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                }
                
                lastMugText = mugTextView
                
                var newMugTextView : MugTextView
                for var i=1; i < texts.count; i++ {
                    newMugTextView = MugTextView(mugText: MugText(mugId: 1000, text: texts[i], state: MugState.Default))
                    mugTextViews.append(newMugTextView) //TODO: fazer append no índice certo, não no final
                    
                    newMugTextView.delegate = self
                    self.addSubview(newMugTextView)
                    
                    var textWidth : CGFloat = newMugTextView.getTextWidth()
                    var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                    
                    newMugTextView.mas_makeConstraints { (make) -> Void in
                        make.height.equalTo()(MUG_TEXT_HEIGHT)
                        make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                        make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                    }
                    
                    lastMugText = newMugTextView
                }

                //break;
            } else {
                if (foundMug) { //só considera elementos após o match
                    //TODO: reposicionar mugTextView depois do elemento alterado a partir do lastMugText.mas_right
                    var textWidth : CGFloat = mugTextView.getTextWidth()
                    var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                    mugTextView.mas_updateConstraints { (make) -> Void in
                        make.height.equalTo()(MUG_TEXT_HEIGHT)
                        make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                        make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                    }
                }
            }
        }
        
        self.updateConstraints();
 
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "cut:" {
            return false;
        }
            
        else if action == "copy:" {
            return false;
        }
            
        else if action == "paste:" {
            return false;
        }
            
        else if action == "_define:" {
            return false;
        }
            
        else if action == "splitText" {
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
}