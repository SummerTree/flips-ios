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

// It needs to declared outside of the class because it is being used in a static method. Swift is not supporting static variables yet.
private let STATUS_BAR_HEIGHT = UIApplication.sharedApplication().statusBarFrame.size.height
private let SMALL_NAVIGATION_BAR_HEIGHT : CGFloat = 56.0

private let NORMAL_NAVIGATION_BAR_HEIGHT : CGFloat = 70.0
private let NORMAL_NAV_BAR_BUTTON_MARGIN : CGFloat = 8.0

private let LARGE_NAVIGATION_BAR_HEIGHT : CGFloat = 145.0
private let LARGE_NAV_BAR_BUTTON_MARGIN : CGFloat = 8.0

class CustomNavigationBar : UIView {
    
    private let BUTTON_HORIZONTAL_MARGIN : CGFloat = 11.0
    private let BUTTON_MINIMUM_SIZE : CGFloat = 44.0
    
    private var backgroundImageView : UIImageView!
    
    private var avatarImageView : UIImageView!
    private var titleTextView : UITextView!
    
    private var leftButton : UIButton!
    private var rightButton : UIButton!
    
    private var buttonsMargin : CGFloat = 0.0
    
    var delegate : CustomNavigationBarDelegate?
    
    
    // MARK: - Static Creator Method
    
    class func CustomSmallNavigationBar(avatarImage : UIImage, showSettingsButton : Bool, showBuiderButton : Bool) -> CustomNavigationBar {
        
        var settingsButtonImage : UIImage?
        if (showSettingsButton) {
            settingsButtonImage = UIImage(named: "Settings")
        }
        
        var builderButtonImage : UIImage?
        if (showBuiderButton) {
            builderButtonImage = UIImage(named: "Builder")
        }
        
        var navBarHeight = SMALL_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        
        var imageView = UIImageView.avatarA4()
        imageView.image = avatarImage
        
        navigationBar.setup(imageView, leftButtonImage: settingsButtonImage, rightButtonImage: builderButtonImage)
        
        return navigationBar
    }
    
    class func CustomNormalNavigationBar(title : String, showBackButton : Bool) -> CustomNavigationBar {
        
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back")
        }
        
        var navBarHeight = NORMAL_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        navigationBar.buttonsMargin = NORMAL_NAV_BAR_BUTTON_MARGIN
        navigationBar.setup(title, leftButtonImage: backButtonImage)
        
