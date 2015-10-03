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

import UIKit

class SettingsView: UIView, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private let LOGOUT_BUTTON_HEIGHT    : CGFloat = 55.0
    private let IMAGE_BUTTONS_WIDTH     : CGFloat = 92.0
    private let USER_PROFILE_CELL_HEIGHT: CGFloat = 95.0
    private let ACTION_ROW_HEIGHT       : CGFloat = 60.0
    
    private let NUMBER_OF_ROWS                      : Int = 7
    private let NUMBER_OF_ACTION_ROWS               : Int = 6
    
    private let USER_PROFILE_CELL_POSITION          : Int = 0
    
    private let IMPORT_CONTACTS_CELL_POSITION       : Int = 1
    private let CHANGE_NUMBER_CELL_POSITION         : Int = 2
    private let SEND_FEEDBACK_CELL_POSITION         : Int = 3
//    private let TUTORIAL_CELL_POSITION              : Int = 4
    private let ABOUT_CELL_POSITION                 : Int = 4
    private let TERMS_OF_USE_PROFILE_CELL_POSITION  : Int = 5
    private let PRIVACY_POLICY_CELL_POSITION        : Int = 6


    weak var delegate: SettingsViewDelegate?
    
    private var tableFooterView: UIView!
    private var logoutButton: UIButton!
    private var tableView: UITableView!
    private var userProfileCell: SettingsTableViewCell!
    private var aboutCell: SettingsTableViewCell!
    private var termsOfUseCell: SettingsTableViewCell!
    private var privacyPolicyCell: SettingsTableViewCell!
    private var sendFeedbackCell: SettingsTableViewCell!
    private var changeNumberCell: SettingsTableViewCell!
    private var importContactsCell: SettingsTableViewCell!
