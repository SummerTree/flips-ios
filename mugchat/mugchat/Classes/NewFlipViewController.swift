//
//  NewFlipViewController.swift
//  mugchat
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

import UIKit

private let STORYBOARD = "NewFlip"


class NewFlipViewController: MugChatViewController,
    JoinStringsTextFieldDelegate,
    MBContactPickerDataSource,
    MBContactPickerDelegate,
    UIAlertViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate {
    
    // MARK: - Constants
    
    private let CANCEL_MESSAGE = NSLocalizedString("This will delete any text you have written for this message.  Do you wish to delete this message?", comment: "Cancel message")
    private let CANCEL_TITLE = NSLocalizedString("Delete Message", comment: "Delete Message")
    private let DELETE = NSLocalizedString("Delete", comment: "Delete")
    private let NO = NSLocalizedString("No", comment: "No")
    private let TITLE = NSLocalizedString("New Flip", comment: "New Flip")
    
    // MARK: - Class methods
    
    class func instantiateNavigationController() -> UINavigationController {
        let storyboard = UIStoryboard(name: STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as UINavigationController
        navigationController.topViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
        return navigationController
    }
    
    // MARK: - Instance variables
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactPicker: MBContactPicker!
    @IBOutlet weak var contactPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flipTextField: JoinStringsTextField!
    @IBOutlet weak var flipTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flipView: UIView!
    @IBOutlet weak var nextButtonAction: UIButton!

    let contactDataSource = ContactDataSource()
    var fetchedResultsController: NSFetchedResultsController?
    var didPressReturn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWhiteNavBarWithCancelButton(TITLE)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.contactPicker.datasource = self
        self.contactPicker.delegate = self
        self.contactPicker.backgroundColor = .sand()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        struct Holder {
            static var flipViewUpperBorderLayer :CALayer!
        }
        
        if (Holder.flipViewUpperBorderLayer == nil) {
            Holder.flipViewUpperBorderLayer = CALayer()
            Holder.flipViewUpperBorderLayer.backgroundColor = UIColor.lightGreyF2().CGColor
            [self.flipView.layer.addSublayer(Holder.flipViewUpperBorderLayer)]
        }
        
        Holder.flipViewUpperBorderLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.flipView.frame), 1.0)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.updateHeightConstraintIfNeeded(self.flipTextFieldHeightConstraint, view: self.flipTextField)
        
        // TODO: Refactor
//        self.updateHeightConstraintIfNeeded(self.toTextViewHeightConstraint, view: self.toTextView)
    }
    
    // MARK: - Private methods
    
    private func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func updateContactPickerHeight(newHeight: CGFloat) {
        self.contactPickerHeightConstraint.constant = newHeight
        self.view.animateConstraintWithDuration(NSTimeInterval(contactPicker.animationSpeed))
    }
    
    private func updateHeightConstraintIfNeeded(heightConstraint: NSLayoutConstraint, view: UIScrollView) {
        let maxHeight = CGRectGetHeight(self.view.frame)/2
        var neededHeight = view.contentSize.height
        
        if (neededHeight > maxHeight) {
            neededHeight = maxHeight
            view.contentOffset = CGPointZero
        }
        
        if (neededHeight != heightConstraint.constant) {
            heightConstraint.constant = neededHeight
        }
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonAction(sender: UIButton) {
        
    }
    
    override func closeButtonTapped() {
        if !flipTextField.hasText() {
            super.closeButtonTapped()
        } else {
            let alertView = UIAlertView(title: CANCEL_TITLE, message: CANCEL_MESSAGE, delegate: self, cancelButtonTitle: NO, otherButtonTitles: DELETE)
            alertView.show()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let kbFrame = info[UIKeyboardFrameEndUserInfoKey] as NSValue
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
            let keyboardFrame = kbFrame.CGRectValue()
            let height = CGRectGetHeight(keyboardFrame)

            self.bottomConstraint.constant = height
            self.view.animateConstraintWithDuration(animationDuration)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let info = notification.userInfo {
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as NSNumber).doubleValue
            
            self.bottomConstraint.constant = 0
            self.view.animateConstraintWithDuration(animationDuration)
        }
    }
    
    // MARK: - JointStringsTextFieldDelegate
    
    func joinStringsTextFieldNeedsToHaveItsHeightUpdated(joinStringsTextField: JoinStringsTextField!) {
        self.view.setNeedsUpdateConstraints()
    }
    
    // MARK: - MBContactPickerDataSource
    
    // Use this method to give the contact picker the entire set of possible contacts.  Required.
    func contactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        return Contact.findAllSortedBy(contactDataSource.sortedByUserFirstNameLastName())
    }
    
    func selectedContactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        return [];
    }
    
    // MARK: - MBContactPickerDelegate
    
    // Optional
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didSelectContact model: MBContactPickerModelProtocol!) {
        println("Did Select: \(model.contactTitle)")
    }
    
    // Optional
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didAddContact model: MBContactPickerModelProtocol!) {
        println("Did Add: \(model.contactTitle)")
    }
    
    // Optional
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didRemoveContact model: MBContactPickerModelProtocol!) {
        println("Did Remove: \(model.contactTitle)")
    }
    
    // Optional
    // This delegate method is called to allow the parent view to increase the size of
    // the contact picker view to show the search table view
    func didShowFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        if (self.contactPickerHeightConstraint.constant <= contactPicker.currentContentHeight) {
            let pickerRectInWindow = self.view.convertRect(contactPicker.frame, fromView: nil)
            let newHeight = self.view.window!.bounds.size.height - pickerRectInWindow.origin.y - contactPicker.keyboardHeight
            self.updateContactPickerHeight(newHeight)
        }
    }
    
    // Optional
    // This delegate method is called to allow the parent view to decrease the size of
    // the contact picker view to hide the search table view
    func didHideFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        if (self.contactPickerHeightConstraint.constant > contactPicker.currentContentHeight) {
            self.updateContactPickerHeight(contactPicker.currentContentHeight)
        }
    }
    
    // Optional
    // This delegate method is invoked to allow the parent to increase the size of the
    // collectionview that shows which contacts have been selected. To increase or decrease
    // the number of rows visible, change the maxVisibleRows property of the MBContactPicker
    func contactPicker(contactPicker: MBContactPicker!, didUpdateContentHeightTo newHeight: CGFloat) {
        self.updateContactPickerHeight(newHeight)
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            super.closeButtonTapped()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController?.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let contact = self.fetchedResultsController?.objectAtIndexPath(indexPath) as Contact
        let cell = tableView.dequeueReusableCellWithIdentifier(ContactTableViewCellIdentifier, forIndexPath: indexPath) as ContactTableViewCell;
        cell.nameLabel.text = "\(contact.firstName) \(contact.lastName)"
        cell.photoView.initials = "\(contact.firstName[contact.firstName.startIndex])\(contact.lastName[contact.lastName.startIndex])"
        
        if let user = contact.contactUser {
            // Flips user
            cell.photoView.borderColor = .mugOrange()
            
            if let photoURLString = user.photoURL {
                if let url = NSURL(string: photoURLString) {
                    cell.photoView.setImageWithURL(url)
                }
            }
            
            cell.hideNumberLabel()
        } else {
            // not a Flips user
            cell.numberLabel?.text = contact.phoneNumber
        }
        
        return cell
    }
    
}
