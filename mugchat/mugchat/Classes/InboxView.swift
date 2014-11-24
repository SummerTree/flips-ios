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
    
    private let MUG_CELL_HEIGHT : CGFloat = 169
    private let COMPOSE_BUTTON_BOTTOM_MARGIN : CGFloat = 8
    private let CELL_IDENTIFIER = "conversationCell"
    
    private var navigationBar : CustomNavigationBar!
    private var conversationsTableView : UITableView!
    private var composeButton : UIButton!
    
    var delegate : InboxViewDelegate?
    
    private var roomIds: Array<String>!
    
    
    // MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        roomIds = Array<String>()
        
        self.initSubviews()
        self.initConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        let loggedUser = AuthenticationHelper.sharedInstance.userInSession
        navigationBar = CustomNavigationBar.CustomSmallNavigationBar(UIImage(named: "User")!, showSettingsButton: true, showBuilderButton: true)
        navigationBar.setAvatarImageUrl(loggedUser.photoURL)
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
    }
    
    
    // MARK: - Rooms Setter
    
    func setRoomIds(roomIds: [String]) {
        self.roomIds = roomIds
        self.conversationsTableView.reloadData()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as ConversationTableViewCell
        cell.setRoomId(roomIds[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomIds.count
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
            
            ActivityIndicatorHelper.showActivityIndicatorAtView(self)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                var roomId = self.roomIds[indexPath.row]
                let roomDataSource = RoomDataSource()
                var room = roomDataSource.retrieveRoomWithId(roomId)
                
                room.markAllMessagesAsRemoved({ (success) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        ActivityIndicatorHelper.hideActivityIndicatorAtView(self)
                    })
                })
                self.roomIds.removeAtIndex(indexPath.row)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                })
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