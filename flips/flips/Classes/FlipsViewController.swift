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

import Foundation

class FlipsViewController : UIViewController {
    
    private let ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION = 0.25
    private let ACTIVITY_INDICATOR_SIZE: CGFloat = 100
    
    private let LOADING_CONTAINER_VERTICAL_MARGIN: CGFloat = 10
    private let LOADING_CONTAINER_HORIZONTAL_MARGIN: CGFloat = 20
    private let LOADING_MESSAGE_TOP_MARGIN: CGFloat = 15

    private var loadingContainer: UIView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadingMessageLabel: UILabel!
    
    
    // MARK: - Init methods
    
    override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
		super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupActivityIndicator()
        self.view.bringSubviewToFront(self.activityIndicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        // Default is light - to apply black content you should override this method
        return UIStatusBarStyle.LightContent
    }
    
    
    // MARK: Activity Indicator Methods
    
    internal func setupActivityIndicator() {
        loadingContainer = UIView()
        loadingContainer.clipsToBounds = true
        loadingContainer.layer.cornerRadius = 8
        loadingContainer.layer.masksToBounds = true
        loadingContainer.backgroundColor = UIColor.blackColor()
        loadingContainer.alpha = 0
        self.view.addSubview(loadingContainer)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingContainer.addSubview(activityIndicator)
        
        loadingMessageLabel = UILabel()
        loadingMessageLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        loadingMessageLabel.textColor = UIColor.whiteColor()
        loadingMessageLabel.textAlignment = NSTextAlignment.Center
        loadingMessageLabel.numberOfLines = 2
        loadingContainer.addSubview(loadingMessageLabel)
    }
    
    func showActivityIndicator(userInteractionEnabled: Bool = false, message: String? = nil) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.bringSubviewToFront(self.loadingContainer)
            
            let isShowingMessage: Bool = (message != nil)
            if (isShowingMessage) {
                self.loadingMessageLabel.text = message!
            } else {
                self.loadingMessageLabel.text = ""
            }
            self.updateLoadingViewConstraints(isShowingMessage)
            
            self.view.userInteractionEnabled = userInteractionEnabled
            self.activityIndicator.startAnimating()
            UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
                self.loadingContainer.alpha = 0.8
            })
        })
    }
    
    private func updateLoadingViewConstraints(isShowingText: Bool) {
        loadingMessageLabel.sizeToFit()
        
        var containerHeight = self.ACTIVITY_INDICATOR_SIZE
        var containerWidth = self.ACTIVITY_INDICATOR_SIZE
        if (isShowingText) {
            containerHeight = self.ACTIVITY_INDICATOR_SIZE + loadingMessageLabel.frame.size.height + LOADING_CONTAINER_VERTICAL_MARGIN
            containerWidth = loadingMessageLabel.frame.size.width + LOADING_CONTAINER_HORIZONTAL_MARGIN
        }
        
        loadingContainer.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.center.equalTo()(self.view)
            update.width.equalTo()(containerWidth)
            update.height.equalTo()(containerHeight)
        }
        
        activityIndicator.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.top.equalTo()(self.loadingContainer)
            update.centerX.equalTo()(self.loadingContainer)
            update.width.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
            update.height.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
        }
        
        loadingMessageLabel.mas_updateConstraints { (update) -> Void in
            update.removeExisting = true
            update.centerX.equalTo()(self.loadingContainer)
            update.top.equalTo()(self.loadingContainer.mas_centerY).offset()(self.LOADING_MESSAGE_TOP_MARGIN)
            update.width.equalTo()(self.loadingMessageLabel.frame.size.width)
            update.height.equalTo()(self.loadingMessageLabel.frame.size.height)
        }
        
        self.view.updateConstraints()
    }
    
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.userInteractionEnabled = true
            UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
                self.loadingContainer.alpha = 0
            }, completion: { (finished) -> Void in
                self.activityIndicator.stopAnimating()
            })
        })
    }
    
    func previousViewController() -> UIViewController? {
        let numberOfViewControllers = self.navigationController?.viewControllers.count
        if (numberOfViewControllers < 2) {
            return nil
        }
        
        return self.navigationController?.viewControllers![numberOfViewControllers! - 2] as UIViewController!
    }
}
