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

class ChangeNumberInputPhoneView: UIView {
    
    var delegate: ChangeNumberInputPhoneViewDelegate?
    
    private let ENTER_NUMBER_BELOW_CONTAINER_HEIGHT:    CGFloat = 109.0
    private let NEW_NUMBER_CONTAINER_HEIGHT:            CGFloat = 80.0
    private let NEW_NUMBER_IMAGE_MARGIN:                CGFloat = 20.0
    
    private var enterNumberBelowContainer: UIView!
    private var enterNumberBelowLabel:  UILabel!
    private var currentNumberContainer: UIView!
    private var currentNumberLabel:     UILabel!
    private var newNumberContainerView: UIView!
    private var newNumberTextField:     UITextField!
    private var newNumberImageView:     UIImageView!
    
    override init() {
        super.init()
        
        addSubviews()
    }
    
    func viewDidLoad() {
        makeConstraints()
        
        self.newNumberTextField.becomeFirstResponder()
    }
    
    func addSubviews() {
        self.backgroundColor = UIColor.whiteColor()
        
        self.enterNumberBelowContainer = UIView()
        self.addSubview(enterNumberBelowContainer)

        self.enterNumberBelowLabel = UILabel()
        self.enterNumberBelowLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h3)
        self.enterNumberBelowLabel.numberOfLines = 2
        self.enterNumberBelowLabel.text = "Please enter the new\nnumber below"
        self.enterNumberBelowLabel.textAlignment = NSTextAlignment.Center
        self.enterNumberBelowLabel.textColor = UIColor.mediumGray()
        self.enterNumberBelowLabel.sizeToFit()
        self.enterNumberBelowContainer.addSubview(enterNumberBelowLabel)
        
        self.newNumberContainerView = UIView()
        self.newNumberContainerView.backgroundColor = UIColor.deepSea()
        self.addSubview(newNumberContainerView)
        
        self.newNumberTextField = UITextField()
        self.newNumberTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("New Number", comment: "New Number"), attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        self.newNumberTextField.keyboardType = UIKeyboardType.PhonePad
        self.newNumberTextField.textColor = UIColor.whiteColor()
        self.newNumberContainerView.addSubview(newNumberTextField)
        
        self.newNumberImageView = UIImageView(image: UIImage(named: "AddNumber"))
        self.newNumberImageView.sizeToFit()
        self.newNumberContainerView.addSubview(newNumberImageView)
        
        self.currentNumberContainer = UIView()
        self.addSubview(currentNumberContainer)
        
        self.currentNumberLabel = UILabel()
        self.currentNumberLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        self.currentNumberLabel.numberOfLines = 2
        self.currentNumberLabel.text = "Current number for this account is\n415-123-4567"
        self.currentNumberLabel.textAlignment = NSTextAlignment.Center
        self.currentNumberLabel.textColor = UIColor.mediumGray()
        self.currentNumberLabel.sizeToFit()
        self.currentNumberContainer.addSubview(currentNumberLabel)
    }
    
    func makeConstraints() {
        
        enterNumberBelowContainer.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.centerX.equalTo()(self)
            make.height.equalTo()(self.ENTER_NUMBER_BELOW_CONTAINER_HEIGHT)
        }
        
        // ask to delegate create constraint related to navigation bar
        self.delegate?.makeConstraintToNavigationBarBottom(enterNumberBelowContainer)
        
        enterNumberBelowLabel.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self.enterNumberBelowContainer)
            make.height.equalTo()(self.enterNumberBelowLabel.frame.size.height)
            make.width.equalTo()(self.enterNumberBelowLabel.frame.size.width)
        }
        
        newNumberContainerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.enterNumberBelowContainer.mas_bottom)
            make.left.equalTo()(self.enterNumberBelowContainer)
            make.right.equalTo()(self.enterNumberBelowContainer)
            make.height.equalTo()(self.NEW_NUMBER_CONTAINER_HEIGHT)
        }
        
        newNumberImageView.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.newNumberContainerView)
            make.left.equalTo()(self).with().offset()(self.NEW_NUMBER_IMAGE_MARGIN)
            make.width.equalTo()(self.newNumberImageView.frame.size.width)
            make.height.equalTo()(self.newNumberImageView.frame.size.height)
        }
        
        newNumberTextField.mas_makeConstraints { (make) -> Void in
            make.centerY.equalTo()(self.newNumberContainerView)
            make.left.equalTo()(self.newNumberImageView.mas_right).with().offset()(self.NEW_NUMBER_IMAGE_MARGIN)
            make.right.equalTo()(self.newNumberContainerView)
            make.height.equalTo()(self.newNumberContainerView)
        }
        
        currentNumberContainer.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.newNumberContainerView.mas_bottom)
            make.height.equalTo()(self.enterNumberBelowContainer)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
        
        currentNumberLabel.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self.currentNumberContainer)
            make.height.equalTo()(self.currentNumberLabel.frame.size.height)
            make.width.equalTo()(self.currentNumberLabel.frame.size.width)
        }
    }
    
    
    // MARK: - Required inits
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

protocol ChangeNumberInputPhoneViewDelegate {
    func makeConstraintToNavigationBarBottom(view: UIView!)
}