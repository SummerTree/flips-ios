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


class BuilderViewController : ComposeViewController, BuilderIntroductionViewControllerDelegate {
    
    private var builderIntroductionViewController: BuilderIntroductionViewController!
    

    // MARK: - Overriden Methods
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (!DeviceHelper.sharedInstance.didUserAlreadySeeBuildIntroduction()) {
            DeviceHelper.sharedInstance.setBuilderIntroductionShown(true)
            self.showIntroduction()
        }
    }
    
    override func shouldShowPreviewButton() -> Bool {
        return false
    }
    
    override func canShowMyFlips() -> Bool {
        return false
    }
    
    override func shouldShowPlusButtonInWords() -> Bool {
        return true
    }
    
    
    // MARK: - Builder Introduction Methods
    
    func showIntroduction() {
        builderIntroductionViewController = BuilderIntroductionViewController(viewBackground: self.view.snapshot())
        builderIntroductionViewController.view.alpha = 0.0
        builderIntroductionViewController.delegate = self
        self.view.addSubview(builderIntroductionViewController.view)
        self.addChildViewController(builderIntroductionViewController)
        
        self.builderIntroductionViewController.view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
        }
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.navigationController?.navigationBar.alpha = 0.001
            self.builderIntroductionViewController.view.alpha = 1.0
        })
    }
    
    func builderIntroductionViewControllerDidTapOkSweetButton(builderIntroductionViewController: BuilderIntroductionViewController!) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.navigationController?.navigationBar.alpha = 1.0
            self.builderIntroductionViewController.view.alpha = 0.0
        }) { (completed) -> Void in
            self.view.sendSubviewToBack(self.builderIntroductionViewController.view)
        }
    }
    
    
    // MARK: - FlipMessageWordListView Delegate
    
    override func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView) {
        println("flipMessageWordListViewDidTapAddWordButton")
    }

}