//    private var tutorialCell: SettingsTableViewCell!
    
    init() {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resyncNotificationReceived:", name: RESYNC_INBOX_NOTIFICATION_NAME, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: RESYNC_INBOX_NOTIFICATION_NAME, object: nil)
    }
    
    func viewWillAppear() {
        if let selected = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selected, animated: true)
        }
         self.updateUserProfileInfo()
    }
    
    func viewDidAppear() {
        self.updateUserProfileInfo()
    }
    
    func viewDidLoad() {
        self.makeConstraints()
    }
    
    override func layoutSubviews() {
        let actionRowsNumber: Int = NUMBER_OF_ROWS - 1
        let sectionHeight = USER_PROFILE_CELL_HEIGHT + ( CGFloat(NUMBER_OF_ACTION_ROWS) * ACTION_ROW_HEIGHT)
        var tableFooterViewHeight = self.tableView.frame.size.height - sectionHeight
        
        if (tableFooterViewHeight < LOGOUT_BUTTON_HEIGHT) {
            tableFooterViewHeight = LOGOUT_BUTTON_HEIGHT
        }
        
        tableFooterView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableFooterViewHeight)
        self.tableView.tableFooterView = tableFooterView
        super.layoutSubviews()
    }
    
    private func addSubviews() {
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor.sand()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorInset = UIEdgeInsetsMake(0, self.IMAGE_BUTTONS_WIDTH, 0, 0)
        self.addSubview(tableView)
        
        tableFooterView = UIView()
        tableFooterView.backgroundColor = UIColor.clearColor()
        
        logoutButton = UIButton()
        logoutButton.addTarget(self, action: "logOutButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        logoutButton.backgroundColor = UIColor.whiteColor()
        logoutButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        logoutButton.setTitleColor(UIColor.flipOrange(), forState: UIControlState.Normal)
        logoutButton.setTitle(NSLocalizedString("Log Out", comment: "Log Out"), forState: UIControlState.Normal)
        tableFooterView.addSubview(logoutButton)
        
        self.createUserProfileCell()
        self.createAboutCell()
        self.createTermsOfUseCell()
        self.createPrivacyPolicyCell()
        self.createFeedbackCell()
        self.createChangeNumberCell()
        self.createImportContactsCell()
        //self.createTutorialCell()
    }
    
    private func makeConstraints() {
        
        tableView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.settingsViewMakeConstraintToNavigationBarBottom(self.tableView)
        
        logoutButton.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.tableFooterView)
            make.left.equalTo()(self.tableFooterView)
            make.right.equalTo()(self.tableFooterView)
            make.height.equalTo()(self.LOGOUT_BUTTON_HEIGHT)
        }
    }
    
    func logOutButtonTapped(sender: AnyObject?) {
        self.delegate?.settingsViewDidTapLogOutButton(self)
    }
    
    func resyncNotificationReceived(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.userProfileCell.setActionDetailLabelText(NSLocalizedString("Updating..."));
        })
    }
    
    
    // MARK: - Required inits

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.NUMBER_OF_ROWS
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.row) {
        case self.USER_PROFILE_CELL_POSITION:
            return self.userProfileCell
            
        case self.ABOUT_CELL_POSITION:
            return self.aboutCell
            
        case self.TERMS_OF_USE_PROFILE_CELL_POSITION:
            return self.termsOfUseCell
            
        case self.PRIVACY_POLICY_CELL_POSITION:
            return self.privacyPolicyCell
            
        case self.SEND_FEEDBACK_CELL_POSITION:
            return self.sendFeedbackCell
            
        case self.CHANGE_NUMBER_CELL_POSITION:
            return self.changeNumberCell
            
        case self.IMPORT_CONTACTS_CELL_POSITION:
            return self.importContactsCell
            
//        case self.TUTORIAL_CELL_POSITION:
//            return self.tutorialCell
            
        default:
            print("Error creating row number: \(indexPath.row)")
            fatalError("Unknown row")
        }
    }
    
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.row == 0) {
            return self.USER_PROFILE_CELL_HEIGHT
        }
        
        return self.ACTION_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch(indexPath.row) {
        case self.USER_PROFILE_CELL_POSITION:
            self.delegate?.settingsViewDidTapChangeProfile(self)
            
        case self.ABOUT_CELL_POSITION:
            self.delegate?.settingsViewDidTapAbout(self)
            
        case self.TERMS_OF_USE_PROFILE_CELL_POSITION:
            self.delegate?.settingsViewDidTapTermsOfUse(self)
            
        case self.PRIVACY_POLICY_CELL_POSITION:
            self.delegate?.settingsViewDidTapPrivacyPolicy(self)
            
        case self.SEND_FEEDBACK_CELL_POSITION:
            self.delegate?.settingsViewDidTapSendFeedback(self)
            
        case self.CHANGE_NUMBER_CELL_POSITION:
            self.delegate?.settingsViewDidTapChangePhoneNumber(self)
            
        case self.IMPORT_CONTACTS_CELL_POSITION:
            self.delegate?.settingsViewDidTapImportContacts(self)
            
//        case self.TUTORIAL_CELL_POSITION:
//            self.delegate?.settingsViewDidTapTutorialButton(self)
            
        default:
            print("Error creating row number: \(indexPath.row)")
            fatalError("Unknown row")
        }
    }


    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let tableHeight = self.tableView.bounds.size.height
        var contentHeight = scrollView.contentSize.height
        
        if (contentHeight < tableHeight) {
            contentHeight = tableHeight
        }
        
        let bottomOffset = offsetY + tableHeight - contentHeight
        self.tableFooterView.transform = CGAffineTransformMakeTranslation(0, max(bottomOffset, 0))
    }

    
    // MARK: Cell creation methods
    
    private func createUserProfileCell() {
        
        if (self.userProfileCell == nil) {
            if let loggedUser = User.loggedUser() {
                let detailedLabel = loggedUser.username + "\n" + loggedUser.formattedPhoneNumber()
                let fullname = loggedUser.fullName()
                
                self.userProfileCell = SettingsTableViewCell(image: UIImage(named: "Placeholder"), labelText: fullname, detailLabel: detailedLabel)
                if let photoURL = loggedUser.photoURL {
                    userProfileCell.setAvatarURL(photoURL)
                }
            }
        }
    }
    
    private func createAboutCell() {
        if (self.aboutCell == nil) {
            self.aboutCell = SettingsTableViewCell(image: UIImage(named: "About"), labelText: NSLocalizedString("About", comment: "About"), detailLabel: nil)
        }
    }
    
    private func createTermsOfUseCell() {
        
        if (self.termsOfUseCell == nil) {
            self.termsOfUseCell = SettingsTableViewCell(image: UIImage(named: "Terms"), labelText: NSLocalizedString("Terms of Use", comment: "Terms of Use"), detailLabel: nil)
        }
    }
    
    private func createPrivacyPolicyCell() {
        
        if (self.privacyPolicyCell == nil) {
            self.privacyPolicyCell = SettingsTableViewCell(image: UIImage(named: "Privacy"), labelText: NSLocalizedString("Privacy Policy", comment: "Privacy Policy"), detailLabel: nil)
        }
    }
    
    private func createFeedbackCell() {
        
        if (self.sendFeedbackCell == nil) {
            self.sendFeedbackCell = SettingsTableViewCell(image: UIImage(named: "Feedback"), labelText: NSLocalizedString("Send Feedback", comment: "Send Feedback"), detailLabel: nil)
        }
    }
    
    private func createChangeNumberCell() {
        
        if (self.changeNumberCell == nil) {
            self.changeNumberCell = SettingsTableViewCell(image: UIImage(named: "ChangePhone"), labelText: NSLocalizedString("Change Number", comment: "Change Number"), detailLabel: nil)
        }
    }
    
    private func createImportContactsCell() {
        
        if (self.importContactsCell == nil) {
            self.importContactsCell = SettingsTableViewCell(image: UIImage(named: "ImportContact"), labelText: NSLocalizedString("Import Contacts", comment: "Import Contacts"), detailLabel: nil)
        }
    }
    
//    private func createTutorialCell() {
//        
//        if (self.tutorialCell == nil) {
//            self.tutorialCell = SettingsTableViewCell(image: UIImage(named: "TutorialCell"), labelText: NSLocalizedString("Play Tutorial", comment: "Play Tutorial"), detailLabel: nil)
//        }
//    }
    
    
    // MARK: - Setters
    func updateUserProfileInfo() {
		if let loggedUser = User.loggedUser() {
			let detailedLabel = loggedUser.username + "\n" + loggedUser.formattedPhoneNumber()

			let fullname = loggedUser.fullName()
			
			self.userProfileCell.setAvatarURL(loggedUser.photoURL)
			self.userProfileCell.setActionLabelText(fullname)
			self.userProfileCell.setActionDetailLabelText(detailedLabel)

		}
	}
}

protocol SettingsViewDelegate: class {
    func settingsViewMakeConstraintToNavigationBarBottom(tableView: UIView!)
    func settingsViewDidTapAbout(settingsView: SettingsView)
    func settingsViewDidTapChangeProfile(settingsView: SettingsView)
    func settingsViewDidTapTermsOfUse(settingsView: SettingsView)
    func settingsViewDidTapPrivacyPolicy(settingsView: SettingsView)
    func settingsViewDidTapSendFeedback(settingsView: SettingsView)
    func settingsViewDidTapChangePhoneNumber(settingsView: SettingsView)
    func settingsViewDidTapImportContacts(settingsView: SettingsView)
    func settingsViewDidTapTutorialButton(settingsView: SettingsView)
    func settingsViewDidTapLogOutButton(settingsView: SettingsView)
}