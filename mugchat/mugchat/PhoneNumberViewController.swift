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

class PhoneNumberViewController: UIViewController {
    
    var phoneNumberView: PhoneNumberView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //phoneNumberView.viewWillAppear()
        self.navigationController?.navigationBarHidden = true
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        phoneNumberView.viewWillDisappear()
//        self.navigationController?.navigationBarHidden = false
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //phoneNumberView.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberView = PhoneNumberView()
        self.view = phoneNumberView
    }
    
}
