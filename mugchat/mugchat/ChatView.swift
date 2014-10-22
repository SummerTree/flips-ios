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

class ChatView: UIView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var mugs = [
        MugVideo(message: "Welcome to MugChat", videoPath: "welcome_mugchat", timestamp: "8:23 am", avatarPath: "tmp_homer", thumbnailPath: "movie_thumbnail.png", received: false),
        MugVideo(message: "Bollywood!!!", videoPath: "bollywood", timestamp: "8:24 am", avatarPath: "tmp_homer", thumbnailPath: "bollywood_thumbnail.jpeg", received: false),
        MugVideo(message: "Wanna coffee?", videoPath: "wanna_coffee", timestamp: "8:25 am", avatarPath: "tmp_homer", thumbnailPath: "coffee_thumbnail.jpeg", received: false)
    ]
    
    var oldestUnreadMessageIndex = 2
    
    private let CELL_IDENTIFIER = "mugChatCell"
    private let REPLY_BUTTON_TOP_MARGIN : CGFloat = 18.0
    private let REPLY_VIEW_OFFSET : CGFloat = 18.0
    private let REPLY_BUTTON_HEIGHT : CGFloat = 64.0
    private let HORIZONTAL_RULER_HEIGHT : CGFloat = 1.0
    
    private let CELL_MUG_AREA_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.width
    private let CELL_MUG_TEXT_AREA_HEIGHT: CGFloat = 62
    
    private let THUMBNAIL_FADE_DURATION: NSTimeInterval = 0.2
    
    var delegate: ChatViewController!
    var tableView: UITableView!
    var separatorView: UIView!
    var darkHorizontalRulerView: UIView!
    var replyView: UIView!
    var replyButton: UIButton!
    var replyTextField: JoinStringsTextField!
    var nextButton: UIButton!
    
    var shouldPlayUnreadMessage: Bool = true
    var keyboardHeight: CGFloat = 0.0
    var words: [String] = []
    
    
    // MARK: - Required initializers
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.makeConstraints()
        let indexPath = NSIndexPath(forRow: oldestUnreadMessageIndex, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Layout
    
    func addSubviews() {
        tableView = UITableView(frame: self.frame, style: .Plain)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.contentOffset = CGPointMake(0, 0)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        self.addSubview(tableView)
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.whiteColor()
        self.addSubview(separatorView)
        
        darkHorizontalRulerView = UIView()
        darkHorizontalRulerView.backgroundColor = UIColor.grayColor()
        self.addSubview(darkHorizontalRulerView)
        
        replyView = UIView()
        replyView.backgroundColor = UIColor.whiteColor()
        self.addSubview(replyView)

        replyButton = UIButton()
        replyButton.contentMode = .Center
        replyButton.backgroundColor = UIColor.whiteColor()
        replyButton.contentEdgeInsets = UIEdgeInsetsMake(REPLY_VIEW_OFFSET / 2, REPLY_VIEW_OFFSET * 2, REPLY_VIEW_OFFSET / 2, REPLY_VIEW_OFFSET * 2)
        replyButton.addTarget(self, action: "didTapReplyButton", forControlEvents: UIControlEvents.TouchUpInside)
        replyButton.setImage(UIImage(named: "Reply"), forState: UIControlState.Normal)
        replyButton.sizeToFit()
        replyView.addSubview(replyButton)
        
        replyTextField = JoinStringsTextField()
        replyTextField.hidden = true
        replyTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Type your message here", comment: "Type your message here"), attributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h4)])
        replyView.addSubview(replyTextField)
        
        nextButton = UIButton()
        nextButton.contentEdgeInsets = UIEdgeInsetsMake(REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET)
        nextButton.hidden = true
        nextButton.addTarget(self, action: "didTapNextButton", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.setAttributedTitle(NSAttributedString(string:NSLocalizedString("Next", comment: "Next"), attributes:[NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.avenirNextDemiBold(UIFont.HeadingSize.h4)]), forState: UIControlState.Normal)
        nextButton.sizeToFit()
        replyView.addSubview(nextButton)
        
    }
    
    func makeConstraints() {
        
        tableView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.separatorView.mas_top)
        })
        
        separatorView.mas_makeConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.REPLY_BUTTON_TOP_MARGIN)
            make.bottom.equalTo()(self.darkHorizontalRulerView.mas_top)
        })
        
        darkHorizontalRulerView.mas_makeConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.HORIZONTAL_RULER_HEIGHT)
            make.bottom.equalTo()(self.replyView.mas_top)
        })
        
        replyView.mas_makeConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.REPLY_BUTTON_HEIGHT)
            make.bottom.equalTo()(self)
        })

        replyButton.mas_makeConstraints( { (make) in
            make.centerX.equalTo()(self.replyView)
            make.centerY.equalTo()(self.replyView)
        })
        
        replyTextField.mas_makeConstraints( { (make) in
            make.left.equalTo()(self.replyView).with().offset()(self.REPLY_VIEW_OFFSET)
            make.right.equalTo()(self.nextButton.mas_left).with().offset()(-self.REPLY_VIEW_OFFSET)
            make.top.equalTo()(self.replyView)
            make.bottom.equalTo()(self.replyView)
        })
        
        nextButton.mas_makeConstraints( { (make) in
            make.right.equalTo()(self.replyView)
            make.top.equalTo()(self.replyView)
            make.bottom.equalTo()(self.replyView)
            make.width.equalTo()(self.nextButton.frame.width)
        })
        
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.chatViewDidTapBackButton(self)
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_MUG_AREA_HEIGHT + CELL_MUG_TEXT_AREA_HEIGHT
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
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let visibleCells = (scrollView.superview as ChatView).tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            if (self.isCell(cell, totallyVisibleInScrollView: scrollView)) {
                if (self.shouldPlayUnreadMessage) {
                    self.shouldPlayUnreadMessage = false
                    cell.player.prepareToPlay()
                    UIView.animateWithDuration(self.THUMBNAIL_FADE_DURATION,
                        delay: 0.5,
                        options: nil,
                        animations: { () -> Void in
                            cell.thumbnailView.alpha = 0.0
                        },
                        completion: { (animationsFinished) -> Void in
                            cell.player.play()
                    })
                }
            } else {
                cell.player.stop()
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (!decelerate) {
                self.playVideoForVisibleCellOnScrollView(scrollView)
            }
        })
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.playVideoForVisibleCellOnScrollView(scrollView)
        })
    }
    
    func isCell(cell: ChatTableViewCell, totallyVisibleInScrollView aScrollView: UIScrollView) -> Bool {
        var thumbnailRect = cell.convertRect(cell.thumbnailView.frame, toView: cell.superview)
        thumbnailRect.origin.y = thumbnailRect.origin.y + (thumbnailRect.height - CELL_MUG_TEXT_AREA_HEIGHT)
        let convertedRect = aScrollView.convertRect(thumbnailRect, toView: aScrollView.superview)
        if (CGRectContainsRect(aScrollView.frame, convertedRect)) {
            return true
        } else {
            return false
        }
    }
    
    private func playVideoForVisibleCellOnScrollView(scrollView: UIScrollView) {
        let visibleCells = (scrollView.superview as ChatView).tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            if (self.isCell(cell, totallyVisibleInScrollView: scrollView)) {
                cell.player.prepareToPlay()
                UIView.animateWithDuration(self.THUMBNAIL_FADE_DURATION,
                    delay: 0.5,
                    options: nil,
                    animations: { () -> Void in
                        cell.thumbnailView.alpha = 0.0
                    },
                    completion: { (animationsFinished) -> Void in
                        cell.player.play()
                })
            } else {
                cell.player.stop()
            }
        }
    }
    
    
    // MARK: - Button Handlers
    
    func didTapReplyButton() {
        hideReplyButtonAndShowTextField()
        self.replyTextField.becomeFirstResponder()
    }

    func didTapNextButton() {
        self.words = replyTextField.getMugTexts()
        self.delegate?.chatView(self, didTapNextButtonWithWords: words)
    }
    
    private func hideReplyButtonAndShowTextField() {
        self.replyButton.hidden = true
        self.replyTextField.hidden = false
        self.nextButton.hidden = false
    }
    
    private func hideTextFieldAndShowReplyButton() {
        self.replyButton.hidden = false
        self.replyTextField.hidden = true
        self.nextButton.hidden = true
    }
    

    // MARK: - Notifications
    
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        keyboardHeight = keyboardFrame.height as CGFloat
        let indexPath = NSIndexPath(forRow: mugs.count - 1, inSection: 0)
        self.frame.size.height -= keyboardHeight
        super.updateConstraints()
        self.layoutIfNeeded()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    
    // MARK: - View Events
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        let visibleCells = tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            cell.viewWillDisappear()
        }
    }
    

}

protocol ChatViewDelegate {
    
    func chatViewDidTapBackButton(view: ChatView)
    
}
