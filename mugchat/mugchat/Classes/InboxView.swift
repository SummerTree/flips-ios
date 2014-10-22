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

class InboxView : UIView, UITableViewDataSource, UITableViewDelegate, CustomNavigationBarDelegate {
    
    // TODO: will be removed - just for test
    var items = [ InboxItem(userName: "Ben", mugMessage: "tap to play", notReadMessages: 2, mugTime: "10:20 PM"),
        InboxItem(userName: "Diego, Ecil, Bruno, Cristiano, Ben, Eric", mugMessage: "tap to play", notReadMessages: 3, mugTime: "10:18 PM"),
        InboxItem(userName: "Diego", mugMessage: "I love SF 1", notReadMessages: 0, mugTime: "10:16 PM"),
        InboxItem(userName: "Eric", mugMessage: "I love SF 2", notReadMessages: 20, mugTime: "10:15 PM"),
        InboxItem(userName: "Ecil", mugMessage: "I love SF 3", notReadMessages: 0, mugTime: "10:14 PM"),
        InboxItem(userName: "Diego, Ecil", mugMessage: "I love SF 4", notReadMessages: 1, mugTime: "10:13 PM"),
        InboxItem(userName: "MugBoys", mugMessage: "Welcome to MugChat", notReadMessages: 0, mugTime: "10:01 PM") ]
    
    private let MUG_CELL_HEIGHT : CGFloat = 168.5
    private let COMPOSE_BUTTON_BOTTOM_MARGIN : CGFloat = 8
    private let CELL_IDENTIFIER = "conversationCell"
    
    private var navigationBar : CustomNavigationBar!
    private var conversationsTableView : UITableView!
    private var composeButton : UIButton!
    
    var delegate : InboxViewDelegate?
    
    
    // MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubviews()
        self.initConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        navigationBar = CustomNavigationBar.CustomSmallNavigationBar(UIImage(named: "tmp_homer")!, showSettingsButton: true, showBuiderButton: true)
        navigationBar.delegate = self
        
        
        conversationsTableView = UITableView(frame: self.frame, style: .Plain)
        conversationsTableView.registerClass(ConversationTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        conversationsTableView.separatorStyle = .None
        conversationsTableView.contentInset = UIEdgeInsetsMake(navigationBar.getNavigationBarHeight(), 0, 0, 0)
        conversationsTableView.contentOffset = CGPointMake(0, -navigationBar.getNavigationBarHeight())
        self.addSubview(conversationsTableView)
        
        conversationsTableView.dataSource = self
        conversationsTableView.delegate = self
        
        self.addSubview(navigationBar)
        
        composeButton = UIButton()
        composeButton.setImage(UIImage(named: "Compose"), forState: .Normal)
        composeButton.addTarget(self, action: "composeButtonTapped", forControlEvents: .TouchUpInside)
        composeButton.sizeToFit()
        self.addSubview(composeButton)
    }
    
    private func initConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        conversationsTableView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        
        composeButton.mas_makeConstraints { (make) -> Void in
            make.bottom.lessThanOrEqualTo()(self).with().offset()(-self.COMPOSE_BUTTON_BOTTOM_MARGIN)
            make.centerX.equalTo()(self)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ConversationTableViewCell
        cell.item = items[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MUG_CELL_HEIGHT;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return NSLocalizedString("Delete", comment: "Delete")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var size = CGSizeMake(CGRectGetWidth(navigationBar.frame), CGRectGetHeight(navigationBar.frame))
        navigationBar.setBackgroundImage(conversationsTableView.getImageWithSize(size))
    }
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.inboxView(self, didTapAtItemAtIndex: indexPath.row)
    }
    
    
    // MARK: - Button Handlers
    
    func composeButtonTapped() {
        delegate?.inboxViewDidTapComposeButton(self)
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.inboxViewDidTapSettingsButton(self)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        delegate?.inboxViewDidTapBuilderButton(self)
    }
}