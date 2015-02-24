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
    
    private let FLIP_CELL_HEIGHT : CGFloat = 169
    private let COMPOSE_BUTTON_BOTTOM_MARGIN : CGFloat = 8
    private let CELL_IDENTIFIER = "conversationCell"
    
    private let ONBOARDING_BUBBLE_TITLE = NSLocalizedString("Welcome to Flips", comment: "Welcome to Flips")
    private let ONBOARDING_BUBBLE_MESSAGE = NSLocalizedString("You have a message. Must be nice to\nbe so popular.", comment: "You have a message. Must be nice to\nbe so popular.")

    private var navigationBar : CustomNavigationBar!
    private var conversationsTableView : UITableView!
    private var composeButton : UIButton!
    
    var delegate : InboxViewDelegate?
    var dataSource: InboxViewDataSource?
    
    private var showOnboarding = false
    private var bubbleView: BubbleView!
    
    // MARK: - Initialization Methods
    
    init(showOnboarding: Bool) {
        super.init(frame: CGRect.zeroRect)
        
        self.showOnboarding = showOnboarding
        self.initSubviews()
        self.initConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        navigationBar = CustomNavigationBar.CustomSmallNavigationBar(UIImage(named: "User")!, showSettingsButton: true, showBuilderButton: true)
        if let loggedUser = User.loggedUser() {
            if let url = NSURL(string: loggedUser.photoURL) {
                navigationBar.setAvatarImageURL(url)
            }
        }
        
        navigationBar.alpha = 0.99 // FOR iOS7.
        // TODO: apply blur for iOS8 using new methods.
        
        conversationsTableView = UITableView(frame: self.frame, style: .Plain)
        conversationsTableView.registerClass(ConversationTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        conversationsTableView.separatorStyle = .None
        conversationsTableView.contentInset = UIEdgeInsetsMake(navigationBar.getNavigationBarHeight(), 0, 0, 0)
        conversationsTableView.contentOffset = CGPointMake(0, -navigationBar.getNavigationBarHeight())
        conversationsTableView.backgroundColor = UIColor.sand()
        self.addSubview(conversationsTableView)
        navigationBar.delegate = self
        
        conversationsTableView.dataSource = self
        conversationsTableView.delegate = self
        
        self.addSubview(navigationBar)
        
        composeButton = UIButton()
        composeButton.setImage(UIImage(named: "Compose"), forState: .Normal)
        composeButton.addTarget(self, action: "composeButtonTapped", forControlEvents: .TouchUpInside)
        composeButton.sizeToFit()
        self.addSubview(composeButton)
        
        if (showOnboarding) {
            navigationBar.userInteractionEnabled = false
            composeButton.userInteractionEnabled = false
            
            bubbleView = BubbleView(title: ONBOARDING_BUBBLE_TITLE, message: ONBOARDING_BUBBLE_MESSAGE, bubbleType: BubbleType.arrowUp)
            bubbleView.hidden = true
            self.addSubview(bubbleView)
        } else {
            navigationBar.userInteractionEnabled = true
            composeButton.userInteractionEnabled = true
        }
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
            make.bottom.equalTo()(self).with().offset()(-self.COMPOSE_BUTTON_BOTTOM_MARGIN)
            make.centerX.equalTo()(self)
        }
        
        if (showOnboarding) {
            bubbleView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self.navigationBar.mas_bottom).with().offset()(self.FLIP_CELL_HEIGHT)
                make.width.equalTo()(self.bubbleView.getWidth())
                make.height.equalTo()(self.bubbleView.getHeight())
                make.centerX.equalTo()(self)
            }
        }
    }
    
    func viewWillAppear() {
        if let loggedUser = User.loggedUser() {
            if let url = NSURL(string: loggedUser.photoURL) {
                navigationBar.setAvatarImageURL(url)
            }
        }
    }
    
    
    // MARK: - Rooms Setter
    
    func reloadData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (self.showOnboarding) {
                if let numberOfRooms = self.dataSource?.numberOfRooms() {
                    if (numberOfRooms > 0) {
                        self.bubbleView.hidden = false
                    }
                }
            }
            
            self.conversationsTableView.reloadData()
        })
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ConversationTableViewCell
        
        if let roomId = dataSource?.inboxView(self, roomAtIndex: indexPath.row) {
            cell.setRoomId(roomId)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataSource == nil) {
            return 0
        }
        return dataSource!.numberOfRooms()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return FLIP_CELL_HEIGHT;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return NSLocalizedString("Delete", comment: "Delete")
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            ActivityIndicatorHelper.showActivityIndicatorAtView(self)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                if let roomId = self.dataSource?.inboxView(self, roomAtIndex: indexPath.row) {
                    self.dataSource?.inboxView(self, didRemoveRoomAtIndex: indexPath.row)
                    
                    let roomDataSource = RoomDataSource()
                    var room = roomDataSource.retrieveRoomWithId(roomId)
                    
                    room.markAllMessagesAsRemoved({ (success) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                        })
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                    })
                }
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // BLUR is causing the scroll to not be smooth.
//        let size = CGSizeMake(CGRectGetWidth(self.navigationBar.frame), CGRectGetHeight(self.navigationBar.frame))
//        let image = self.conversationsTableView.getImageWithSize(size)
//        self.navigationBar.setBackgroundImage(image)
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

protocol InboxViewDataSource {
    func numberOfRooms() -> Int
    func inboxView(inboxView: InboxView, roomAtIndex index: Int) -> String
    func inboxView(inboxView: InboxView, didRemoveRoomAtIndex index: Int)
}