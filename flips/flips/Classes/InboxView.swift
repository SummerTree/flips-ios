//
// Copyright 2015 ArcTouch, Inc.
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
    
    private let ONBOARDING_KEY = "InboxViewOnboardingShown";
    
    //private let FLIP_CELL_HEIGHT : CGFloat = 169
    private let COMPOSE_BUTTON_BOTTOM_MARGIN : CGFloat = 8
    private let CELL_IDENTIFIER = "conversationCell"
    
    private let ONBOARDING_BUBBLE_TITLE = NSLocalizedString("Welcome to Flips", comment: "Welcome to Flips")
    private let ONBOARDING_BUBBLE_MESSAGE = NSLocalizedString("You have a message. Must be nice to\nbe so popular.", comment: "You have a message. Must be nice to\nbe so popular.")

    private var sendingView : UILabel!
    private var navigationBar : CustomNavigationBar!
    private var conversationsTableView : UITableView!
    private var composeButton : UIButton!
    private var overlayView : UIImageView!
    
    private var cellHeight : CGFloat = 169
    
    weak var delegate : InboxViewDelegate?
    weak var dataSource: InboxViewDataSource?
    
    private var showOnboarding = false
    private var bubbleView: BubbleView!
    
    // MARK: - Initialization Methods
    
    init(showOnboarding: Bool) {
        super.init(frame: CGRect.zero)
        
        self.showOnboarding = showOnboarding
        self.initSubviews()
        self.initConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        navigationBar = CustomNavigationBar.CustomSmallNavigationBar(UIImage(named: "User")!, showSettingsButton: true, showBuilderButton: false)
        if let loggedUser = User.loggedUser() {
            if let url = NSURL(string: loggedUser.photoURL) {
                navigationBar.setAvatarImageURL(url)
            }
        }
        
        navigationBar.alpha = 0.99
        
        conversationsTableView = UITableView(frame: self.frame, style: .Plain)
        conversationsTableView.registerClass(ConversationTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        conversationsTableView.separatorStyle = .None
        conversationsTableView.contentInset = UIEdgeInsetsMake(navigationBar.getNavigationBarHeight(), 0, 0, 0)
        conversationsTableView.contentOffset = CGPointMake(0, -navigationBar.getNavigationBarHeight())
        conversationsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(navigationBar.getNavigationBarHeight(), 0, 0, 0)
        conversationsTableView.backgroundColor = UIColor.sand()
        self.addSubview(conversationsTableView)
        navigationBar.delegate = self
        
        conversationsTableView.dataSource = self
        conversationsTableView.delegate = self
        
        sendingView = UILabel()
        sendingView.hidden = true
        sendingView.backgroundColor = UIColor.flipOrangeBackground()
        sendingView.textColor = UIColor.whiteColor()
        sendingView.text = "Sending Message..."
        sendingView.textAlignment = NSTextAlignment.Center
        addSubview(self.sendingView)
        
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
        
        setupOnboarding()
    }
    
    private func initConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        sendingView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.navigationBar)
            make.left.equalTo()(self)
            make.width.equalTo()(self)
            make.height.equalTo()(44)
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
                make.top.equalTo()(self.navigationBar.mas_bottom).with().offset()(self.cellHeight)
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
    
    override func layoutSubviews() {
        cellHeight = self.frame.height * 0.4
        super.layoutSubviews()
    }
    
    ////
    // MARK: - Onboarding
    ////
    
    private func shouldShowOnboarding() -> (Bool) {
        return !NSUserDefaults.standardUserDefaults().boolForKey(ONBOARDING_KEY);
    }
    
    private func setupOnboarding() {
        
        if (shouldShowOnboarding()) {
            
            let singleTap = UITapGestureRecognizer(target: self, action: Selector("onOnboardingOverlayClick"))
            singleTap.numberOfTapsRequired = 1
            
            overlayView = UIImageView(image: UIImage(named: "Inbox Overlay"))
            overlayView.userInteractionEnabled = true
            overlayView.addGestureRecognizer(singleTap)
            
            let window = UIApplication.sharedApplication().keyWindow
            window!.addSubview(overlayView)
            
            overlayView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(window)
                make.left.equalTo()(window)
                make.right.equalTo()(window)
                make.bottom.equalTo()(window)
            }
            
            let userDefaults = NSUserDefaults.standardUserDefaults();
            userDefaults.setBool(true, forKey: ONBOARDING_KEY);
            userDefaults.synchronize();
            
        }
        
    }
    
    func onOnboardingOverlayClick() {
        overlayView.removeFromSuperview()
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
    
    func reloadCells() {
        for cell: ConversationTableViewCell in self.conversationsTableView.visibleCells as! [ConversationTableViewCell] {
            cell.refreshCell(false)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as! ConversationTableViewCell
        
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
        return cellHeight;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let roomID: String = dataSource!.inboxView(self, roomAtIndex: indexPath.row)
        let roomDataSource: RoomDataSource = RoomDataSource()
        if let room: Room = roomDataSource.getRoomById(roomID) {

            let participants: [User] = Array(room.participants) as! [User]
            if (participants.count == 2) {
                for participant in participants {
                    if (participant.username == TEAMFLIPS_USERNAME) {
                        return false
                    }
                }
            }
        }
        
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
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dataSource?.inboxView(self, didRemoveRoomAtIndex: indexPath.row)
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                    })

                    let roomDataSource = RoomDataSource()
                    let room = roomDataSource.retrieveRoomWithId(roomId)
                    
                    room.markAllMessagesAsRemoved({ (success) -> Void in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                        })
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
    
    
    
    ////
    // MARK: - Sending View
    ////
    
    func showSendingView() {
        
        if sendingView.hidden == true
        {
            self.sendingView.mas_updateConstraints { (update) -> Void in
                update.bottom.equalTo()(self.navigationBar)
            }
            
            self.sendingView.hidden = false
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.sendingView.frame.origin.y += self.sendingView.frame.height
            })
        }
        
    }
    
    func hideSendingView() {
        
        if sendingView.hidden == false
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
            
                self.sendingView.frame.origin.y -= self.sendingView.frame.height
                
            }, completion:{ (finished) -> Void in
                    
                self.sendingView.hidden = true
                
            })
        }
        
    }
    
    
}

protocol InboxViewDataSource: class {
    func numberOfRooms() -> Int
    func inboxView(inboxView: InboxView, roomAtIndex index: Int) -> String
    func inboxView(inboxView: InboxView, didRemoveRoomAtIndex index: Int)
}