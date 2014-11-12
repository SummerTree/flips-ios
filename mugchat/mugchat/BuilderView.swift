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

import UIKit

class BuilderView : UIView {
    
    var delegate: BuilderViewDelegate?

    private let CONTENT_MARGIN_LEFT:    CGFloat = 25.0
    private let CONTENT_MARGIN_RIGHT:   CGFloat = -25.0
    private let TOP_CONTAINER_HEIGHT:   CGFloat = 60.0
    private let SEPARATOR_HEIGHT:       CGFloat = 50.0
    private let OK_SWEET_BUTTON_HEIGHT: CGFloat = 62.0
    private let OK_SWEET_BUTTON_WIDTH:  CGFloat = 195.0
    private let OK_SWEET_CORNER_RADIUS: CGFloat = 30.0
    private let OK_SWEET_BACKGROUND_COLOR: UIColor = UIColor(RRGGBB: UInt(0x4A90E2))
    
    private var backgroundImageView: UIImageView!
    private var contentTopContainer: UIView!
    private var hiUserLabel: UILabel!
    private var thisIsYourWordBuilderLabel: UILabel!
    private var separatorBetweenNameAndDescription: UIView!
    private var descriptionLabel: UILabel!
    private var separatorBetweenDescriptionAndButton: UIView!
    private var okSweetButton: UIButton!
    private var separatorBetweenButtonAndBottom: UIView!
    
    override init() {
        super.init()
        
        addSubviews()
        makeConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func viewDidLoad() {
        makeConstraints()
    }
    
    func addSubviews() {
        var backgroundImage = UIImage(named: "BuilderBackground")
        var blurredImage = applyBlur(backgroundImage!)
        self.backgroundImageView = UIImageView(image: blurredImage)
        self.addSubview(backgroundImageView)
        
        self.contentTopContainer = UIView()
        self.addSubview(contentTopContainer)
        
        self.hiUserLabel = UILabel()
        self.hiUserLabel.numberOfLines = 1
        self.hiUserLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h1)
        self.hiUserLabel.text = "Hi \(User.loggedUser()!.firstName),"
        self.hiUserLabel.textColor = UIColor.deepSea()
        self.hiUserLabel.textAlignment = NSTextAlignment.Center
        self.hiUserLabel.sizeToFit()
        self.addSubview(hiUserLabel)
        
        self.thisIsYourWordBuilderLabel = UILabel()
        self.thisIsYourWordBuilderLabel.numberOfLines = 1
        self.thisIsYourWordBuilderLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h2)
        self.thisIsYourWordBuilderLabel.text = "this is your word builder."
        self.thisIsYourWordBuilderLabel.textColor = UIColor.deepSea()
        self.thisIsYourWordBuilderLabel.textAlignment = NSTextAlignment.Center
        self.thisIsYourWordBuilderLabel.sizeToFit()
        self.addSubview(thisIsYourWordBuilderLabel)
        
        self.separatorBetweenNameAndDescription = UIView()
        self.addSubview(separatorBetweenNameAndDescription)
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.numberOfLines = 0
        
        if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
            self.descriptionLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        } else {
            self.descriptionLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        }
        self.descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let descriptionText = "It's a quick & easy tool to define & add\nwords to use for future messages. We have\nsuggested words to get you started, but feel free\nto add as many words as you like."
        self.descriptionLabel.text = NSLocalizedString(descriptionText, comment: descriptionText)
        self.descriptionLabel.textColor = UIColor.deepSea()
        self.descriptionLabel.textAlignment = NSTextAlignment.Center
        self.descriptionLabel.sizeToFit()
        self.addSubview(descriptionLabel)

        self.separatorBetweenDescriptionAndButton = UIView()
        self.addSubview(separatorBetweenDescriptionAndButton)

        self.okSweetButton = UIButton()
        self.okSweetButton.addTarget(self, action: "okSweetButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.okSweetButton.backgroundColor = self.OK_SWEET_BACKGROUND_COLOR
        self.okSweetButton.layer.cornerRadius = self.OK_SWEET_CORNER_RADIUS
        self.okSweetButton.setAttributedTitle(NSAttributedString(string:NSLocalizedString("ok, sweet!", comment: "ok, sweet!"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextRegular(UIFont.HeadingSize.h4)]), forState: UIControlState.Normal)
        self.addSubview(okSweetButton)
        
        self.separatorBetweenButtonAndBottom = UIView()
        self.addSubview(separatorBetweenButtonAndBottom)

    }
    
    func makeConstraints() {
        self.backgroundImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        self.contentTopContainer.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.greaterThanOrEqualTo()(self.TOP_CONTAINER_HEIGHT)
        }
        
        self.hiUserLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentTopContainer.mas_bottom)
            make.left.equalTo()(self.contentTopContainer).with().offset()(self.CONTENT_MARGIN_LEFT)
            make.right.equalTo()(self.contentTopContainer).with().offset()(self.CONTENT_MARGIN_RIGHT)
            make.height.equalTo()(self.hiUserLabel.frame.size.height)
        }
        
        self.thisIsYourWordBuilderLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.hiUserLabel.mas_bottom)
            make.left.equalTo()(self.contentTopContainer).with().offset()(self.CONTENT_MARGIN_LEFT)
            make.right.equalTo()(self.contentTopContainer).with().offset()(self.CONTENT_MARGIN_RIGHT)
            make.height.equalTo()(self.thisIsYourWordBuilderLabel.frame.size.height)
        }

        self.separatorBetweenNameAndDescription.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.thisIsYourWordBuilderLabel.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.separatorBetweenDescriptionAndButton)
        }
        
        self.descriptionLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.separatorBetweenNameAndDescription.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.CONTENT_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(self.CONTENT_MARGIN_RIGHT)
        }
        
        self.separatorBetweenDescriptionAndButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.descriptionLabel.mas_bottom)
            make.bottom.equalTo()(self.okSweetButton.mas_top)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.greaterThanOrEqualTo()(self.SEPARATOR_HEIGHT)
        }
        
        self.okSweetButton.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.separatorBetweenButtonAndBottom.mas_top)
            make.centerX.equalTo()(self)
            make.height.equalTo()(self.OK_SWEET_BUTTON_HEIGHT)
            make.width.equalTo()(self.OK_SWEET_BUTTON_WIDTH)
        }
        
        self.separatorBetweenButtonAndBottom.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.contentTopContainer)
        }

    }
    
    func applyBlur(image: UIImage) -> UIImage {
        return image.applyBlurWithRadius(10, tintColor: UIColor(white: 255, alpha: 0.5), saturationDeltaFactor: 1.5, maskImage: nil)
    }
}

protocol BuilderViewDelegate {
    func builderViewDidTapOkSweetButton(builderView: BuilderView!)
}