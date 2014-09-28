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

class PhoneNumberView : UIView, UITextFieldDelegate {
    
    private let MARGIN_TOP: CGFloat = 40.0
    
    private let TOP_BAR_MARGIN_LEFT: CGFloat = 16.0
    private let TOP_BAR_MARGIN_RIGHT: CGFloat = 16.0
    private let TOP_BAR_HEIGHT: CGFloat = 44.0
    private let HINT_VIEW_HEIGHT: CGFloat = 218.0
    private let HINT_VIEW_MARGIN_LEFT: CGFloat = 25.0
    private let HINT_VIEW_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_LEFT: CGFloat = 25.0
    private let MOBILE_NUMBER_MARGIN_RIGHT: CGFloat = 25.0
    private let MOBILE_NUMBER_VIEW_HEIGHT: CGFloat = 60.0
    
    private let TOP_BAR_TITLE: String = "Phone Number"
    private let HINT_TEXT: String = "Enter your number\n to verify you are a human."
    
    var topBarView: UIView!
    var topBarTitle: UILabel!
    var backButton: UIButton!
    var backImage: UIImage!
    var hintView: UIView!
    var hintText: UILabel!
    var mobileNumberView: UIView!
    var phoneImageView: UIImageView!
    var mobileNumberField: UITextField!
    var noticeView: UIView!
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.updateConstraintsIfNeeded()
    }

    
    func addSubviews() {
        
        topBarView = UIView()
        topBarView.contentMode = .Center
        self.addSubview(topBarView)
        
        backImage = UIImage(named: "Back")
        backButton = UIButton()
        backButton.setImage(backImage, forState: UIControlState.Normal)
        backButton.setImage(backImage, forState: UIControlState.Highlighted)
        topBarView.addSubview(backButton)
        
        topBarTitle = UILabel()
        topBarTitle.text = NSLocalizedString(TOP_BAR_TITLE, comment: TOP_BAR_TITLE)
        topBarTitle.textColor = UIColor.whiteColor()
        topBarTitle.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        topBarView.addSubview(topBarTitle)
        
        hintView = UIView()
        hintView.contentMode = .Center
        self.addSubview(hintView)
        
        hintText = UILabel()
        hintText.numberOfLines = 0
        hintText.textAlignment = NSTextAlignment.Center
        hintText.text = NSLocalizedString(HINT_TEXT, comment: HINT_TEXT)
        hintText.textColor = UIColor.whiteColor()
        hintText.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)
        hintView.addSubview(hintText)
        
        mobileNumberView = UIView()
        mobileNumberView.contentMode = .Center
        mobileNumberView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)
        self.addSubview(mobileNumberView)
        
        phoneImageView = UIImageView(image: UIImage(named: "Phone"))
        phoneImageView.contentMode = .Center
        mobileNumberView.addSubview(phoneImageView)
        
        
        
        
    }
    
    override func updateConstraints() {
        
        topBarView.mas_updateConstraints { (make) in
            make.top.equalTo()(self).with().offset()(self.MARGIN_TOP)
            make.height.equalTo()(self.TOP_BAR_HEIGHT)
            make.left.equalTo()(self).with().offset()(self.TOP_BAR_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.TOP_BAR_MARGIN_RIGHT)
        }
        
        backButton.mas_updateConstraints { (make) in
            make.left.equalTo()(self.topBarView.mas_left)
            make.centerY.equalTo()(self.topBarView.mas_centerY)
        }
        
        topBarTitle.mas_updateConstraints { (make) in
            make.centerX.equalTo()(self.mas_centerX)
            make.centerY.equalTo()(self.topBarView.mas_centerY)
        }
        
        hintView.mas_updateConstraints { (make) in
            make.height.equalTo()(self.HINT_VIEW_HEIGHT)
            make.top.equalTo()(self.topBarView.mas_bottom)
            make.left.equalTo()(self).with().offset()(self.HINT_VIEW_MARGIN_LEFT)
            make.right.equalTo()(self).with().offset()(-self.HINT_VIEW_MARGIN_RIGHT)
        }
        
        hintText.mas_updateConstraints { (make) in
            make.centerY.equalTo()(self.hintView)
            make.centerX.equalTo()(self.hintView)
        }
        
        mobileNumberView.mas_updateConstraints { (make) in
            make.top.equalTo()(self.hintView.mas_bottom)
            make.height.equalTo()(self.MOBILE_NUMBER_VIEW_HEIGHT)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        phoneImageView.mas_updateConstraints { (make) in
            make.left.equalTo()(self.mobileNumberView).with().offset()(self.MOBILE_NUMBER_MARGIN_LEFT)
            make.centerY.equalTo()(self.mobileNumberView)
            make.width.equalTo()(self.phoneImageView.image?.size.width)
        }
        
        super.updateConstraints()
    }

    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}