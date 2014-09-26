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

class InboxViewController : UIViewController {
    
    // MARK: - Init methods

    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - UIViewController overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupRedNavBar("tmp_homer", showSettingsButton: true, showBuilderButton: true) // TODO: change it to logged user thumnail
        
        self.initInboxView()
    }
    
    
    //MARK: - Private methods
    
    private func initInboxView() {
        var inboxView = InboxView()
        self.view.addSubview(inboxView)
        
        inboxView.mas_makeConstraints { (maker) -> Void in
            maker.top.equalTo()(self.view)
            maker.bottom.equalTo()(self.view)
            maker.leading.equalTo()(self.view)
            maker.trailing.equalTo()(self.view)
        }
    }
}

