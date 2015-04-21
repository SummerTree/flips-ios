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

class TutorialViewController : FlipsViewController, TutorialViewDelegate {
    
    private var tutorialView: TutorialView!
    
    override func loadView() {
        tutorialView = TutorialView()
        tutorialView.delegate = self
        
        self.view = tutorialView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tutorialView.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tutorialView.viewWillAppear()
    }
    
    // MARK: - TutorialViewDelegate
    
    func tutorialViewDidTapBackButton(tutorialView: TutorialView!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}