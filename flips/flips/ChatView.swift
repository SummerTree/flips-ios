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

class ChatView: UIView, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, JoinStringsTextFieldDelegate,ChatTableViewCellDelegate {
    
    private let CELL_IDENTIFIER: String = "flipChatCell"
    private let REPLY_VIEW_OFFSET : CGFloat = 18.0
    private let REPLY_BUTTON_HEIGHT : CGFloat = 64.0
    private let REPLY_VIEW_MARGIN : CGFloat = 10.0
    private let TEXT_VIEW_MARGIN : CGFloat = 3.0
    private let HORIZONTAL_RULER_HEIGHT : CGFloat = 1.0
    private let AUTOPLAY_ON_LOAD_DELAY : Double = 0.3

    private let THUMBNAIL_FADE_DURATION: NSTimeInterval = 0.2
    
    private let ONBOARDING_BUBBLE_TITLE: String = NSLocalizedString("Pretty cool, huh?", comment: "Pretty cool, huh?")
    private let ONBOARDING_BUBBLE_MESSAGE: String = NSLocalizedString("Now it's your turn.", comment: "Now it's your turn.")
    
    private var tableView: UITableView!
    private var darkHorizontalRulerView: UIView!
    private var replyView: UIView!
    private var replyButton: UIButton!
    private var replyTextField: JoinStringsTextField!
    private var nextButton: NextButton!
    
    private var shouldPlayUnreadMessage: Bool = true
    private var keyboardHeight: CGFloat = 0.0
    
    weak var delegate: ChatViewDelegate?
    weak var dataSource : ChatViewDataSource?
    
    private var showOnboarding: Bool = false
    private var bubbleView: BubbleView!
    
    private var prototypeCell: ChatTableViewCell?
    
    private var cellsHeightsCache: Dictionary<Int,CGFloat?>!
    private var indexPathToShow: NSIndexPath?

    
    // MARK: - Required initializers
    
    init(showOnboarding: Bool) {
        super.init(frame: CGRect.zeroRect)
        self.backgroundColor = UIColor.whiteColor()
        
        self.cellsHeightsCache = Dictionary<Int,CGFloat?>()
        
        self.showOnboarding = showOnboarding
        self.addSubviews()
        self.makeConstraints()
        
        self.updateNextButtonState()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Events
    
    func viewDidLoad() {
        println("ChatView - viewDidLoad")
        self.indexPathToShow = self.indexPathForCellThatShouldBeVisible()
        self.tableView.reloadData()
    }
    
    func viewWillAppear() {
        println("ChatView - viewWillAppear")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        
        replyView.mas_updateConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.getReplyTextHeight() + self.REPLY_VIEW_MARGIN)
            make.bottom.equalTo()(self)
        })
        self.updateConstraints()
        
        self.replyTextField.viewWillAppear()
        
        if (self.indexPathToShow != nil) {
            self.tableView.alpha = 0
        }
    }

    func didLayoutSubviews() {
        if (self.indexPathToShow != nil) {
            self.tableView.scrollToRowAtIndexPath(self.indexPathToShow!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            if (self.tableView.alpha == 0) {
                let oneSecond = 1 * Double(NSEC_PER_SEC)
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(oneSecond))
                dispatch_after(delay, dispatch_get_main_queue()) { () -> Void in
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.tableView.alpha = 1
                    })
                }
            }
        }
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        self.indexPathToShow = nil
        let visibleCells = tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            cell.stopMovie()
            cell.releaseResources()
        }
    }
    
    
    // MARK: - Layout
    
    func addSubviews() {
        tableView = UITableView(frame: self.frame, style: .Plain)
        tableView.backgroundColor = UIColor.grayColor()
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
        
        nextButton = NextButton()
        nextButton.contentEdgeInsets = UIEdgeInsetsMake(REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET, REPLY_VIEW_OFFSET)
        nextButton.hidden = true
        nextButton.addTarget(self, action: "didTapNextButton", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.sizeToFit()
        replyView.addSubview(nextButton)
        
        if (showOnboarding) {
            bubbleView = BubbleView(title: ONBOARDING_BUBBLE_TITLE, message: ONBOARDING_BUBBLE_MESSAGE, bubbleType: BubbleType.arrowDownFirstLineBold)
            self.addSubview(bubbleView)
        } 
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
            make.height.equalTo()(self.getReplyTextHeight())
        })
        
        nextButton.mas_makeConstraints( { (make) in
            make.right.equalTo()(self.replyView)
            make.top.equalTo()(self.replyView)
            make.bottom.equalTo()(self.replyView)
            make.width.equalTo()(self.nextButton.frame.width)
        })
        
        if (showOnboarding) {
            bubbleView.mas_makeConstraints({ (make) -> Void in
                make.bottom.equalTo()(self.tableView.mas_bottom)
                make.width.equalTo()(self.bubbleView.getWidth())
                make.height.equalTo()(self.bubbleView.getHeight())
                make.centerX.equalTo()(self)
            })
        }
    }
    
    func getReplyTextHeight() -> CGFloat{
        let myString: NSString = self.replyTextField.text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.height * 2 - self.TEXT_VIEW_MARGIN
    }
    
    func changeFlipWords(words: [String]) {
        self.replyTextField.setWords(words)
    }
    
    private func indexPathForCellThatShouldBeVisible() -> NSIndexPath {
        if let numberOfMessages: Int = self.dataSource?.numberOfFlipMessages(self) as Int? {
            return NSIndexPath(forRow: numberOfMessages - 1, inSection: 0)
        }
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    private func moveTableViewToCellAtIndexPath(indexPath: NSIndexPath) {
        let completionBlock : (() -> Void) = {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.tableView.alpha = 1.0
            })
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.AUTOPLAY_ON_LOAD_DELAY * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                self.playVideoForVisibleCell()
            })
        }
        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (indexPath.row > 0) {
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
//                let expectedContentOffset: CGFloat = CGFloat(380.5 * Float(indexPath.row))
//                let contentOffset = CGPoint(x: CGFloat(0), y: expectedContentOffset)
//                self.tableView.setContentOffset(contentOffset, animated: false)
//                println("   new offset: \(self.tableView.contentOffset)")
                completionBlock()
            } else {
                completionBlock()
            }
