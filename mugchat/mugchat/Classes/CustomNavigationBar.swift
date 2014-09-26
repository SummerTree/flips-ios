//
//  CustomNavigationBar.swift
//  mugchat
//
//  Created by Bruno Bruggemann on 9/26/14.
//  Copyright (c) 2014 ArcTouch Inc. All rights reserved.
//


/*
 *
 *  DON'T REVIEW. CLASS NOT FINISHED AND NOT BEING USED YET.
 *
 */

//import Foundation
//
//private let STATUS_BAR_HEIGHT = UIApplication.sharedApplication().statusBarFrame.size.height
//private let RED_NAV_BAR_TOTAL_HEIGHT : CGFloat = 74.0
//
//class CustomNavigationBar : UIView {
//
//    private var leftButton : UIBarButtonItem!
//    private var titleView : UIView!
//    private var rightButton : UIButton!
//    
//    class func CustomNavigationBarRed(avatarImage : UIImage, showSettingsButton : Bool, showBuiderButton : Bool) -> CustomNavigationBar {
//        var navBarFrame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), RED_NAV_BAR_TOTAL_HEIGHT)
//        
//        var navigationBar = CustomNavigationBar(frame: navBarFrame)
//        var toolBar = UIToolbar(frame: navBarFrame)
//        toolBar.translucent = true
//        
//        navigationBar.addSubview(toolBar)
//        navigationBar.backgroundColor = UIColor.mugOrange()
//        
//        if (showSettingsButton) {
//            var settingsBarButton = UIBarButtonItem(image: UIImage(named: "Settings") , style: .Plain, target: self, action: "settingsButtonTapped")
//            settingsBarButton.tintColor = UIColor.whiteColor()
//            navigationBar.leftButton = settingsBarButton
////            self.navigationItem.leftBarButtonItem = settingsBarButton
//        }
//        
////        if (showBuilderButton) {
////            var builderBarButton = UIBarButtonItem(image: UIImage(named: "Builder") , style: .Plain, target: self, action: "buildButtonTapped")
////            builderBarButton.tintColor = UIColor.whiteColor()
////            self.navigationItem.rightBarButtonItem = builderBarButton
////        }
//        
////        var containerView = UIView()
////        containerView.backgroundColor = UIColor.clearColor()
////        var loggedUserImageView = UIImageView.avatarA4()
////        loggedUserImageView.image = UIImage(named: centerThumbnailImage)
////        containerView.addSubview(loggedUserImageView)
////        
////        loggedUserImageView.center = containerView.center
////        
////        self.navigationItem.titleView = containerView
//
//        
//        return navigationBar
//    }
//
//    // MARK: - Init Methods
//    
//    convenience override init() {
//        self.init(frame: CGRect.zeroRect)
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//
//}