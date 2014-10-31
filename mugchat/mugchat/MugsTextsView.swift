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

class MugsTextsView : UIView, UIScrollViewDelegate {
    
    private let MIN_BUTTON_WIDTH : CGFloat = 70.0
    private let MUG_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
    private let MUG_TEXT_HEIGHT : CGFloat = 40.0
    private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0
    
    var scrollView: UIScrollView!
    
    private var mugTexts: [MugText]!
    private var mugTextViews: [MugTextView]!
    private var tappedMugTextView: MugTextView?
    
    var delegate: MugsTextsViewDelegate?
    
    // MARK: - Initializers
    
    init(mugTexts: [MugText]) {
        super.init(frame: CGRect.zeroRect)
        self.mugTexts = mugTexts
        self.mugTextViews = [MugTextView]()
        
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
        
        for mugText in mugTexts {
            var mugTextView = MugTextView(mugText: mugText)
            mugTextView.sizeToFit()
            addGestureRecognizers(mugTextView)
            scrollView.addSubview(mugTextView)
            
            mugTextViews.append(mugTextView)
        }
    }
    
    func addGestureRecognizers(mugTextView: MugTextView) {
        mugTextView.userInteractionEnabled = true
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "mugButtonTapped:")
        mugTextView.addGestureRecognizer(tapGesture)
        
