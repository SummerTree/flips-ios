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

private let STORYBOARD = "NewFlip"


class NewFlipViewController: FlipsViewController,
    JoinStringsTextFieldDelegate,
    MBContactPickerDataSource,
    MBContactPickerDelegate,
    UIAlertViewDelegate,
    UITextViewDelegate,
    ComposeViewControllerDelegate {

    // MARK: - Constants
    
    private let CANCEL_MESSAGE = NSLocalizedString("This will delete any text you have written for this message.  Do you wish to delete this message?", comment: "Cancel message")
    private let CANCEL_TITLE = NSLocalizedString("Delete Message", comment: "Delete Message")
    private let DELETE = NSLocalizedString("Delete", comment: "Delete")
    private let NO = NSLocalizedString("No", comment: "No")
    private let TITLE = NSLocalizedString("New Flip", comment: "New Flip")
    private let INVALID_CONTACT_TITLE = NSLocalizedString("Invalid Contact", comment: "Invalid Contact")
    private let INVALID_CONTACT_MESSAGE = NSLocalizedString("Please choose a valid contact.", comment: "Please choose a valid contact.")
    
    weak var delegate: NewFlipViewControllerDelegate?
    
    // MARK: - Class methods
    
    class func instantiateNavigationController(contact: Contact? = nil) -> UINavigationController {
        let storyboard = UIStoryboard(name: STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as UINavigationController

        if (contact != nil) {
            if let viewController = navigationController.topViewController as? NewFlipViewController {
                viewController.contacts.append(contact!)
            }
        }

        navigationController.topViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
        return navigationController
    }
    
    // MARK: - Instance variables
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contactPicker: MBContactPicker!
    @IBOutlet weak var contactPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flipTextField: JoinStringsTextField!
    @IBOutlet weak var flipTextFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flipView: TopBorderedView!
    @IBOutlet weak var nextButton: NextButton!

    let contactDataSource = ContactDataSource()
    var contacts: [Contact] {
        didSet {
            if (self.nextButton != nil) {
                updateNextButtonState()
            }
        }
    }

    required init(coder: NSCoder) {
        contacts = [Contact]()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWhiteNavBarWithCancelButton(TITLE)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.flipTextField.joinStringsTextFieldDelegate = self
        
        self.contactPicker.datasource = self
        self.contactPicker.delegate = self
        self.contactPicker.backgroundColor = .sand()
        self.automaticallyAdjustsScrollViewInsets = false
        updateNextButtonState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        registerForKeyboardNotifications()
        
        self.flipTextField.setupMenu()

        if self.contacts.isEmpty {
            self.contactPicker.becomeFirstResponder()
        } else {
            self.flipTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        handleReplyTextFieldSize()
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
    
    private func handleReplyTextFieldSize() {
        var textFieldHeight = flipTextField.DEFAULT_HEIGHT
        if (flipTextField.numberOfLines > 1) {
            textFieldHeight = flipTextField.DEFAULT_HEIGHT+flipTextField.DEFAULT_LINE_HEIGHT
        }
        
        flipTextFieldHeightConstraint.constant = textFieldHeight
        flipTextField.handleMultipleLines(textFieldHeight)
    }
    
    private func updateNextButtonState() {
        let hasContacts = contacts.count > 0
        let hasText = !flipTextField.text.removeWhiteSpaces().isEmpty
        nextButton.enabled = hasContacts && hasText
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonAction(sender: UIButton) {
        
        if (self.contactPicker.invalidContact) {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                let alertView = UIAlertView(title: self.INVALID_CONTACT_TITLE, message: self.INVALID_CONTACT_MESSAGE, delegate: nil, cancelButtonTitle: LocalizedString.OK)
                alertView.show()
            }
        } else {
            let createNewRoom = { () -> Void in
                let composeViewController = ComposeViewController(contacts: self.contacts, words: self.flipTextField.getTextWords())
                composeViewController.delegate = self
                self.navigationController?.pushViewController(composeViewController, animated: true)
            }
            
            var userIDs = [String]()
            for contact in self.contacts {
                if (contact.contactUser == nil) {
                    createNewRoom()
                    return
                }
                userIDs.append(contact.contactUser.userID)
            }
            
            let roomDataSource = RoomDataSource()
            var result = roomDataSource.hasRoomWithUserIDs(userIDs)
            if (result.hasRoom) {
                let composeViewController = ComposeViewController(roomID: result.room!.roomID, composeTitle: result.room!.roomName(), words: flipTextField.getTextWords())
                composeViewController.delegate = self
                self.navigationController?.pushViewController(composeViewController, animated: true)
                return
            }
            
            createNewRoom()
        }
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
    
    func joinStringsTextField(joinStringsTextField: JoinStringsTextField, didChangeText: String!) {
        handleReplyTextFieldSize()
        updateNextButtonState()
    }
    
    func joinStringsTextFieldShouldReturn(joinStringsTextField: JoinStringsTextField) -> Bool {
        if (nextButton.enabled) {
            self.nextButtonAction(self.nextButton)
            return true
        }
        return false
    }
    
    // MARK: - MBContactPickerDataSource
    
    func contactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        return contactDataSource.getMyContactsSortedByUsersFirst()
    }
    
    func selectedContactModelsForContactPicker(contactPickerView: MBContactPicker!) -> [AnyObject]! {
        return self.contacts;
    }
    
    // MARK: - MBContactPickerDelegate
    
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didAddContact model: MBContactPickerModelProtocol!) {
        if let contact = model as? Contact {
            contacts.append(contact)
        }
    }
    
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didRemoveContact model: MBContactPickerModelProtocol!) {
        if let contact = model as? Contact {
            if let index = find(contacts, contact) {
                contacts.removeAtIndex(index)
            }
        }
    }
    
    func didShowFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        if (self.contactPickerHeightConstraint.constant <= contactPicker.currentContentHeight) {
            let pickerRectInWindow = self.view.convertRect(contactPicker.frame, fromView: nil)
            let newHeight = self.view.window!.bounds.size.height - pickerRectInWindow.origin.y - contactPicker.keyboardHeight
            self.updateContactPickerHeight(newHeight)
        }
    }
    
    func didHideFilteredContactsForContactPicker(contactPicker: MBContactPicker!) {
        if (self.contactPickerHeightConstraint.constant > contactPicker.currentContentHeight) {
            self.updateContactPickerHeight(contactPicker.currentContentHeight)
        }
    }
    
    func contactPicker(contactPicker: MBContactPicker!, didChangeEntryText entryText: String!) {
        updateNextButtonState()
    }
    
    func contactPicker(contactPicker: MBContactPicker!, didUpdateContentHeightTo newHeight: CGFloat) {
        self.updateContactPickerHeight(newHeight)
    }
    
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            super.closeButtonTapped()
        }
    }
    
    
    // MARK: - ComposeViewControllerDelegate
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String) {
        delegate?.newFlipViewController(self, didSendMessageToRoom: roomID)
    }
    
    func composeViewController(viewController: ComposeViewController, didChangeFlipWords words: [String]) {
        self.flipTextField.setWords(words)
    }

}

protocol NewFlipViewControllerDelegate: class {
    
    func newFlipViewController(viewController: NewFlipViewController, didSendMessageToRoom roomID: String)
    
}
