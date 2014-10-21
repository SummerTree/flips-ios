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

class CenteredMugsView : UIView, UIScrollViewDelegate {
    
    private let MIN_BUTTON_WIDTH : CGFloat = 70.0
    private let MUG_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
    private let MUG_TEXT_HEIGHT : CGFloat = 40.0
    private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0
    
    private let ITEMS_SPACING: CGFloat = 20
    
    var scrollView: UIScrollView!
    
    private var mugTexts: [MugText]!
    private var mugTextViews: [MugTextView]!
    
    
    // MARK: - Initializers
    
    init(mugTexts: [MugText]) {
        super.init(frame: CGRect.zeroRect)
        self.mugTexts = mugTexts
        self.mugTextViews = [MugTextView]()
        
        self.addSubviews()
        self.addConstraints()
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
            scrollView.addSubview(mugTextView)
            mugTextViews.append(mugTextView)
            
            mugTextView.userInteractionEnabled = true
            
            var holdGesture = UILongPressGestureRecognizer(target: self, action: "mugButtonTapped:")
            holdGesture.minimumPressDuration = 0.1 // It is required to avoid conflict with the swipe in the scrollView
            mugTextView.addGestureRecognizer(holdGesture)
        }
    }
    
    func mugButtonTapped(gesture: UILongPressGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Began) {
            gesture.view?.alpha = 0.5
            self.centerScrollViewAtView(gesture.view!)
        } else if (gesture.state == UIGestureRecognizerState.Ended) {
            gesture.view?.alpha = 1
        }
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
        super.layoutSubviews()
        
        var contentOffset: CGFloat = 0.0
        var index = 0
        
        for mugText in mugTexts {
            var mugTextView = self.mugTextViews[index]
            
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
                rightMargin = ITEMS_SPACING
            }
            contentOffset += mugTextView.frame.size.width + rightMargin
            scrollView.contentSize = CGSizeMake(contentOffset, mugTextView.frame.size.height)
            
            index++
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
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
}