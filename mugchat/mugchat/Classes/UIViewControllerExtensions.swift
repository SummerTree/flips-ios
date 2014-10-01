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
import UIKit

extension UIViewController {
    
    // MARK: - Public Methods
    
    func setupWhiteNavBarWithCloseButton(title: String) {
        self.setNavBarColor()
        
        var titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        var closeBarButton = UIBarButtonItem(image: UIImage(named: "Cancel") , style: .Done, target: self, action: "closeButtonTapped")
        closeBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = closeBarButton
    }
    
    func setupWhiteNavBarWithBackButton(title: String) {
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.alpha = 0.9
        
        var titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        var backBarButton = UIBarButtonItem(image: UIImage(named: "Back_Orange") , style: .Done, target: self, action: "backButtonTapped")
        backBarButton.tintColor = UIColor.orangeColor()
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    func setupOrangeNavBarWithBackButton(title: String) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        var titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h2)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        var backBarButton = UIBarButtonItem(image: UIImage(named: "Back") , style: .Done, target: self, action: "backButtonTapped")
        backBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = backBarButton
    }

    func setupRedNavBar(centerThumbnailImage: String, showSettingsButton: Bool, showBuilderButton: Bool) {
        self.setNavBarColor()
        
        if (showSettingsButton) {
            var settingsBarButton = UIBarButtonItem(image: UIImage(named: "Settings") , style: .Plain, target: self, action: "settingsButtonTapped")
            settingsBarButton.tintColor = UIColor.whiteColor()
            self.navigationItem.leftBarButtonItem = settingsBarButton
        }

        if (showBuilderButton) {
            var builderBarButton = UIBarButtonItem(image: UIImage(named: "Builder") , style: .Plain, target: self, action: "buildButtonTapped")
            builderBarButton.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem = builderBarButton
        }
        
        var containerView = UIView()
        containerView.backgroundColor = UIColor.clearColor()
        var loggedUserImageView = UIImageView.avatarA4()
        loggedUserImageView.image = UIImage(named: centerThumbnailImage)
        containerView.addSubview(loggedUserImageView)
        
        loggedUserImageView.center = containerView.center
        
        self.navigationItem.titleView = containerView
    }
    
    
    // MARK: - Nav Button Actions
    
    func settingsButtonTapped() {
        println("settingsButtonTapped")
        
        var settingsViewController = SettingsViewController()
        var navigationController = UINavigationController(rootViewController: settingsViewController)
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func buildButtonTapped() {
        println("buildButtonTapped")
        
        var builderViewController = BuilderViewController()
        var navigationController = UINavigationController(rootViewController: builderViewController)
        
        builderViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func closeButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backButtonTapped() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Private Methods
    
    private func setNavBarColor() {
        self.navigationController?.navigationBar.barTintColor = UIColor.mugOrange()
        self.navigationController?.navigationBar.alpha = 0.9
    }
}