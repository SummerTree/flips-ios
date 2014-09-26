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

class InboxView : UIView, UITableViewDataSource, UITableViewDelegate {
    
    // TODO: will be removed - just for test
    var items = [ InboxItem(userName: "Ben", mugMessage: "tap to play", notReadMessages: 2, mugTime: "10:20 PM"),
        InboxItem(userName: "Diego, Ecil, Bruno, Cristiano, Ben, Eric", mugMessage: "tap to play", notReadMessages: 3, mugTime: "10:18 PM"),
        InboxItem(userName: "Diego", mugMessage: "I love SF", notReadMessages: 0, mugTime: "10:16 PM"),
        InboxItem(userName: "MugBoys", mugMessage: "Welcome to MugChat", notReadMessages: 0, mugTime: "10:01 PM") ]
    
    private let MUG_CELL_HEIGHT : CGFloat = 168.5
    private let COMPOSE_BUTTON_BOTTOM_MARGIN : CGFloat = 8
    private let CELL_IDENTIFIER = "conversationCell"
    
    private var conversationsTableView : UITableView!
    private var composeButton : UIButton!
    
    
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
    
    
    // MARK: - Private Methods
    
    private func initSubviews() {
        conversationsTableView = UITableView(frame: self.frame, style: .Plain)
        conversationsTableView.registerClass(ConversationTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        conversationsTableView.separatorStyle = .None
        self.addSubview(conversationsTableView)
        
        conversationsTableView.dataSource = self
        conversationsTableView.delegate = self
        
        composeButton = UIButton()
        composeButton.setImage(UIImage(named: "Compose"), forState: .Normal)
        composeButton.addTarget(self, action: "composeButtonTapped", forControlEvents: .TouchUpInside)
        composeButton.sizeToFit()
        self.addSubview(composeButton)
    }
    
    private func initConstraints() {
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
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("didDeselectRowAtIndexPath")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    // MARK: - Button Handlers
    
    func composeButtonTapped() {
        println("composeButtonTapped")
    }
}