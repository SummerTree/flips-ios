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
    
    private var avatarButton : UIButton!
    private var avatarImageView : RoundImageView!
	private var titleLabel : UILabel!
    
    private var leftButton : UIButton!
    private var rightButton : UIButton!
    
    private var buttonsMargin : CGFloat = 0.0
    
    var delegate : CustomNavigationBarDelegate?
    
    
    // MARK: - Static Creator Method
    
    class func CustomSmallNavigationBar(avatarImage: UIImage, showSettingsButton: Bool, showBuilderButton: Bool) -> CustomNavigationBar {
        
        var settingsButtonImage : UIImage?
        if (showSettingsButton) {
            settingsButtonImage = UIImage(named: "Settings")
        }
        
        var builderButtonImage : UIImage?
        if (showBuilderButton) {
            builderButtonImage = UIImage(named: "Builder")
        }
        
        var navBarHeight = SMALL_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        
        var imageView = RoundImageView.avatarA4()
        imageView.image = avatarImage
        
        navigationBar.setup(imageView, leftButtonImage: settingsButtonImage, rightButtonObject: builderButtonImage)
        
        return navigationBar
    }
    
    class func CustomSmallNavigationBar(title: String, showBackButton: Bool) -> CustomNavigationBar {
        
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back_White")
        }
        
        var navBarHeight = SMALL_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        
        navigationBar.buttonsMargin = NORMAL_NAV_BAR_BUTTON_MARGIN
        navigationBar.setup(title, leftButtonImage: backButtonImage)
        
        return navigationBar
    }

    
    class func CustomNormalNavigationBar(title: String, showBackButton: Bool) -> CustomNavigationBar {
        
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back_White")
        }
        
        var navBarHeight = NORMAL_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        navigationBar.buttonsMargin = NORMAL_NAV_BAR_BUTTON_MARGIN
        navigationBar.setup(title, leftButtonImage: backButtonImage)
        
        return navigationBar
    }
    
    class func CustomLargeNavigationBar(avatarImage: UIImage, isAvatarButtonInteractionEnabled: Bool = false, showBackButton: Bool, showNextButton: Bool) -> CustomNavigationBar {
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back_White")
        }
        
        var nextButtonImage : UIImage?
        var nextButtonInactiveImage : UIImage?
        if (showNextButton) {
            nextButtonImage = UIImage(named: "Forward")
            nextButtonInactiveImage = UIImage(named: "Forward_Inactive")
        }
        
        var navBarHeight = LARGE_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        navigationBar.buttonsMargin = LARGE_NAV_BAR_BUTTON_MARGIN
        
        var imageButton = UIButton.avatarA2(avatarImage)
        imageButton.userInteractionEnabled = isAvatarButtonInteractionEnabled
        
        navigationBar.setup(imageButton, leftButtonImage: backButtonImage, rightButtonObject: nextButtonImage, rightButtonInactiveObject: nextButtonInactiveImage)
        
        return navigationBar
    }
    
    class func CustomLargeNavigationBar(avatarImage: UIImage, isAvatarButtonInteractionEnabled: Bool = false, showBackButton: Bool, showSaveButton: Bool) -> CustomNavigationBar {
        var backButtonImage : UIImage?
        if (showBackButton) {
            backButtonImage = UIImage(named: "Back_Orange")
        }
        
        var saveButtonTitle : String?
        if (showSaveButton) {
            saveButtonTitle = NSLocalizedString("Save", comment: "Save")
        }
        
        var navBarHeight = LARGE_NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT
        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), navBarHeight)
        var navigationBar = CustomNavigationBar(frame: navBarFrame)
        navigationBar.buttonsMargin = LARGE_NAV_BAR_BUTTON_MARGIN
        
        var imageButton = UIButton.avatarA2WithoutBorder(avatarImage)
        imageButton.userInteractionEnabled = isAvatarButtonInteractionEnabled
        
        navigationBar.setup(imageButton, leftButtonImage: backButtonImage, rightButtonObject: saveButtonTitle)
        
        return navigationBar
    }
    
    // MARK: - Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundImageView = UIImageView(frame: frame)
        backgroundImageView.backgroundColor = UIColor.flipOrange()
        self.addSubview(backgroundImageView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup Methods
    
    private func setup(titleObject: AnyObject?, leftButtonImage: UIImage? = nil, leftButtonInactiveImage: UIImage? = nil, rightButtonObject: AnyObject? = nil, rightButtonInactiveObject: AnyObject? = nil) {
        if let title = titleObject as? String {
			titleLabel = UILabel()
			titleLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
			titleLabel.textColor = UIColor.whiteColor()
			titleLabel.text = title
			titleLabel.backgroundColor = UIColor.clearColor()
			titleLabel.sizeToFit()
			self.addSubview(titleLabel)
        } else if let imageView = titleObject as? RoundImageView {
            avatarImageView = imageView
            self.addSubview(avatarImageView)
        } else if let imageButton = titleObject as? UIButton {
            avatarButton = imageButton
            avatarButton.addTarget(self, action: "didTapAvatarButton", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(avatarButton)
        }
        
        self.setupButtons(leftButtonImage, leftButtonInactiveImage: leftButtonInactiveImage, rightButtonObject: rightButtonObject, rightButtonInactiveObject: rightButtonInactiveObject)
    }
    
    private func setupButtons(leftButtonImage: UIImage?, leftButtonInactiveImage: UIImage? = nil, rightButtonObject: AnyObject?, rightButtonInactiveObject: AnyObject? = nil) {
        if (leftButtonImage != nil) {
            leftButton = UIButton()
            leftButton.setImage(leftButtonImage, forState: .Normal)
            if (leftButtonInactiveImage != nil) {
                leftButton.setImage(leftButtonInactiveImage, forState: UIControlState.Disabled)
            }
            leftButton.addTarget(self, action: "didTapLeftButton", forControlEvents: .TouchUpInside)
            self.addSubview(leftButton)
        }
        
        if (rightButtonObject != nil) {
            // Right button could have a background image or a title
            rightButton = UIButton()
            if let rightButtonItem = rightButtonObject as? String {
                rightButton.setTitle(rightButtonItem, forState: .Normal)
                rightButton.setTitleColor(UIColor.flipOrange(), forState: UIControlState.Normal)
                rightButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
                rightButton.titleLabel?.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h3)
            } else if let rightButtonItem = rightButtonObject as? UIImage {
                rightButton.setImage(rightButtonItem, forState: .Normal)
                rightButton.setImage(rightButtonInactiveObject as? UIImage, forState: .Disabled)
            }
            
            rightButton.addTarget(self, action: "didTapRightButton", forControlEvents: .TouchUpInside)
            self.addSubview(rightButton)
        }
    }
    
    
    // MARK: -  Overridden Methods
    
    override func updateConstraints() {
        super.updateConstraints()
        
        if (avatarButton != nil) {
            avatarButton.mas_updateConstraints({ (update) -> Void in
                update.centerX.equalTo()(self)
                update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
                update.width.equalTo()(self.avatarButton.frame.size.width)
                update.height.equalTo()(self.avatarButton.frame.size.height)
            })
        }
        
        if (avatarImageView != nil) {
            avatarImageView.mas_updateConstraints { (update) -> Void in
                update.centerX.equalTo()(self)
                update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
                update.width.equalTo()(self.avatarImageView.frame.size.width)
                update.height.equalTo()(self.avatarImageView.frame.size.height)
            }
        }
        
		if (titleLabel != nil) {
			titleLabel.mas_updateConstraints({ (update) -> Void in
				update.centerX.equalTo()(self)
				update.centerY.equalTo()(self).with().offset()(STATUS_BAR_HEIGHT / 2)
				update.width.equalTo()(self.titleLabel.frame.size.width)
				update.height.equalTo()(self.titleLabel.frame.size.height)
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
    
    func getAvatarImage() -> UIImage! {
        if (avatarButton != nil) {
            return avatarButton.imageView?.image
        } else {
            return avatarImageView.image
        }
    }
    
    
    // MARK: - Setters
    
    func setRightButtonEnabled(enabled: Bool) {
        rightButton.enabled = enabled
    }
    
    func setLeftButtonEnabled(enabled: Bool) {
        leftButton.enabled = enabled
    }
    
    func setAvatarImage(image: UIImage) {
        if (avatarButton != nil) {
            avatarButton.setAvatarImage(image, forState: .Normal)
            avatarButton.setAvatarImage(image, forState: UIControlState.Highlighted)
        } else if (avatarImageView != nil) {
            avatarImageView.image = image
        }
    }
    
    func setAvatarImageURL(url: NSURL, success: ((UIImage) -> Void)? = nil) {
        if (avatarButton != nil) {
            ActivityIndicatorHelper.showActivityIndicatorAtView(avatarButton, style: UIActivityIndicatorViewStyle.Gray)
            let urlRequest = NSURLRequest(URL: url)
            
            avatarButton.setImageForState(.Normal, withURLRequest: urlRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.avatarButton)
                
                self.avatarButton.setAvatarImage(image, forState: .Normal)
                self.avatarButton.setAvatarImage(image, forState: UIControlState.Highlighted)
                if success != nil {
                    success!(image)
                }
                
                }, failure: { (error) -> Void in
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.avatarButton)
            })
        } else if (avatarImageView != nil) {
            ActivityIndicatorHelper.showActivityIndicatorAtView(avatarImageView, style: UIActivityIndicatorViewStyle.Gray)
            avatarImageView.setImageWithURL(url, success: { (request, response, image) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.avatarImageView)
                })
                if success != nil {
                    success!(image)
                }
            })
        }
    }
    
    
    // MARK: - Button Handlers
    
    func didTapLeftButton() {
        delegate?.customNavigationBarDidTapLeftButton?(self)
    }
    
    func didTapRightButton() {
        delegate?.customNavigationBarDidTapRightButton?(self)
    }
    
    func didTapAvatarButton() {
        delegate?.customNavigationBarDidTapAvatarButton?(self)
    }
    
    // MARK: - Blur Background Handler
    
    func setBackgroundImage(image: UIImage) {
        backgroundImageView.alpha = 1.0
        backgroundImageView.image = image.applyTintEffectWithColor(UIColor.flipOrange())
    }
    
    func setBackgroundImageColor(color: UIColor) {
        backgroundImageView.backgroundColor = color
    }
}