        return navigationBar
    }
    
    class func CustomLargeNavigationBar(avatarImage : UIImage, showBackButton : Bool, showSaveButton : Bool) -> CustomNavigationBar {
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back")
        }
        
        var saveButtonTitle : String?
        if (showSaveButton) {
            saveButtonTitle = NSLocalizedString("Save", comment: "Save")
        }
        
        var navBarHeight = LARGE_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        navigationBar.buttonsMargin = LARGE_NAV_BAR_BUTTON_MARGIN
        var imageView = UIImageView.avatarA2()
        imageView.image = avatarImage
        
        navigationBar.setup(imageView, leftButtonImage: backButtonImage, rightButtonImage: saveButtonTitle)

        return navigationBar
    }
    
    
    // MARK: - Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.backgroundColor = UIColor.mugOrange()
        backgroundImageView.alpha = 0.9
        self.addSubview(backgroundImageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup Methods
    
    private func setup(titleObject : AnyObject?, leftButtonImage : UIImage? = nil, rightButtonImage : AnyObject? = nil) {
        if let title = titleObject as? String {
            titleTextView = UITextView()
            titleTextView.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
            titleTextView.textColor = UIColor.whiteColor()
            titleTextView.text = title
            titleTextView.backgroundColor = UIColor.clearColor()
            titleTextView.sizeToFit()
            self.addSubview(titleTextView)
        } else if let imageView = titleObject as? UIImageView {
            avatarImageView = imageView
            self.addSubview(avatarImageView)
        }
        
        self.setupButtons(leftButtonImage, rightButtonObject: rightButtonImage)
    }

    private func setupButtons(leftButtonImage : UIImage?, rightButtonObject : AnyObject?) {
        if (leftButtonImage != nil) {
            leftButton = UIButton()
            leftButton.setImage(leftButtonImage, forState: .Normal)
            leftButton.addTarget(self, action: "didTapLeftButton", forControlEvents: .TouchUpInside)
            self.addSubview(leftButton)
        }
        
        if (rightButtonObject != nil) {
            // Right button could have a background image or a title
            rightButton = UIButton()
            if let rightButtonItem = rightButtonObject as? String {
                rightButton.setTitle(rightButtonItem, forState: .Normal)
                rightButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
                rightButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
                rightButton.titleLabel?.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h3)
            } else if let rightButtonItem = rightButtonObject as? UIImage {
                rightButton.setImage(rightButtonItem, forState: .Normal)
            }

            rightButton.addTarget(self, action: "didTapRightButton", forControlEvents: .TouchUpInside)
            self.addSubview(rightButton)
        }
    }
    
    
    // MARK: -  Overridden Methods
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if (avatarImageView != nil) {
            avatarImageView.mas_updateConstraints { (update) -> Void in
                update.centerX.equalTo()(self)
                update.centerY.equalTo()(self.mas_centerY).with().offset()(STATUS_BAR_HEIGHT / 2)
                update.width.equalTo()(self.avatarImageView.frame.size.width)
                update.height.equalTo()(self.avatarImageView.frame.size.height)
            }
        }
        
        if (titleTextView != nil) {
            titleTextView.mas_updateConstraints({ (update) -> Void in
                update.centerX.equalTo()(self)
                update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
                update.width.equalTo()(self.titleTextView.frame.size.width)
                update.height.equalTo()(self.titleTextView.frame.size.height)
            })
        }

        if (leftButton != nil) {
            leftButton.mas_updateConstraints { (update) -> Void in
                update.leading.equalTo()(self).with().offset()(self.buttonsMargin)
                update.width.equalTo()(self.BUTTON_MINIMUM_SIZE)
                update.height.equalTo()(self.BUTTON_MINIMUM_SIZE)
            }
        }
        
        if (rightButton != nil) {
            rightButton.mas_updateConstraints { (update) -> Void in
                update.trailing.equalTo()(self).with().offset()(-self.buttonsMargin)
                update.width.greaterThanOrEqualTo()(self.BUTTON_MINIMUM_SIZE)
                update.height.greaterThanOrEqualTo()(self.BUTTON_MINIMUM_SIZE)
            }
        }

        if (CGRectGetHeight(self.frame) >= LARGE_NAVIGATION_BAR_HEIGHT) {
            // Buttons should be top aligned
            if (leftButton != nil) {
                leftButton.mas_updateConstraints { (update) -> Void in
                    update.top.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT)
                    return ()
                }
            }
            
            if (rightButton != nil) {
                rightButton.mas_updateConstraints { (update) -> Void in
                    update.top.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT)
                    return ()
                }
            }
        } else {
            // Buttons should be centered
            if (leftButton != nil) {
                leftButton.mas_updateConstraints { (update) -> Void in
                    update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
                    return ()
                }
            }
            
            if (rightButton != nil) {
                rightButton.mas_updateConstraints { (update) -> Void in
                    update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
                    return ()
                }
            }
        }
    }
    

    // MARK: - Getters
    
    func getNavigationBarHeight() -> CGFloat {
        return CGRectGetHeight(self.frame) - STATUS_BAR_HEIGHT
    }
    
    
    // MARK: - Button Handlers
    
    func didTapLeftButton() {
        delegate?.customNavigationBarDidTapLeftButton(self)
    }
    
    func didTapRightButton() {
        delegate?.customNavigationBarDidTapRightButton(self)
    }
    
    
    // MARK: - Blur Background Handler
    
    func setBackgroundImage(image: UIImage) {
        backgroundImageView.alpha = 1.0
        backgroundImageView.image = image.applyTintEffectWithColor(UIColor.mugOrange())
    }
}