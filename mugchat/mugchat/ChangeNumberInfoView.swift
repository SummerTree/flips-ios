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

class ChangeNumberInfoView: UIView {
    
    var delegate: ChangeNumberInfoViewDelegate?
    
    private let TRANSITION_CIRCLES_MARGIN: CGFloat = 25.0
    
    private var phonesContainer:            UIView!
    private var oldPhoneImageView:          UIImageView!
    private var transitionCircleImageView:  UIImageView!
    private var newPhoneImageView:          UIImageView!
    private var descriptionLabel:           UILabel!
    private var nextButton:                 UIButton!
    
    override init() {
        super.init()
        
        addSubviews()
        makeConstraints()
    }

    func addSubviews() {
        self.backgroundColor = UIColor.whiteColor()
        
        self.phonesContainer = UIView()
        self.addSubview(phonesContainer)
        
        self.oldPhoneImageView = UIImageView(image: UIImage(named: "OldPhone"))
        self.oldPhoneImageView.sizeToFit()
        self.phonesContainer.addSubview(oldPhoneImageView)
        
        self.transitionCircleImageView = UIImageView(image: UIImage(named: "TransitionCircles"))
        self.transitionCircleImageView.sizeToFit()
        self.phonesContainer.addSubview(transitionCircleImageView)
        
        self.newPhoneImageView = UIImageView(image: UIImage(named: "NewPhone"))
        self.newPhoneImageView.sizeToFit()
        self.phonesContainer.addSubview(newPhoneImageView)
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h3)
        self.descriptionLabel.numberOfLines = 3
        self.descriptionLabel.text = "Changing your number will transfer\nyour account info, groups and settings\nto the new number."
        self.descriptionLabel.textAlignment = NSTextAlignment.Center
        self.descriptionLabel.textColor = UIColor.deepSea()
        self.descriptionLabel.sizeToFit()
        self.addSubview(descriptionLabel)
        
        self.nextButton = UIButton()
        self.nextButton.setBackgroundImage(UIImage(named: "NextButtonNormal"), forState: UIControlState.Normal)
        self.nextButton.setBackgroundImage(UIImage(named: "NextButtonTapped"), forState: UIControlState.Highlighted)
        self.nextButton.addTarget(self, action: "nextButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.nextButton.setTitle(NSLocalizedString("Next", comment: "Next"), forState: UIControlState.Normal)
        self.addSubview(nextButton)
    }
    
    func makeConstraints() {
        phonesContainer.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.descriptionLabel.mas_top).with().offset()(-59)
            make.height.equalTo()(self.newPhoneImageView.frame.size.height)
        }
        
        transitionCircleImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.oldPhoneImageView.mas_centerY)
            make.centerX.equalTo()(self)
            make.height.equalTo()(self.transitionCircleImageView.frame.size.height)
            make.width.equalTo()(self.transitionCircleImageView.frame.size.width)
        }
        
        oldPhoneImageView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.phonesContainer)
            make.right.equalTo()(self.transitionCircleImageView.mas_left).with().offset()(-self.TRANSITION_CIRCLES_MARGIN)
            make.height.equalTo()(self.oldPhoneImageView.frame.size.height)
            make.width.equalTo()(self.oldPhoneImageView.frame.size.width)
        }
        
        newPhoneImageView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.phonesContainer)
            make.left.equalTo()(self.transitionCircleImageView.mas_right).with().offset()(self.TRANSITION_CIRCLES_MARGIN)
            make.height.equalTo()(self.newPhoneImageView.frame.size.height)
            make.width.equalTo()(self.newPhoneImageView.frame.size.width)
        }
        
        descriptionLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mas_centerY)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.descriptionLabel.frame.size.height)
        }
        
        nextButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.descriptionLabel.mas_bottom).with().offset()(59)
            make.centerX.equalTo()(self)
        }
    }
    
    
    // MARK: - Action buttons
    
    func nextButtonTapped(button: UIButton!) {
        self.delegate?.changeNumberInfoViewDidTapNextButton(self)
    }
    
    
    // MARK: - Required inits
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

protocol ChangeNumberInfoViewDelegate {
    func changeNumberInfoViewDidTapNextButton(changeNumberInfoView: ChangeNumberInfoView!)
}