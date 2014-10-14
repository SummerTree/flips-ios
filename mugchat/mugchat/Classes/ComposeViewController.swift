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

class ComposeViewController : MugChatViewController, ComposeViewDelegate {
    
    private let composeView = ComposeView()
    
    override func loadView() {
        composeView.delegate = self
        self.view = composeView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.setupWhiteNavBarWithBackButton(NSLocalizedString("MugChat", comment: "MugChat"))
        
        var previewBarButton = UIBarButtonItem(title: NSLocalizedString("Preview", comment: "Preview"), style: .Done, target: self, action: "previewButtonTapped:")
        previewBarButton.tintColor = UIColor.orangeColor()
        self.navigationItem.rightBarButtonItem = previewBarButton
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.composeView.viewDidLoad()
    }
    
    
    // MARK: - Bar Buttons
    
    func previewButtonTapped(sender: AnyObject?) {
        println("Preview button tapped")
    }
    
    
    // MARK: - ComposeViewDelegate Methods
    
    func composeViewDidTapBackButton(composeView: ComposeView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func composeViewDidTapGalleryButton(composeView: ComposeView!) {
        println("Gallery button tapped")
    }
    
    func composeViewDidTapTakePictureButton(composeView: ComposeView!) {
        println("Take picture button tapped")
    }
    
    func composeViewMakeConstraintToNavigationBarBottom(composeView: UIView!) {
        // using Mansory strategy
        // check here: https://github.com/Masonry/Masonry/issues/27
        composeView.mas_makeConstraints { (make) -> Void in
            var topLayoutGuide: UIView = self.topLayoutGuide as AnyObject! as UIView
            make.top.equalTo()(topLayoutGuide.mas_bottom)
        }
    }
}