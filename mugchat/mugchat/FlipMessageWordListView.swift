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

class FlipMessageWordListView : UIView, UIScrollViewDelegate {
    
    private let MIN_BUTTON_WIDTH : CGFloat = 70.0
    private let MUG_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
    private let MUG_TEXT_HEIGHT : CGFloat = 36.0
    private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0
    
    private let PLUS_BUTTON_WIDTH: CGFloat = 50.0
    
    private var arrowToCenteredWordImageView: UIImageView!
    private var scrollView: UIScrollView!
    
    private var mugTextViews: [MugTextView]!
    private var tappedMugTextView: MugTextView?
    
    private var addWordButton: UIButton!
    
    var delegate: FlipMessageWordListViewDelegate?
    
    var dataSource: FlipMessageWordListViewDataSource?
    
    
    // MARK: - Initializers
    
    override init() {
        super.init(frame: CGRect.zeroRect)
        self.mugTextViews = Array<MugTextView>()
        
        self.addSubviews()
        self.addConstraints()
        
        self.becomeFirstResponder()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        arrowToCenteredWordImageView = UIImageView()
        arrowToCenteredWordImageView.image = UIImage(named: "Triangle")
        arrowToCenteredWordImageView.sizeToFit()
        self.addSubview(arrowToCenteredWordImageView)
        
        addWordButton = UIButton()
        addWordButton.setImage(UIImage(named: "AddWord"), forState: UIControlState.Normal)
        addWordButton.addTarget(self, action: "addWordButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addWordButton.hidden = true
        self.addSubview(addWordButton)
    }
    
    private func addConstraints() {
        scrollView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
        
        arrowToCenteredWordImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.mas_bottom) // to show only half triangle
            make.centerX.equalTo()(self)
        }
        
        addWordButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.bottom.equalTo()(self)
            make.width.equalTo()(self.PLUS_BUTTON_WIDTH)
        }
    }
    
    func addGestureRecognizers(mugTextView: MugTextView) {
        mugTextView.userInteractionEnabled = true
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "flipWordTapped:")
        mugTextView.addGestureRecognizer(tapGesture)
        
        var holdGesture = UILongPressGestureRecognizer(target: self, action: "flipWordLongPressed:")
        mugTextView.addGestureRecognizer(holdGesture)
    }
    
    private func layoutWords() {
        var contentOffset: CGFloat = 0.0
        var index = 0
        
        for mugTextView in mugTextViews {
            mugTextView.updateLayout()
            
            var requiredWidth = self.getTextWidth(mugTextView.textLabel.text!) + MUG_TEXT_ADDITIONAL_WIDTH
            var mugTextViewWidth = requiredWidth > MIN_BUTTON_WIDTH ? requiredWidth : MIN_BUTTON_WIDTH
            
            var leftMargin: CGFloat = 0
            var rightMargin: CGFloat = 0
            if (index == 0) {
                // Add left margin
                leftMargin = (CGRectGetWidth(self.frame) / 2) - (mugTextViewWidth / 2)
            } else if (index == (mugTextViews.count - 1)) {
                // Add right margin
                rightMargin = (CGRectGetWidth(self.frame) / 2) - (mugTextViewWidth / 2)
            }
            
            contentOffset += leftMargin
            
            var textViewY = (CGRectGetHeight(self.frame) / 2) - (MUG_TEXT_HEIGHT / 2) - (LABEL_MARGIN_TOP / 2)
            mugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, MUG_TEXT_HEIGHT)
            
            if (rightMargin == 0) {
                // The last item already has his rightMargin
                rightMargin = SPACE_BETWEEN_MUG_TEXTS
            }
            contentOffset += mugTextView.frame.size.width + rightMargin
            scrollView.contentSize = CGSizeMake(contentOffset, mugTextView.frame.size.height)
            
            index++
        }
    }
    
    func reloadWords(animated: Bool = true) {
        for flipText in mugTextViews {
            flipText.removeFromSuperview()
        }
        mugTextViews.removeAll(keepCapacity: false)
        
        for (var i = 0; i < dataSource?.numberOfFlipWords(); i++) {
            let mugText = dataSource?.flipMessageWordListView(self, flipWordAtIndex: i)
            var mugTextView = MugTextView(mugText: mugText!)
            mugTextView.sizeToFit()
            addGestureRecognizers(mugTextView)
            scrollView.addSubview(mugTextView)
            mugTextViews.append(mugTextView)
        }
        
        self.layoutWords()
        
        let centeredWordIndex = dataSource?.flipMessageWordListViewHighlightedWordIndex(self)
        self.centerScrollViewAtView(mugTextViews[centeredWordIndex!], animated: animated)
    }
    
    func showPlusButton() {
        addWordButton.hidden = false
    }
    
    // MARK: - Word Gesture Handlers
    
    func flipWordTapped(gesture: UIGestureRecognizer) {
        let menuController = UIMenuController.sharedMenuController()
        menuController.setMenuVisible(false, animated: true)
        
        self.centerScrollViewAtView(gesture.view!)
        
        let flipText = (gesture.view! as MugTextView).mugText
        delegate?.flipMessageWordListView(self, didSelectFlipWord: flipText)
    }
    
    func flipWordLongPressed(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began) {
            let mugTextView = gesture.view! as MugTextView
            var arrayOfWords : [String] = MugStringsUtil.splitMugString(mugTextView.mugText.text)
            if (arrayOfWords.count > 1) {
                gesture.view?.alpha = 0.5
                self.showSplitMenuAtView(gesture.view! as MugTextView)
            }
        } else if (gesture.state == UIGestureRecognizerState.Ended) {
            gesture.view?.alpha = 1
        }
    }
    
    
    // MARK: - Items Handler
    
    func addWordButtonTapped() {
        delegate?.flipMessageWordListViewDidTapAddWordButton(self)
    }
    
    func replaceFlipWord(flipWord: MugText, forFlipWords flipWords: [MugText]) {
        var startPositionToStartUpdate = flipWord.position
        
        var initialFrame : CGRect!
        for (var i = 0; i < mugTextViews.count; i++) {
            var textView = mugTextViews[i]
            if (textView.mugText.position == flipWord.position) {
                textView.removeFromSuperview()
                mugTextViews.removeAtIndex(i)
                initialFrame = textView.frame
                break
            }
        }

        for newFlipWord in flipWords {
            var flipTextView = MugTextView(mugText: newFlipWord)
            flipTextView.sizeToFit()
            
            var requiredWidth = self.getTextWidth(flipTextView.textLabel.text!) + self.MUG_TEXT_ADDITIONAL_WIDTH
            var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
            initialFrame.size.width = mugTextViewWidth
            flipTextView.frame = initialFrame
            
            addGestureRecognizers(flipTextView)
            scrollView.addSubview(flipTextView)
            mugTextViews.insert(flipTextView, atIndex: newFlipWord.position)
        }
        
        // Update MugTexts
        for (var i = 0; i < mugTextViews.count; i++) {
            var flipWord = dataSource?.flipMessageWordListView(self, flipWordAtIndex: i)
            var textView = mugTextViews[i]
            textView.mugText = flipWord
        }
    
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var contentOffset: CGFloat = 0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var totalOffsetX: CGFloat = 0
                var itemX: CGFloat = initialFrame.origin.x
                for flipTextView in self.mugTextViews {
                    if (flipTextView.mugText.position >= startPositionToStartUpdate) {
                        var x = itemX + totalOffsetX
                        var requiredWidth = self.getTextWidth(flipTextView.textLabel.text!) + self.MUG_TEXT_ADDITIONAL_WIDTH
                        var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
                        
                        flipTextView.frame = CGRectMake(x,
                            CGRectGetMinY(flipTextView.frame),
                            mugTextViewWidth,
                            CGRectGetHeight(flipTextView.frame))
                        
                        totalOffsetX = totalOffsetX + mugTextViewWidth + self.SPACE_BETWEEN_MUG_TEXTS
                    }
                    contentOffset = CGRectGetMidX(flipTextView.frame) + (CGRectGetWidth(self.frame) / 2)
                }

            }, completion: { (finished) -> Void in
                self.centerScrollViewAtClosestItem()
            })
        })
    }
    
    
    // MARK: - Scroll Position Setters
    
    func centerAtFlipWord(flipWord: MugText?) {
        for textView in mugTextViews {
            if (textView.mugText.position == flipWord?.position) {
                self.centerScrollViewAtView(textView)
            }
        }
    }
    
    
    // MARK: - Contextual Menu Handlers
    
    private func showSplitMenuAtView(mugTextView : MugTextView!) {
        let menuController = UIMenuController.sharedMenuController()
        
        self.tappedMugTextView = mugTextView;
        
        var scrollViewCurrentMinX: CGFloat = self.scrollView.bounds.minX
        var selectionRect : CGRect = CGRectMake(mugTextView.frame.origin.x - scrollViewCurrentMinX, mugTextView.frame.origin.y + 10, mugTextView.frame.size.width, mugTextView.frame.size.height);
        menuController.setTargetRect(selectionRect, inView: self)
        
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Split", comment: "Split"), action: NSSelectorFromString("splitText"))
        menuController.menuItems = NSArray(array: [lookupMenu])
        
        menuController.update();
        
        menuController.setMenuVisible(true, animated: true)
    }
    
    func splitText() {
        delegate?.flipMessageWordListView(self, didSplitFlipWord: self.tappedMugTextView?.mugText)
    }
    

    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let menuController = UIMenuController.sharedMenuController()
        menuController.setMenuVisible(false, animated: true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.centerScrollViewAtClosestItem()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.centerScrollViewAtClosestItem()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.scrollEnabled = true
    }
    
    
    // MARK: - ScrollView Helper Methods
    
    private func centerScrollViewAtClosestItem() {
        scrollView.scrollEnabled = false
        
        var mugTextViewToBeCentered = mugTextViews[0]
        
        var scrollX = scrollView.contentOffset.x + CGRectGetMidX(scrollView.frame)
        
        for mugTextView in mugTextViews {
            var currentCenteredMugTextViewMidX = CGRectGetMidX(mugTextViewToBeCentered.frame)
            var nextMugTextViewMidX = CGRectGetMidX(mugTextView.frame)

            var currentCenteredMugTextViewDistanceFromCenter = scrollX - currentCenteredMugTextViewMidX
            var nextMugTextViewDistanceFromCenter = scrollX - nextMugTextViewMidX
            
            if (abs(currentCenteredMugTextViewDistanceFromCenter) > abs(nextMugTextViewDistanceFromCenter)) {
                mugTextViewToBeCentered = mugTextView
            }
        }
        
        var mugTextViewToBeCenteredMidX: CGFloat = CGRectGetMidX(mugTextViewToBeCentered.frame)
        var scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        var contentOffsetX = mugTextViewToBeCenteredMidX - scrollViewCenterX
        
        if (scrollView.contentOffset.x != contentOffsetX) {
            scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: true)
        } else {
            scrollView.scrollEnabled = true
        }
        
        self.delegate?.flipMessageWordListView(self, didSelectFlipWord: mugTextViewToBeCentered.mugText)
    }
    
    private func centerScrollViewAtView(view: UIView, animated: Bool = true) {
        scrollView.scrollEnabled = false
        
        var mugTextViewToBeCenteredMidX: CGFloat = CGRectGetMidX(view.frame)
        var scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        var contentOffsetX = mugTextViewToBeCenteredMidX - scrollViewCenterX
        
        if (scrollView.contentOffset.x != contentOffsetX) {
            scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: animated)
        } else {
            scrollView.scrollEnabled = true
        }
    }
    
    
    // MARK: - Font Helper Methods
    
    private func getTextWidth(text: String) -> CGFloat {
        let mugTextString: NSString = text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = mugTextString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
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


// MARK: - Protocols

protocol FlipMessageWordListViewDelegate {
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSelectFlipWord flipWord: MugText!)

    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSplitFlipWord flipWordToSplit: MugText!)
    
    func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView)
}

protocol FlipMessageWordListViewDataSource {
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> MugText

    func numberOfFlipWords() -> Int
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int
    
}