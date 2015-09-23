
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

class ImportContactsTableViewController: UITableViewController, NewFlipViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    private let CONTACT_TABLE_VIEW_IDENTIFIER_ON_FLIPS: String! = "CONTACT_TABLE_VIEW_IDENTIFIER_ON_FLIPS"
    private let CONTACT_TABLE_VIEW_IDENTIFIER_OTHERS: String! = "CONTACT_TABLE_VIEW_IDENTIFIER_OTHERS"
    private let IMPORT_CONTACTS_TIMEOUT: dispatch_time_t = 10
    private let LABEL_MARGIN_LEFT: CGFloat = 10.0
    private let LABEL_MARGIN_RIGHT: CGFloat = -15.0
    private let CELL_HEIGHT: CGFloat = 56.0
    private let HEADER_HEIGHT: CGFloat = 25.0
    private let CONTACTS_ON_FLIPS_SECTION: Int = 0
    private let EVERYONE_ELSE_SECTION: Int = 1
    
    
    private var contactsIdsWithFlipsAccount: [String]!
    private var contactsIdsWithoutFlipsAccount: [String]!
    private var contactsOnFlipsHeaderView: UIView!
    private var everyoneElseHeaderView: UIView!

    init() {
        super.init(style: UITableViewStyle.Plain)
        let contactDataSource = ContactDataSource()
        self.contactsIdsWithoutFlipsAccount = contactDataSource.getMyContactsIdsWithoutFlipsAccount()
        self.contactsIdsWithFlipsAccount = contactDataSource.getMyContactsIdsWithFlipsAccount()
        
        self.contactsOnFlipsHeaderView = createContactsOnFlipsHeaderView()
        self.everyoneElseHeaderView = createEveryoneElseHeaderView()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createContactsOnFlipsHeaderView () -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.layer.borderColor = UIColor.lightGreyD8().CGColor
        view.layer.borderWidth = 0.5
        
        let label = UILabel()
        label.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h3)
        label.text = NSLocalizedString("Contacts on Flips", comment: "Contacts with Account")
        label.textColor = UIColor.deepSea()
        label.sizeToFit()
        
        view.addSubview(label)
        
        label.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(view).with().offset()(self.LABEL_MARGIN_LEFT)
            make.centerY.equalTo()(view)
        }
        
        return view
    }
    
    private func createEveryoneElseHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        view.layer.borderColor = UIColor.lightGreyD8().CGColor
        view.layer.borderWidth = 0.5
        
        let leftLabel = UILabel()
        leftLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h3)
        leftLabel.text = NSLocalizedString("Everyone else", comment: "Contacts without account")
        leftLabel.textColor = UIColor.deepSea()
        leftLabel.sizeToFit()
        
        view.addSubview(leftLabel)
        
        let rightLabel = UILabel()
        rightLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
        rightLabel.text = NSLocalizedString("send a message to invite", comment:"Invite")
        rightLabel.textColor = UIColor.lightGreyD8()
        rightLabel.sizeToFit()
        
        view.addSubview(rightLabel)
        
        leftLabel.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(view).with().offset()(self.LABEL_MARGIN_LEFT)
            make.centerY.equalTo()(view)
            make.height.equalTo()(leftLabel.frame.size.height)
        }
        
        rightLabel.mas_makeConstraints { (make) -> Void in
            make.right.equalTo()(view).with().offset()(self.LABEL_MARGIN_RIGHT)
            make.centerY.equalTo()(view)
            make.height.equalTo()(rightLabel.frame.size.height)
        }
        
        return view
    }
    
    
    // MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupWhiteNavBarWithoutBackButtonWithRightDoneButton("Contacts")
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.translucent = false
        let textAttributes = [NSForegroundColorAttributeName: UIColor.deepSea()]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.setNeedsStatusBarAppearanceUpdate()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    
        self.tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: CONTACT_TABLE_VIEW_IDENTIFIER_ON_FLIPS)
        self.tableView.registerNib(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: CONTACT_TABLE_VIEW_IDENTIFIER_OTHERS)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }

    override func doneButtonTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK - UITableViewControllerDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == CONTACTS_ON_FLIPS_SECTION) {
            return self.contactsOnFlipsHeaderView
        }
        
        if (section == EVERYONE_ELSE_SECTION) {
            return everyoneElseHeaderView
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.HEADER_HEIGHT
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let contactDatasource = ContactDataSource()
        var contact: Contact!
        
        if (indexPath.section == CONTACTS_ON_FLIPS_SECTION) {
            let contactId = self.contactsIdsWithFlipsAccount[indexPath.row]
            contact = contactDatasource.retrieveContactWithId(contactId)
            
        } else if (indexPath.section == EVERYONE_ELSE_SECTION) {
            let contactId = self.contactsIdsWithoutFlipsAccount[indexPath.row]
            contact = contactDatasource.retrieveContactWithId(contactId)
            
            AnalyticsService.logUserSentInvite()
        }

        let navigationController: UINavigationController = NewFlipViewController.instantiateNavigationController(contact)
        let newFlipViewController = navigationController.topViewController as! NewFlipViewController
        newFlipViewController.delegate = self
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == CONTACTS_ON_FLIPS_SECTION) {
            return self.contactsIdsWithFlipsAccount.count
        }
        
        if (section == EVERYONE_ELSE_SECTION) {
            return self.contactsIdsWithoutFlipsAccount.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: ContactTableViewCell?

        let contactDataSource = ContactDataSource()
        var contact: Contact!
        
        if (indexPath.section == CONTACTS_ON_FLIPS_SECTION) {
            cell = tableView.dequeueReusableCellWithIdentifier(CONTACT_TABLE_VIEW_IDENTIFIER_ON_FLIPS) as? ContactTableViewCell

            let contactId = self.contactsIdsWithFlipsAccount[indexPath.row]
            if let contact = contactDataSource.getContactById(contactId) {
                cell!.photoView.setAvatarWithURL(NSURL(string:contact.contactUser.photoURL))
                cell!.contact = contact
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(CONTACT_TABLE_VIEW_IDENTIFIER_OTHERS) as? ContactTableViewCell

            let contactId = self.contactsIdsWithoutFlipsAccount[indexPath.row]
            if let contact = contactDataSource.getContactById(contactId) {
                cell!.contact = contact
            }
        }
        
        return cell!
    }
    
    
    // MARK: - NewFlipViewControllerDelegate
    
    func didBeginSendingMessageToRoom(roomID: String!) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            if let roomID = roomID
            {
                let roomDataSource = RoomDataSource()
                let room = roomDataSource.retrieveRoomWithId(roomID)
                self.navigationController?.pushViewController(ChatViewController(room: room), animated: true)
            }
            else
            {
                self.navigationController?.pushViewController(InboxViewController(roomID: nil, flipMessageID: nil), animated: true)
            }
            
        })
        
        
        
    }
    
    func newFlipViewController(viewController: NewFlipViewController, didSendMessageToRoom roomID: String, withExternal messageComposer: MessageComposerExternal? = nil) {
        
        
    }
}
