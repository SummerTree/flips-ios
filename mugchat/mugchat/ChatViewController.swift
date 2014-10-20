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

class ChatViewController: MugChatViewController, ChatViewDelegate {
    
    var chatView: ChatView!
    var chatTitle: String!
    
    init(chatTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = chatTitle
    }
    
    override func loadView() {
        self.chatView = ChatView()
        self.chatView.delegate = self
        self.view = chatView
        
        self.setupWhiteNavBarWithBackButton(chatTitle)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.chatView.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.chatView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }

    
    // MARK: - Delegate methods
    
    func chatViewDidTapBackButton(view: ChatView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func chatView(view: ChatView, didTapNextButtonWithWords words : [String]) {
        var composeViewController = ComposeViewController(words: words)
        self.navigationController?.pushViewController(composeViewController, animated: true)
    }
   
    
    // MARK: - Required initializers
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}