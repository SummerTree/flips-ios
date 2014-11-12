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

class ChatView: UIView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, JoinStringsTextFieldDelegate {
    
    private let CELL_IDENTIFIER = "flipChatCell"
    private let REPLY_VIEW_OFFSET : CGFloat = 18.0
    private let REPLY_BUTTON_HEIGHT : CGFloat = 64.0
    private let REPLY_VIEW_MARGIN : CGFloat = 10.0
    private let TEXT_VIEW_MARGIN : CGFloat = 3.0
    private let HORIZONTAL_RULER_HEIGHT : CGFloat = 1.0
    
    private let CELL_FLIP_AREA_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.width
    private let CELL_FLIP_TEXT_AREA_HEIGHT: CGFloat = 62
    
    private let THUMBNAIL_FADE_DURATION: NSTimeInterval = 0.2
    
    private var tableView: UITableView!
    private var darkHorizontalRulerView: UIView!
    private var replyView: UIView!
    private var replyButton: UIButton!
    private var replyTextField: JoinStringsTextField!
    private var nextButton: UIButton!
    
    private var shouldPlayUnreadMessage: Bool = true
    private var keyboardHeight: CGFloat = 0.0
    
    var delegate: ChatViewDelegate?
    var dataSource : ChatViewDataSource?
    
    
    // MARK: - Required initializers
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.makeConstraints()
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
        replyTextField.joinStringsTextFieldDelegate = self
        replyTextField.hidden = true
        replyTextField.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
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
            make.center.equalTo()(self.replyView)
            return ()
        })
        
        replyTextField.mas_makeConstraints( { (make) in
            make.left.equalTo()(self.replyView).with().offset()(self.REPLY_VIEW_OFFSET)
            make.right.equalTo()(self.nextButton.mas_left).with().offset()(-self.REPLY_VIEW_OFFSET)
            make.centerY.equalTo()(self.replyView)
            make.height.equalTo()(self.getTextHeight())
        })
        
        nextButton.mas_makeConstraints( { (make) in
            make.right.equalTo()(self.replyView)
            make.top.equalTo()(self.replyView)
            make.bottom.equalTo()(self.replyView)
            make.width.equalTo()(self.nextButton.frame.width)
        })
    }
    
    func getTextHeight() -> CGFloat{
        let myString: NSString = self.replyTextField.text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.height * 2 - self.TEXT_VIEW_MARGIN
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.chatViewDidTapBackButton(self)
    }
    
    
    // MARK: - Data Load Methods
    
    func reloadFlipMessages() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell
        
        let flipId = dataSource?.chatView(self, flipMessageIdAtIndex: indexPath.row)
        cell.setFlipMessageId(flipId!)
        
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfMessages = dataSource?.numberOfFlipMessages(self) as Int?
        if (numberOfMessages == nil) {
            numberOfMessages = 0
        }
        
        return numberOfMessages!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_FLIP_AREA_HEIGHT + CELL_FLIP_TEXT_AREA_HEIGHT
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let visibleCells = (scrollView.superview as ChatView).tableView.visibleCells()
//
//        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
//            if (self.isCell(cell, totallyVisibleInScrollView: scrollView)) {
//                var indexPath = self.tableView.indexPathForCell(cell) as NSIndexPath?
//                if (indexPath == nil) {
//                    return
//                }
//                var row = indexPath?.row
//                var shouldAutoPlay: Bool = dataSource!.chatView(self, shouldAutoPlayFlipMessageAtIndex: row!) as Bool
//                if (shouldAutoPlay) {
//                    cell.prepareToPlay()
//                    cell.playMovie()
//                }
//                
//                // AUTO PLAY - OLD VERSION
////                if (self.shouldPlayUnreadMessage) {
////                    self.shouldPlayUnreadMessage = false
////                    cell.player.prepareToPlay()
////                    UIView.animateWithDuration(self.THUMBNAIL_FADE_DURATION,
////                        delay: 0.5,
////                        options: nil,
////                        animations: { () -> Void in
////                            cell.thumbnailView.alpha = 0.0
////                        },
////                        completion: { (animationsFinished) -> Void in
////                            cell.player.play()
////                    })
////                }
//            } else {
//                cell.stopMovie()
//            }
//        }
//    }
//    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            if (!decelerate) {
//                self.playVideoForVisibleCellOnScrollView(scrollView)
//            }
//        })
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.playVideoForVisibleCellOnScrollView(scrollView)
//        })
//    }
//    
//    func isCell(cell: ChatTableViewCell, totallyVisibleInScrollView aScrollView: UIScrollView) -> Bool {
//        var thumbnailRect = cell.convertRect(cell.thumbnailView.frame, toView: cell.superview)
////        var thumbnailRect = cell.convertRect(cell.frame, toView: cell.superview)
//        thumbnailRect.origin.y = thumbnailRect.origin.y + (thumbnailRect.height - CELL_FLIP_TEXT_AREA_HEIGHT)
//        let convertedRect = aScrollView.convertRect(thumbnailRect, toView: aScrollView.superview)
//        if (CGRectContainsRect(aScrollView.frame, convertedRect)) {
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    private func playVideoForVisibleCellOnScrollView(scrollView: UIScrollView) {
//        let visibleCells = (scrollView.superview as ChatView).tableView.visibleCells()
//        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
//            if (self.isCell(cell, totallyVisibleInScrollView: scrollView)) {
//                var indexPath = self.tableView.indexPathForCell(cell) as NSIndexPath?
//                if (indexPath == nil) {
//                    return
//                }
//                var row = indexPath?.row
//                var shouldAutoPlay: Bool = dataSource!.chatView(self, shouldAutoPlayFlipMessageAtIndex: row!) as Bool
//                if (shouldAutoPlay) {
//                    cell.prepareToPlay()
//                    cell.playMovie()
//                }
//                // AUTO PLAY OLD VERSION
////                cell.player.prepareToPlay()
////                UIView.animateWithDuration(self.THUMBNAIL_FADE_DURATION,
////                    delay: 0.5,
////                    options: nil,
////                    animations: { () -> Void in
////                        cell.thumbnailView.alpha = 0.0
////                    },
////                    completion: { (animationsFinished) -> Void in
////                        cell.player.play()
////                })
//            } else {
////                cell.player.stop()
//                cell.stopMovie()
//            }
//        }
//    }
    
    
    // MARK: - Button Handlers
    
    func didTapReplyButton() {
        hideReplyButtonAndShowTextField()
        self.replyTextField.becomeFirstResponder()
    }
    
    func didTapNextButton() {
        self.delegate?.chatView(self, didTapNextButtonWithWords: replyTextField.getMugTexts())
    }
    
    private func hideReplyButtonAndShowTextField() {
        self.replyButton.hidden = true
        self.replyTextField.hidden = false
        self.nextButton.hidden = false
        
        replyView.mas_updateConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.getTextHeight() + self.REPLY_VIEW_MARGIN)
            make.bottom.equalTo()(self)
        })
        self.updateConstraints()
        
        
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
        
        var numberOfMessages = dataSource?.numberOfFlipMessages(self) as Int?
        if (numberOfMessages == nil) {
            numberOfMessages = 0
        }
        
        let indexPath = NSIndexPath(forRow: numberOfMessages! - 1, inSection: 0)
        self.frame.size.height -= keyboardHeight
        super.updateConstraints()
        self.layoutIfNeeded()
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    
    // MARK: - View Events
    
    func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        self.replyTextField.viewWillAppear()
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        let visibleCells = tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            cell.viewWillDisappear()
        }
    }
    
    
    // MARK: JoinStringsTextFieldDelegate delegate
    
    func joinStringsTextFieldNeedsToHaveItsHeightUpdated(joinStringsTextField: JoinStringsTextField!) {
        replyView.mas_updateConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.getTextHeight() + self.REPLY_VIEW_MARGIN)
            make.bottom.equalTo()(self)
        })
        
        replyTextField.mas_updateConstraints( { (make) in
            make.left.equalTo()(self.replyView).with().offset()(self.REPLY_VIEW_OFFSET)
            make.right.equalTo()(self.nextButton.mas_left).with().offset()(-self.REPLY_VIEW_OFFSET)
            make.centerY.equalTo()(self.replyView)
            make.height.equalTo()(self.getTextHeight())
        })
        self.updateConstraints()
    }
    
}

@objc protocol ChatViewDelegate {
    
    func chatViewDidTapBackButton(chatView: ChatView)
    
    func chatView(chatView: ChatView, didTapNextButtonWithWords words: [String])
    
    optional func chatViewReloadMessages(chatView: ChatView)
    
    optional func chatView(chatView: ChatView, didDeleteItemAtIndex index: Int)
    
}

protocol ChatViewDataSource {
    
    func numberOfFlipMessages(chatView: ChatView) -> Int
    
    func chatView(chatView: ChatView, flipMessageIdAtIndex index: Int) -> String
    
    func chatView(chatView: ChatView, shouldAutoPlayFlipMessageAtIndex index: Int) -> Bool
    
}
