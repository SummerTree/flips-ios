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

class MugChatViewController : UIViewController {
    
    private let ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION = 0.25
    private let ACTIVITY_INDICATOR_SIZE: CGFloat = 100
    private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Init methods
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
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
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        activityIndicator.backgroundColor = UIColor.blackColor()
        activityIndicator.alpha = 0
        activityIndicator.layer.cornerRadius = 8
        activityIndicator.layer.masksToBounds = true
        self.view.addSubview(activityIndicator)
        
        activityIndicator.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self.view)
            make.width.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
            make.height.equalTo()(self.ACTIVITY_INDICATOR_SIZE)
        }
    }
    
    func showActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.userInteractionEnabled = false
            self.activityIndicator.startAnimating()
            UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
                self.activityIndicator.alpha = 0.8
            })
        })
    }
    
    func hideActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.userInteractionEnabled = true
            self.activityIndicator.startAnimating()
            UIView.animateWithDuration(self.ACTIVITY_INDICATOR_FADE_ANIMATION_DURATION, animations: { () -> Void in
                self.activityIndicator.alpha = 0
            }, completion: { (finished) -> Void in
                self.activityIndicator.stopAnimating()
            })
        })
        
    }
    
}
