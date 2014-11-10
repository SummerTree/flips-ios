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

class ChangeNumberViewController : MugChatViewController, ChangeNumberViewDelegate {
    
    private var changeNumberView: ChangeNumberView!
    
    override func loadView() {
        changeNumberView = ChangeNumberView()
        changeNumberView.delegate = self
        
        self.view = changeNumberView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWhiteNavBarWithBackButton("Change Number")
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    // MARK: - ChangeNumberViewDelegate
    
    func changeNumberViewDidTapNextButton(changeNumberView: ChangeNumberView!) {
        println("next button tapped")
    }
}