//        })
    }
    
//    private func moveTableViewForLatestNotReadMessage() {
//        self.tableView.alpha = 0.0
//        
//        println("moveTableViewForLatestNotReadMessage")
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//            let flipMessagaDataSource = FlipMessageDataSource()
//            if let numberOfMessages = self.dataSource?.numberOfFlipMessages(self) as Int? {
//                println("   numberOfMessages: \(numberOfMessages)")
//                var firstNotReadMessageIndex = numberOfMessages - 1
//                println("   before firstNotReadMessageIndex: \(firstNotReadMessageIndex)")
//                
//                for (var i = 0; i < numberOfMessages; i++) {
//                    let flipMessageId = self.dataSource?.chatView(self, flipMessageIdAtIndex: i)
//                    if (flipMessageId != nil) {
//                        var flipMessage = flipMessagaDataSource.retrieveFlipMessageById(flipMessageId!)
//                        if (flipMessage.notRead.boolValue) {
//                            firstNotReadMessageIndex = i
//                            break
//                        }
//                    }
//                }
//                println("   after firstNotReadMessageIndex: \(firstNotReadMessageIndex)")
//                
//                let completionBlock : (() -> Void) = {
//                    UIView.animateWithDuration(0.25, animations: { () -> Void in
//                        self.tableView.alpha = 1.0
//                    })
//                    
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(self.AUTOPLAY_ON_LOAD_DELAY * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
//                        self.playVideoForVisibleCell()
//                    })
//                }
//                
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    if (firstNotReadMessageIndex > 0) {
//                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: firstNotReadMessageIndex, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
//                        completionBlock()
//                    } else {
//                        completionBlock()
//                    }
//                })
//            }
//        })
//    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.chatViewDidTapBackButton(self)
    }
    
    
    // MARK: - Data Load Methods
    
    func loadNewFlipMessages() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let currentNumberOfCells: Int = self.tableView.numberOfRowsInSection(0)

            var newCellsIndexPaths: Array<NSIndexPath> = Array<NSIndexPath>()
            if let newNumberOfCells: Int = self.dataSource?.numberOfFlipMessages(self) {
                for (var i = currentNumberOfCells; i < newNumberOfCells; i++) {
                    var indexPath = NSIndexPath(forRow: i, inSection: 0)
                    newCellsIndexPaths.append(indexPath)
                }
            }
            self.tableView.insertRowsAtIndexPaths(newCellsIndexPaths, withRowAnimation: UITableViewRowAnimation.None)
        })
    }
    
    private func reloadFlipMessagesWithCompletion(completion: ((NSIndexPath) -> Void)?) {
//        ActivityIndicatorHelper.showActivityIndicatorAtView(self)
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
//            let indexPathToBeVisible = self.indexPathForCellThatShouldBeVisible()
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                if (completion != nil) {
//                    completion!(indexPathToBeVisible)
//                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                }
//            })
//        })
        
    }
    
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("cellForRowAtIndexPath \(indexPath.row)")
        var cell: ChatTableViewCell? = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell?
        if (cell == nil) {
            cell = ChatTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_IDENTIFIER)
        }
        
        cell!.textLabel?.text = "Test \(indexPath.row)" // TODO: remove it
        configureCell(cell!, atIndexPath: indexPath)
        
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfMessages: Int? = dataSource?.numberOfFlipMessages(self) as Int?
        if (numberOfMessages == nil) {
            numberOfMessages = 0
        }
        
        return numberOfMessages!
    }
    
    /* There are performance implications to using tableView:heightForRowAtIndexPath: instead of the rowHeight property. Every time a table view is displayed, it calls tableView:heightForRowAtIndexPath: on the delegate for each of its rows, which can result in a significant performance problem with table views having a large number of rows (approximately 1000 or more). */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (DeviceHelper.sharedInstance.systemVersion() >= 8.0) {
            return UITableViewAutomaticDimension
        }

