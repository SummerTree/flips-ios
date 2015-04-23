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

class TutorialViewController : UIPageViewController {

    var viewDelegate: TutorialViewControllerDelegate?
    private var pagesDataSource: TutorialPagesDataSource?
    private var tintColor: UIColor? = nil

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.flipOrangeBackground()

        self.pagesDataSource = TutorialPagesDataSource() // We need a strong reference to this guy
        self.dataSource = self.pagesDataSource

        let initialViewController = (self.dataSource! as TutorialPagesDataSource).viewControllerForPage(0)!
        self.setViewControllers([initialViewController], direction: .Forward, animated: false, completion: nil)

        self.setupNavigationBar()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.tintColor = self.tintColor
    }

    func setupNavigationBar() {
        self.tintColor = self.navigationController?.navigationBar.tintColor
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        self.navigationItem.titleView = nil

        var closeBarButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "closeButtonTapped")
        closeBarButton.setTitleTextAttributes([NSFontAttributeName: UIFont.avenirNextRegular(UIFont.HeadingSize.h4)], forState: .Normal)
        closeBarButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = closeBarButton
        self.navigationItem.hidesBackButton = true
    }

    override func closeButtonTapped() {
        self.viewDelegate?.tutorialViewControllerDidTapCloseButton(self);
        
        var currentPage = self.viewControllers.first as TutorialPageViewController
        AnalyticsService.logOnboardingSkipped(currentPage.pageIndex)
    }

}

// MARK: - TutorialViewControllerDelegate Protocol

protocol TutorialViewControllerDelegate: class {

    func tutorialViewControllerDidTapCloseButton(viewController: TutorialViewController!)

}
