//
//  EndlessScrollView.swift
//  flips
//
//  Created by Taylor Bell on 9/18/15.
//
//

class EndlessScrollView : UIView, UIScrollViewDelegate {
    
    private var views : [UIView] = []
    private var imageViews : [UIImageView] = []
    private var scrollView : UIScrollView!
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        initScrollView()
    }
    
    
    
    ////
    // MARK: - ScrollView Setup
    ////
    
    private func initScrollView() {
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        addSubview(scrollView)
        
        scrollView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.width.equalTo()(self)
            make.height.equalTo()(self)
        }
        
    }
    
    
    
    ////
    // MARK: - Layout
    ////
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (var i = 0; i < views.count; i++) {
            
            if i == 0
            {
                imageViews[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.scrollView)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            else
            {
                imageViews[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.imageViews[i - 1].mas_bottom)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            
        }
        
        for (var i = 0; i < views.count; i++) {
            
            if i == 0
            {
                views[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.imageViews[self.views.count - 1].mas_bottom)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            else
            {
                views[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.views[i - 1].mas_bottom)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            
        }
        
        for (var i = views.count; i < views.count * 2; i++) {
            
            if i == views.count
            {
                imageViews[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.views[self.views.count - 1].mas_bottom)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            else
            {
                imageViews[i].mas_makeConstraints({ (make) -> Void in
                    make.top.equalTo()(self.imageViews[i - 1].mas_bottom)
                    make.left.equalTo()(self.scrollView)
                    make.width.equalTo()(self.scrollView)
                    make.height.equalTo()(self.scrollView)
                })
            }
            
        }
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.width, scrollView.frame.height * CGFloat(views.count * 3))
        scrollView.contentOffset = CGPointMake(0, scrollView.frame.height * CGFloat(views.count))
        
    }
    
    
    
    ////
    // MARK: - Subview Management
    ////
    
    private func addView(view: UIView) {
        
        
        let topImageView = UIImageView()
        topImageView.backgroundColor = UIColor.redColor()
        
        let bottomImageView = UIImageView()
        bottomImageView.backgroundColor = UIColor.blueColor()
        
        views.append(view)
        
        imageViews.append(topImageView)
        imageViews.append(bottomImageView)
        
        scrollView.addSubview(topImageView)
        scrollView.addSubview(view)
        scrollView.addSubview(bottomImageView)
        
    }
    
    func addViews(views: [UIView]) {
        
        for view in views {
            addView(view)
        }
        
        layoutSubviews()
        
    }
    
    
    
    ////
    // MARK: - Scrolling
    ////
    
    func scrollToPageIndex(index: Int, animated: Bool) {
        
        if index > 0 && index < self.views.count {
            self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.bounds.height * CGFloat(self.views.count + index)), animated: animated)
        }
        
    }
    
    
    ////
    // MARK: - UIImageView Management
    ////
    
    private func refreshImages() {
        
        for (var i = 0; i < views.count; i++) {
            
            let view = views[i]
            
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, view.opaque, 0.0)
            view.layer.renderInContext(UIGraphicsGetCurrentContext())
            let viewImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            imageViews[i].image = viewImage
            imageViews[i + views.count].image = viewImage
        }
        
    }
    
    
    
    ////
    // MARK: - UIScrollView Delegate
    ////
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        refreshImages()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = self.scrollView.contentOffset.y
        let scrollViewHeight = self.scrollView.bounds.height
        let pageIndex = Int(offsetY / scrollViewHeight)
        
        if  pageIndex < self.views.count  || pageIndex >= self.views.count * 2 {
            self.scrollView.userInteractionEnabled = false
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let offsetY = self.scrollView.contentOffset.y
        let scrollViewHeight = self.scrollView.bounds.height
        var pageIndex = Int(offsetY / scrollViewHeight)
        
        if  pageIndex < self.views.count {
            self.scrollView.setContentOffset(CGPointMake(0, scrollViewHeight * CGFloat(self.views.count + pageIndex)), animated: false)
        }
        else if pageIndex >= self.views.count * 2 {
            pageIndex = pageIndex % self.views.count
            self.scrollView.setContentOffset(CGPointMake(0, scrollViewHeight * CGFloat(self.views.count + pageIndex)), animated: false)
        }
        
        self.scrollView.userInteractionEnabled = true
        
    }
    
}