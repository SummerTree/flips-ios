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

class InboxViewController : MugChatViewController, InboxViewDelegate {
    
    // MARK: - UIViewController overridden methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.initInboxView()
    }
    
    
    //MARK: - Private methods
    
    private func initInboxView() {
        var inboxView = InboxView()
        inboxView.delegate = self
        self.view.addSubview(inboxView)
        
        inboxView.mas_makeConstraints { (maker) -> Void in
            maker.top.equalTo()(self.view)
            maker.bottom.equalTo()(self.view)
            maker.leading.equalTo()(self.view)
            maker.trailing.equalTo()(self.view)
        }
    }
    
    
    // MARK: - InboxViewDelegate
    
    func inboxViewDidTapComposeButton(inboxView : InboxView) {
        self.navigationController?.pushViewController(ComposeViewController(), animated: true)
    }
    
    func inboxViewDidTapSettingsButton(inboxView : InboxView) {
        var settingsViewController = SettingsViewController()
        var navigationController = UINavigationController(rootViewController: settingsViewController)
        
        settingsViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxViewDidTapBuilderButton(inboxView : InboxView) {
        var builderViewController = BuilderViewController()
        var navigationController = UINavigationController(rootViewController: builderViewController)
        
        builderViewController.modalPresentationStyle = UIModalPresentationStyle.PageSheet;
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func inboxView(inboxView : InboxView, didTapAtItemAtIndex index: Int) {
        println("tap at cell \(index)")
        self.navigationController?.pushViewController(ChatViewController(chatTitle: "MugBoys"), animated: true)
    }
}

