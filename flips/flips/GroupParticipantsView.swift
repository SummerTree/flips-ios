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

class GroupParticipantsView: UIView, UITableViewDelegate, UITableViewDataSource {

    private let CELL_IDENTIFIER: String = "participantCell"
    private let CELL_HEIGHT: CGFloat = 50
    
    private let VIEW_ALPHA: CGFloat = 0.989 // Since the original blur wasn't applied, we need a very small transparency.
    
    private var participantsTableView: UITableView!
    private var participants: Array<User>!
    
    
    // MARK: - Init Methods
    
    init(participants: Array<User>) {
        super.init(frame: CGRect.zeroRect)
        self.participants = participants
        
        self.tintColor = UIColor.whiteColor()
        self.alpha = VIEW_ALPHA
        
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View Layout Methods
    
    func setupView() {
        self.participantsTableView = UITableView(frame: self.frame, style: .Plain)
        self.participantsTableView.dataSource = self
        self.participantsTableView.delegate = self
        self.participantsTableView.contentInset = UIEdgeInsetsZero
        self.participantsTableView.contentOffset = CGPointMake(0, 0)
        self.participantsTableView.allowsSelection = false
        self.participantsTableView.registerClass(GroupPartcipantsTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        self.addSubview(self.participantsTableView)
        
        self.participantsTableView.reloadData()
        
        self.participantsTableView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.top.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    func calculatedHeight() -> CGFloat {
        return CGFloat(self.participants.count) * CELL_HEIGHT
    }
    
    
    // MARK: - TableViewDataSource Methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: GroupPartcipantsTableViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath) as GroupPartcipantsTableViewCell
        
        let user = self.participants[indexPath.row]
        cell.configureCellWithUser(user)
        cell.removeSeparatorInsets()
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.participants.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
}