//        // (7)
//        //self.prototypeCell.bounds = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
//        
//        [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
//        
//        // (8)
//        [self.prototypeCell updateConstraintsIfNeeded];
//        [self.prototypeCell layoutIfNeeded];
//        
//        // (9)
//        return [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

        var cell = self.getPrototypeCell()
        
//        cell.setBounds(CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds)))
        
//        self.configureCell(cell, atIndexPath: indexPath)
        var size: CGFloat = 0
        if let flipMessage: FlipMessage? = dataSource?.chatView(self, flipMessageAtIndex: indexPath.row) {
//        if (flipMessageId != nil) {
//            cell.setFlipMessageToCalculateHeight(flipMessage!)
//            cell.setFlipMessage(flipMessage!)
            size = cell.heightForFlipMessage(flipMessage!)
        }
        
//        cell.updateConstraints()
//        cell.contentView.setNeedsLayout()
//        cell.updateConstraintsIfNeeded()
//        cell.layoutIfNeeded()
//        cell.layoutSubviews()

        println("cell.frame: \(cell.frame)")
//        return cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
//        let size: CGFloat = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        println("calculated height for cell \(indexPath.row): \(size)")
        return size
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    // MARK: - Cell Height Auxiliary Methods
    
    private func getPrototypeCell() -> ChatTableViewCell {
//        if (self.prototypeCell == nil) {
//            self.prototypeCell = (self.tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell)
//        }
        
//        return self.prototypeCell!
        return (self.tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell)
    }
    
    private func configureCell(cell: ChatTableViewCell, atIndexPath indexPath: NSIndexPath) {
        println("configureCell at index \(indexPath.row)")
        if cell.isPlayingFlip() {
            cell.stopMovie()
        }
        
//        let flipMessageId: String? = dataSource?.chatView(self, flipMessageIdAtIndex: indexPath.row)
        if let flipMessage: FlipMessage? = dataSource?.chatView(self, flipMessageAtIndex: indexPath.row) {
//        if (flipMessageId != nil) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                cell.setFlipMessage(flipMessage!)
//            })
        }
        
        //        cell.videoPlayerContainerViewWidthConstraint.constant = CGRectGetWidth(self.tableView.bounds)
        //
        //        if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
        //            cell.videoPlayerContainerViewWidthConstraint.constant -= self.CELL_PADDING_FOR_IPHONE_4S * 2.0
        //        }
    }

    