        var holdGesture = UILongPressGestureRecognizer(target: self, action: "mugButtonLongPress:")
        mugTextView.addGestureRecognizer(holdGesture)
    }
    
    func mugButtonTapped(gesture : UIGestureRecognizer) {
        self.centerScrollViewAtView(gesture.view!)
        self.delegate?.mugsTextsViewDidSelectMugText((gesture.view! as MugTextView).mugText)
    }
    
    func selectText(text: MugText?) {
        for textView in mugTextViews {
            if (textView.mugText.mugId == text?.mugId) {
                self.centerScrollViewAtView(textView)
                self.delegate?.mugsTextsViewDidSelectMugText((textView as MugTextView).mugText)
                break
            }
        }
    }
    
    func mugButtonLongPress(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began) {
            gesture.view?.alpha = 0.5
            self.showSplitMenuAtView(gesture.view! as MugTextView)
        } else if (gesture.state == UIGestureRecognizerState.Ended) {
            gesture.view?.alpha = 1
        }
    }
    
    func showSplitMenuAtView(mugTextView : MugTextView!) {
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
        let text = self.tappedMugTextView?.mugText.text
        
        var splittedTextWords: [String] = MugStringsUtil.splitMugString(text!);
        
        var mugTextView: MugTextView
        var lastMugText: MugTextView!
        var splitMugTextView: MugTextView!
        
        var foundMug: Bool = false
        var contentOffset: CGFloat = 0.0
        var scrollViewWidth: CGFloat = self.scrollView.contentSize.width
        var textViewY = (CGRectGetHeight(self.frame) / 2) - (MUG_TEXT_HEIGHT / 2)
        
        var index = -1
        var mugTextViewsUpdated = [MugTextView]()
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () -> Void in
            
            for mugTextView in self.mugTextViews {
                index++
                mugTextViewsUpdated.append(mugTextView)
                
                if (mugTextView.mugText.text == text) {
                    foundMug = true
                    
                    var oldMugTextViewWidth : CGFloat = mugTextView.frame.width
                    
                    //Update the original MugText with the first string of the splitted text
                    mugTextView.mugText.text = splittedTextWords[0]
                    mugTextView.textLabel.text = splittedTextWords[0]
                    self.mugTexts[index].text = splittedTextWords[0]
                    
                    //update mugTextView size to fit the smaller text
                    var requiredWidth = mugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
                    var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
                    mugTextView.frame = CGRectMake(mugTextView.frame.origin.x, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
                    
                    scrollViewWidth = scrollViewWidth - oldMugTextViewWidth + mugTextViewWidth
                    
                    splitMugTextView = mugTextView
                    lastMugText = mugTextView
                    
                    contentOffset = lastMugText.frame.origin.x + lastMugText.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
                    
                    var newMugTextView : MugTextView
                    for var i=1; i < splittedTextWords.count; i++ { //creating and positioning new MugTextViews
                        index++
                        
                        var mugText = MugText(mugId: self.mugTexts.count, text: splittedTextWords[i], state: MugState.NewWord)
                        self.mugTexts.insert(mugText, atIndex: index)
                        
                        newMugTextView = MugTextView(mugText: mugText)
                        self.addGestureRecognizers(newMugTextView)
                        self.scrollView.addSubview(newMugTextView)
                        
                        var requiredWidth = newMugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
                        var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
                        newMugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
                        mugTextViewsUpdated.append(newMugTextView)
                        
                        lastMugText = newMugTextView
                        contentOffset += newMugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
                        scrollViewWidth += newMugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
                    }
                    
                    self.scrollView.contentSize = CGSizeMake(scrollViewWidth, self.scrollView.contentSize.height)
                } else {
                    if (foundMug) { //texts after the split one must be moved to the right
                        var requiredWidth = mugTextView.getTextWidth() + self.MUG_TEXT_ADDITIONAL_WIDTH
                        var mugTextViewWidth = requiredWidth > self.MIN_BUTTON_WIDTH ? requiredWidth : self.MIN_BUTTON_WIDTH
                        
                        mugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, self.MUG_TEXT_HEIGHT)
                        
                        contentOffset += mugTextView.frame.size.width + self.SPACE_BETWEEN_MUG_TEXTS
                    }
                }
            }
            
            }, completion: { (value: Bool) in
                //Updating mugTextViews with new mugTexts
                for var i=0; i < mugTextViewsUpdated.count; i++ {
                    var mugTextView = mugTextViewsUpdated[i]
                    if ((i < self.mugTextViews.count) && (self.mugTextViews[i].mugText.mugId != mugTextView.mugText.mugId)) {
                        self.mugTextViews.insert(mugTextView, atIndex: i)
                    } else {
                        self.mugTextViews.append(mugTextView)
                    }
                }
                
                self.delegate?.mugsTextsViewDidSplitMugText(self.mugTexts)
                
                self.centerScrollViewAtView(splitMugTextView)
                self.delegate?.mugsTextsViewDidSelectMugText(splitMugTextView.mugText)
            ()})

    }
    
    private func addConstraints() {
        scrollView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    
    // MARK: - Overridden Methods
    
    override func layoutSubviews() {
        var contentOffset: CGFloat = 0.0
        var index = 0
        
        for mugText in mugTexts {
            var mugTextView = self.mugTextViews[index]
            mugTextView.updateLayout()
            
            var requiredWidth = self.getTextWidth(mugText) + MUG_TEXT_ADDITIONAL_WIDTH
            var mugTextViewWidth = requiredWidth > MIN_BUTTON_WIDTH ? requiredWidth : MIN_BUTTON_WIDTH
            
            var leftMargin: CGFloat = 0
            var rightMargin: CGFloat = 0
            if (index == 0) {
                // Add left margin
                leftMargin = (CGRectGetWidth(self.frame) / 2) - (mugTextViewWidth / 2)
            } else if (index == (mugTexts.count - 1)) {
                // Add right margin
                rightMargin = (CGRectGetWidth(self.frame) / 2) - (mugTextViewWidth / 2)
            }
            
            contentOffset += leftMargin
            
            var textViewY = (CGRectGetHeight(self.frame) / 2) - (MUG_TEXT_HEIGHT / 2)
            mugTextView.frame = CGRectMake(contentOffset, textViewY, mugTextViewWidth, MUG_TEXT_HEIGHT)
            
            if (rightMargin == 0) {
                // The last item already has his rightMargin
                rightMargin = SPACE_BETWEEN_MUG_TEXTS
            }
            contentOffset += mugTextView.frame.size.width + rightMargin
            scrollView.contentSize = CGSizeMake(contentOffset, mugTextView.frame.size.height)
            
            index++
        }
        
        super.layoutSubviews()
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        let menuController = UIMenuController.sharedMenuController()
        menuController.setMenuVisible(false, animated: true)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.centerScrollViewAtClosestItem(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.centerScrollViewAtClosestItem(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.scrollEnabled = true
    }
    
    
    // MARK: - ScrollView Helper Methods
    
    private func centerScrollViewAtClosestItem(scrollView: UIScrollView) {
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
        
        self.delegate?.mugsTextsViewDidSelectMugText(mugTextViewToBeCentered.mugText)
    }
    
    private func centerScrollViewAtView(view: UIView) {
        scrollView.scrollEnabled = false
        
        var mugTextViewToBeCenteredMidX: CGFloat = CGRectGetMidX(view.frame)
        var scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        var contentOffsetX = mugTextViewToBeCenteredMidX - scrollViewCenterX
        
        if (scrollView.contentOffset.x != contentOffsetX) {
            scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: true)
        } else {
            scrollView.scrollEnabled = true
        }
    }
    
    
    // MARK: - Font Helper Methods
    
    func getTextWidth(mugText: MugText) -> CGFloat{
        let mugTextString: NSString = mugText.text as NSString
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

// MARK: - View Delegate

protocol MugsTextsViewDelegate {

    func mugsTextsViewDidSelectMugText(mugText: MugText!)
    func mugsTextsViewDidSplitMugText(mugTexts: [MugText])
    
}