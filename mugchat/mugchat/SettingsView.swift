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

class SettingsView: UIView {
    
    private let logoutButton = UIButton()
    
    var delegate: SettingsViewDelegate?
    
    override init() {
        super.init()
        
        self.addSubviews()
        self.makeConstraints()
    }
    
    private func addSubviews() {
        
        self.backgroundColor = UIColor.whiteColor()
        
        logoutButton.addTarget(self, action: "logOutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.layer.borderWidth = 0.5
        logoutButton.layer.borderColor = UIColor.grayColor().CGColor
        logoutButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        logoutButton.setTitleColor(UIColor.mugOrange(), forState: UIControlState.Normal)
        logoutButton.setTitle(NSLocalizedString("Log Out", comment: "Log Out"), forState: UIControlState.Normal)
        self.addSubview(logoutButton)
    }
    
    private func makeConstraints() {
        logoutButton.mas_makeConstraints { (make) -> Void in
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
            make.height.equalTo()(92)
        }
    }
    
    func logOutButtonTapped(sender: AnyObject?) {
        self.delegate?.settingsViewDidTapLogOutButton(self)
    }
    
    
    // MARK: - Required inits

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

protocol SettingsViewDelegate {
    func settingsViewDidTapLogOutButton(settingsView: SettingsView)
}