//    private func calculateHeightForConfiguredSizingCell(sizingCell: UITableViewCell) -> CGFloat {
//        sizingCell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(sizingCell.bounds))
//        
//        sizingCell.setNeedsLayout()
//        sizingCell.layoutIfNeeded()
//        
//        let size: CGSize = sizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//        return size.height
//    }
//    
//    private func heightForChatTableViewCellAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
//        struct Static {
//            static var sizingCell: ChatTableViewCell!
//        }
//        
//        if (Static.sizingCell == nil) {
//            Static.sizingCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ChatTableViewCell
//        }
//        
//        let flipMessageId: String? = dataSource?.chatView(self, flipMessageIdAtIndex: indexPath.row)
//        if (flipMessageId != nil) {
//            Static.sizingCell.setFlipMessageIdToCalculateHeight(flipMessageId!)
//        }
//        
//        return calculateHeightForConfiguredSizingCell(Static.sizingCell)
//    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let visibleCells: [AnyObject] = self.tableView.visibleCells()

        for cell: ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            if !self.isCell(cell, totallyVisibleOnView: self) {
                if cell.isPlayingFlip() {
                    cell.stopMovie()
                }
            }
        }
    }
    
    private func isCell(cell: ChatTableViewCell, totallyVisibleOnView view: UIView) -> Bool {
        var videoContainerView: UIView = cell.subviews[0] as UIView // Gets video container view from cell
        var convertedVideoContainerViewFrame: CGRect = cell.convertRect(videoContainerView.frame, toView:view)
        if (CGRectContainsRect(view.frame, convertedVideoContainerViewFrame)) {
            return true
        } else {
            return false
        }
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (!decelerate) {
                self.playVideoForVisibleCell()
            }
        })
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.playVideoForVisibleCell()
        })
    }

    private func playVideoForVisibleCell() {
//        let visibleCells = self.tableView.visibleCells()
//        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
//            if (self.isCell(cell, totallyVisibleOnView: self)) {
//                var indexPath = self.tableView.indexPathForCell(cell) as NSIndexPath?
//                if (indexPath == nil) {
//                    return
//                }
//                var row = indexPath?.row
//                var shouldAutoPlay: Bool? = dataSource?.chatView(self, shouldAutoPlayFlipMessageAtIndex: row!)
//                if (shouldAutoPlay != nil) {
//                    cell.playMovie()
//                }
//            } else {
//                cell.stopMovie()
//            }
//        }
    }

    
    // MARK: - Button Handlers
    
    func didTapReplyButton() {
        hideReplyButtonAndShowTextField()
        
        let visibleCells: [AnyObject] = tableView.visibleCells()
        for cell: ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            cell.stopMovie()
        }
        
        self.replyTextField.becomeFirstResponder()
    }
    
    func didTapNextButton() {
        self.delegate?.chatView(self, didTapNextButtonWithWords: replyTextField.getFlipTexts())
    }
    
    private func hideReplyButtonAndShowTextField() {
        self.replyButton.hidden = true
        self.replyTextField.hidden = false
        self.nextButton.hidden = false
        
        replyView.mas_updateConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.getReplyTextHeight() + self.REPLY_VIEW_MARGIN)
            make.bottom.equalTo()(self)
        })
        self.updateConstraints()
    }
    
    func hideTextFieldAndShowReplyButton() {
        self.replyButton.hidden = false
        self.replyTextField.hidden = true
        self.nextButton.hidden = true
        self.updateNextButtonState()
    }
    
    func clearReplyTextField() {
        self.replyTextField.text = ""
        self.updateNextButtonState()
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
        
        if (numberOfMessages > 0) {
            let indexPath = NSIndexPath(forRow: numberOfMessages! - 1, inSection: 0)
            
            replyView.mas_updateConstraints( { (make) in
                make.left.equalTo()(self)
                make.right.equalTo()(self)
                make.height.equalTo()(self.getReplyTextHeight() + self.REPLY_VIEW_MARGIN)
                make.bottom.equalTo()(self).with().offset()(-self.keyboardHeight)
            })
            self.updateConstraints()
            self.layoutIfNeeded()
            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    
    // MARK: - JoinStringsTextFieldDelegate delegate
    
    func joinStringsTextFieldNeedsToHaveItsHeightUpdated(joinStringsTextField: JoinStringsTextField!) {
        replyView.mas_updateConstraints( { (make) in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.getReplyTextHeight() + self.REPLY_VIEW_MARGIN)
            make.bottom.equalTo()(self).with().offset()(-self.keyboardHeight)
        })
        
        replyTextField.mas_updateConstraints( { (make) in
            make.left.equalTo()(self.replyView).with().offset()(self.REPLY_VIEW_OFFSET)
            make.right.equalTo()(self.nextButton.mas_left).with().offset()(-self.REPLY_VIEW_OFFSET)
            make.centerY.equalTo()(self.replyView)
            make.height.equalTo()(self.getReplyTextHeight())
        })
        self.updateConstraints()
    }
    
    func joinStringsTextField(joinStringsTextField: JoinStringsTextField, didChangeText: String!) {
        updateNextButtonState()
    }
    
    // MARK: - ChatTableViewCellDelegate
    
    func chatTableViewCellIsVisible(chatTableViewCell: ChatTableViewCell) -> Bool {
        let visibleCells = tableView.visibleCells()
        for cell : ChatTableViewCell in visibleCells as [ChatTableViewCell] {
            if (cell == chatTableViewCell) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Private methods
    
    private func updateNextButtonState() {
        nextButton.enabled = !replyTextField.text.removeWhiteSpaces().isEmpty
    }
}

@objc protocol ChatViewDelegate {
    
    func chatViewDidTapBackButton(chatView: ChatView)
    
    func chatView(chatView: ChatView, didTapNextButtonWithWords words: [String])
    
    optional func chatViewReloadMessages(chatView: ChatView)
    
    optional func chatView(chatView: ChatView, didDeleteItemAtIndex index: Int)
    
}

protocol ChatViewDataSource: class {
    
    func numberOfFlipMessages(chatView: ChatView) -> Int
    
    func chatView(chatView: ChatView, flipMessageAtIndex index: Int) -> FlipMessage
    
    func chatView(chatView: ChatView, shouldAutoPlayFlipMessageAtIndex index: Int) -> Bool
    
}
