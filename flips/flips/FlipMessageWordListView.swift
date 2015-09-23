//
// Copyright 2015 ArcTouch, Inc.
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
    private let FLIP_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
    private let FLIP_TEXT_HEIGHT : CGFloat = 36.0
    private let SPACE_BETWEEN_FLIP_TEXTS : CGFloat = 12.0
    
    private let PLUS_BUTTON_WIDTH: CGFloat = 50.0
    
    private var arrowToCenteredWordImageView: UIImageView!
    private var scrollView: UIScrollView!
    
    private var flipTextViews: [FlipTextView]!
    private var tappedFlipTextView: FlipTextView?
    
    private var addWordButton: UIButton!
    
    private var enabled: Bool = true
    
    weak var delegate: FlipMessageWordListViewDelegate?
    
    weak var dataSource: FlipMessageWordListViewDataSource?
    
    
    // MARK: - Initializers
    
    init() {
        super.init(frame: CGRectZero)
        self.flipTextViews = Array<FlipTextView>()
        
        clipsToBounds = true
        
        self.addSubviews()
        self.addConstraints()
        
        self.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let source = dataSource {
            reloadWords(false)
        }
    }
    
    func addGestureRecognizers(flipTextView: FlipTextView) {
        flipTextView.userInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "flipWordTapped:")
        flipTextView.addGestureRecognizer(tapGesture)
        
        let holdGesture = UILongPressGestureRecognizer(target: self, action: "flipWordLongPressed:")
        flipTextView.addGestureRecognizer(holdGesture)
    }
    
    private func layoutWords() {
        var contentOffset: CGFloat = 0.0
        var index = 0
        
        for flipTextView in flipTextViews {
            flipTextView.updateLayout()
            
            let requiredWidth = self.getTextWidth(flipTextView.textLabel.text!) + FLIP_TEXT_ADDITIONAL_WIDTH
            let flipTextViewWidth = requiredWidth > MIN_BUTTON_WIDTH ? requiredWidth : MIN_BUTTON_WIDTH
            
            var leftMargin: CGFloat = 0
            var rightMargin: CGFloat = 0
            if (index == 0) {
                // Add left margin
                leftMargin = (CGRectGetWidth(self.frame) / 2) - (flipTextViewWidth / 2)
            } else if (index == (flipTextViews.count - 1)) {
                // Add right margin
                rightMargin = (CGRectGetWidth(self.frame) / 2) - (flipTextViewWidth / 2)
            }
            
            contentOffset += leftMargin
            
            let textViewY = (CGRectGetHeight(self.frame) / 2) - (FLIP_TEXT_HEIGHT / 2) - (LABEL_MARGIN_TOP / 2)
            flipTextView.frame = CGRectMake(contentOffset, textViewY, flipTextViewWidth, FLIP_TEXT_HEIGHT)
            
            if (rightMargin == 0) {
                // The last item already has his rightMargin
                rightMargin = SPACE_BETWEEN_FLIP_TEXTS
            }
            contentOffset += flipTextView.frame.size.width + rightMargin
            scrollView.contentSize = CGSizeMake(contentOffset, flipTextView.frame.size.height)
            
            index++
        }
    }
    
    func reloadWords(animated: Bool = true) {
        for flipText in flipTextViews {
            flipText.removeFromSuperview()
        }
        flipTextViews.removeAll(keepCapacity: false)
        
        for (var i = 0; i < dataSource?.numberOfFlipWords(); i++) {
            let flipText = dataSource?.flipMessageWordListView(self, flipWordAtIndex: i)
            let flipTextView = FlipTextView(flipText: flipText!)
            flipTextView.sizeToFit()
            addGestureRecognizers(flipTextView)
            scrollView.addSubview(flipTextView)
            flipTextViews.append(flipTextView)
        }
        
        self.layoutWords()

        if (self.flipTextViews.count > 0) {
            let centeredWordIndex = dataSource?.flipMessageWordListViewHighlightedWordIndex(self)
            self.centerScrollViewAtView(flipTextViews[centeredWordIndex!], animated: animated)
        }
    }
    
    func updateWordState() {
        if (flipTextViews.count > 0) {
            for flipText in flipTextViews {
                flipText.updateLayout()
            }
            
            let centeredWordIndex = dataSource?.flipMessageWordListViewHighlightedWordIndex(self)
            self.centerScrollViewAtView(flipTextViews[centeredWordIndex!], animated: true)
        }
    }
    
    func showPlusButton() {
        addWordButton.hidden = false
    }

    func setEnabled(enabled: Bool) {
        self.enabled = enabled
        self.scrollView.scrollEnabled = enabled
    }
    
    // MARK: - Word Gesture Handlers
    
    func flipWordTapped(gesture: UIGestureRecognizer) {
        if (!self.enabled) {
            return
        }
        
        let menuController = UIMenuController.sharedMenuController()
        menuController.setMenuVisible(false, animated: true)
        
        self.centerScrollViewAtView(gesture.view!)
        
        let flipText = (gesture.view as! FlipTextView).flipText
        delegate?.flipMessageWordListView(self, didSelectFlipWord: flipText)
    }
    
    func flipWordLongPressed(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began) {
            let flipTextView = gesture.view as! FlipTextView
            let arrayOfWords : [String] = FlipStringsUtil.splitFlipString(flipTextView.flipText.text)
            if (arrayOfWords.count > 1) {
                gesture.view?.alpha = 0.5
                self.showSplitMenuAtView(gesture.view as! FlipTextView)
            }
        } else if (gesture.state == UIGestureRecognizerState.Ended) {
            gesture.view?.alpha = 1
        }
    }
    
    
    // MARK: - Items Handler
    
    func addWordButtonTapped() {
        delegate?.flipMessageWordListViewDidTapAddWordButton(self)
    }
    
    // MARK: - Scroll Position Setters
    
    func centerAtFlipWord(flipWord: FlipText?) {
        for textView in flipTextViews {
            if (textView.flipText.position == flipWord?.position) {
                self.centerScrollViewAtView(textView)
            }
        }
    }
    
    
    // MARK: - Contextual Menu Handlers
    
    private func showSplitMenuAtView(flipTextView : FlipTextView!) {
        let menuController = UIMenuController.sharedMenuController()
        
        self.tappedFlipTextView = flipTextView;
        
        let scrollViewCurrentMinX: CGFloat = self.scrollView.bounds.minX
        let selectionRect : CGRect = CGRectMake(flipTextView.frame.origin.x - scrollViewCurrentMinX, flipTextView.frame.origin.y + 10, flipTextView.frame.size.width, flipTextView.frame.size.height);
        menuController.setTargetRect(selectionRect, inView: self)
        
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Split", comment: "Split"), action: NSSelectorFromString("splitText"))
        menuController.menuItems = NSArray(array: [lookupMenu]) as [AnyObject]
        
        menuController.update();
        
        menuController.setMenuVisible(true, animated: true)
    }
    
    func splitText() {
        delegate?.flipMessageWordListView(self, didSplitFlipWord: self.tappedFlipTextView?.flipText)
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
        
        var flipTextViewToBeCentered = flipTextViews[0]
        
        let scrollX = scrollView.contentOffset.x + CGRectGetMidX(scrollView.frame)
        
        for flipTextView in flipTextViews {
            let currentCenteredFlipTextViewMidX = CGRectGetMidX(flipTextViewToBeCentered.frame)
            let nextFlipTextViewMidX = CGRectGetMidX(flipTextView.frame)

            let currentCenteredFlipTextViewDistanceFromCenter = scrollX - currentCenteredFlipTextViewMidX
            let nextFlipTextViewDistanceFromCenter = scrollX - nextFlipTextViewMidX
            
            if (abs(currentCenteredFlipTextViewDistanceFromCenter) > abs(nextFlipTextViewDistanceFromCenter)) {
                flipTextViewToBeCentered = flipTextView
            }
        }
        
        let flipTextViewToBeCenteredMidX: CGFloat = CGRectGetMidX(flipTextViewToBeCentered.frame)
        let scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        let contentOffsetX = flipTextViewToBeCenteredMidX - scrollViewCenterX
        
        if (scrollView.contentOffset.x != contentOffsetX) {
            scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: true)
        } else {
            scrollView.scrollEnabled = true
        }
        
        if (self.enabled) {
            self.delegate?.flipMessageWordListView(self, didSelectFlipWord: flipTextViewToBeCentered.flipText)
        }
    }
    
    private func centerScrollViewAtView(view: UIView, animated: Bool = true) {
        let flipTextViewToBeCenteredMidX: CGFloat = CGRectGetMidX(view.frame)
        let scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        let contentOffsetX = flipTextViewToBeCenteredMidX - scrollViewCenterX
        
        if (scrollView.contentOffset.x != contentOffsetX) {
            scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: animated)
        }
    }
    
    
    // MARK: - Font Helper Methods
    
    private func getTextWidth(text: String) -> CGFloat {
        let flipTextString: NSString = text as NSString
        let font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = flipTextString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }
    
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "cut:" {
            return false
        }
            
        else if action == "copy:" {
            return false
        }
            
        else if action == "paste:" {
            return false
        }
            
        else if action == "_define:" {
            return false
        }
            
        else if action == "splitText" {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}


// MARK: - Protocols

protocol FlipMessageWordListViewDelegate: class {
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSelectFlipWord flipWord: FlipText!)

    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, didSplitFlipWord flipWordToSplit: FlipText!)
    
    func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView)
}

protocol FlipMessageWordListViewDataSource: class {
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> FlipText

    func numberOfFlipWords() -> Int
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int
    
}