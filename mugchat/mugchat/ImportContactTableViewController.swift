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

class ImportContactsTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let CONTACT_TABLE_VIEW_IDENTIFIER: String! = "ContactTableViewCell"
    private let IMPORT_CONTACTS_TIMEOUT: dispatch_time_t = 10
    private let LABEL_MARGIN_LEFT: CGFloat = 10.0
    private let LABEL_MARGIN_RIGHT: CGFloat = -15.0
    private let CELL_HEIGHT: CGFloat = 56.0
    private let HEADER_HEIGHT: CGFloat = 25.0
    
    private var contactsWithFlipsAccount: [Contact]!
    private var contactsWithoutFlipsAccount: [Contact]!
    private var contactsOnFlipsHeaderView: UIView!
    private var everyoneElseHeaderView: UIView!

    override init() {
        super.init(style: UITableViewStyle.Plain)
        let contactDataSource = ContactDataSource()
        self.contactsWithoutFlipsAccount = contactDataSource.getMyContactsWithoutFlipsAccount()
        self.contactsWithFlipsAccount = contactDataSource.getMyContactsWithFlipsAccount()
        
        self.contactsOnFlipsHeaderView = createContactsOnFlipsHeaderView()
        self.everyoneElseHeaderView = createEveryoneElseHeaderView()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.setupWhiteNavBarWithCancelButton("Contacts")
        super.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.deepSea()]
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    
        self.tableView.registerNib(UINib(nibName: CONTACT_TABLE_VIEW_IDENTIFIER, bundle: nil), forCellReuseIdentifier: CONTACT_TABLE_VIEW_IDENTIFIER)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        let group = dispatch_group_create()
        
        dispatch_group_enter(group)
                ContactListHelper.sharedInstance.findAllContactsWithPhoneNumber({ (contacts) -> Void in
            let contactDataSource = ContactDataSource()
            self.contactsWithFlipsAccount = contactDataSource.getMyContactsWithFlipsAccount()
            self.contactsWithoutFlipsAccount = contactDataSource.getMyContactsWithoutFlipsAccount()
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
            self.tableView.reloadData()
            dispatch_group_leave(group)
            }, failure: { (error) -> Void in
            ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                println("Couln't retrieve the contact list.")
                dispatch_group_leave(group)
        })
        
        dispatch_group_wait(group, self.IMPORT_CONTACTS_TIMEOUT)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return self.contactsOnFlipsHeaderView
        }
        
        if (section == 1) {
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.contactsWithFlipsAccount.count
        }
        
        if (section == 1) {
            return self.contactsWithoutFlipsAccount.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CONTACT_TABLE_VIEW_IDENTIFIER) as ContactTableViewCell
        
        var contact: Contact!
        
        if (indexPath.section == 0) {
            contact = self.contactsWithFlipsAccount[indexPath.row]
            cell.photoView.setImageWithURL(NSURL(string:contact.contactUser.photoURL)!)
        } else if (indexPath.section == 1) {
            contact = self.contactsWithoutFlipsAccount[indexPath.row]
        }

        cell.nameLabel.text = contact.contactTitle
        cell.numberLabel.text = "\(contact.phoneNumber) \(contact.phoneType)"
        let firstCharFirstName = String(Array(contact.firstName)[0])
        var firstCharLastName = ""
        
        if (contact.lastName != nil && countElements(contact.lastName) > 0) {
            firstCharLastName = String(Array(contact.lastName)[0])
        }

        cell.photoView.initials = "\(firstCharFirstName)\(firstCharLastName)"
        
        return cell
    }
    
}
