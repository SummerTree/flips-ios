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

class ChatViewController: MugChatViewController, ChatViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var mugs = [
        MugVideo(message: "Welcome to MugChat 1", videoPath: "welcome_mugchat", timestamp: "8:23 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 2", videoPath: "welcome_mugchat", timestamp: "8:24 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 3", videoPath: "welcome_mugchat", timestamp: "8:25 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 4", videoPath: "welcome_mugchat", timestamp: "8:26 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 5", videoPath: "welcome_mugchat", timestamp: "8:27 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 6", videoPath: "welcome_mugchat", timestamp: "8:28 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 7", videoPath: "welcome_mugchat", timestamp: "8:29 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 8", videoPath: "welcome_mugchat", timestamp: "8:30 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 9", videoPath: "welcome_mugchat", timestamp: "8:31 am", avatarPath: "tmp_homer", received: false),
        MugVideo(message: "Welcome to MugChat 10", videoPath: "welcome_mugchat", timestamp: "8:32 am", avatarPath: "tmp_homer", received: false)
    ]

    private let CELL_IDENTIFIER = "mugCell"
    
    var chatView: ChatView!
    var chatTitle: String!
    
    init(chatTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = chatTitle
        self.chatView = ChatView()
        self.setupWhiteNavBarWithBackButton(chatTitle)
        self.setNeedsStatusBarAppearanceUpdate()
        self.view = chatView
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }

    
    // MARK: - Delegate methods
    
    func chatViewDidTapBackButton(view: ChatView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ChatTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell
        cell.message = mugs[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mugs.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return NSLocalizedString("Delete", comment: "Delete")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            mugs.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        var size = CGSizeMake(CGRectGetWidth(self.navigationController?.navigationBar.frame), CGRectGetHeight(self.navigationController?.navigationBar.frame))
//        navigationBar.setBackgroundImage(tableView.getImageWithSize(size))
//    }
    
    
    // MARK: - Required initializers
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
}