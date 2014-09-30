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

class ForgotPasswordView : UIView {
    
    var delegate: ForgotPasswordViewDelegate?
    
    private let MARGIN_TOP:CGFloat = 25.0
    
    private var navigationBar: CustomNavigationBar!
    private var enterMobileNumberLabel: UILabel!
    private var mobileNumberTextField: UITextField!
    
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func viewDidLoad() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func addSubviews() {
        
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar("Forgot Password", showBackButton: true)
        //navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        enterMobileNumberLabel = UILabel()
        enterMobileNumberLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h7)
        enterMobileNumberLabel.text = "Enter your phone number below to reset your password"
        enterMobileNumberLabel.textColor = UIColor.whiteColor()
        self.addSubview(enterMobileNumberLabel)
        
    }
    
    func makeConstraints() {
        
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        enterMobileNumberLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.top.equalTo()(self.navigationBar.mas_bottom).with().offset()(self.MARGIN_TOP)
        }
        
        super.updateConstraints()
    }
    
    
    // MARK: - Buttons delegate
    func finishTypingMobileNumber(sender: AnyObject?) {
        self.delegate?.forgotPasswordViewDidFinishTypingMobileNumber(self)
    }
    
    
    // MARK: - Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
