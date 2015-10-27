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
    UITextViewDelegate,
    FlipsCompositionControllerDelegate {

    // MARK: - Constants
    
    private let TITLE = NSLocalizedString("New Flip", comment: "New Flip")
    private let INVALID_CONTACT_TITLE = NSLocalizedString("Invalid Contact", comment: "Invalid Contact")
    private let INVALID_CONTACT_MESSAGE = NSLocalizedString("Please choose a valid contact.", comment: "Please choose a valid contact.")
    private let MESSAGE_PLACEHOLDER = NSLocalizedString("Type your message here...", comment: "Type your message here...")
    private let EMPTY_MESSAGE_TITLE = NSLocalizedString("Empty Message", comment: "Empty Message")
    private let EMPTY_MESSAGE_MESSAGE = NSLocalizedString("Please input a message.", comment: "Please input a message.")
    
    private let ONBOARDING_KEY = "NewFlipOverlayShown"
    
    weak var delegate: NewFlipViewControllerDelegate?
    
    // MARK: - Class methods
    
    class func instantiateNavigationController(contact: Contact? = nil) -> UINavigationController {
        let storyboard = UIStoryboard(name: STORYBOARD, bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController

        if (contact != nil) {
            if let viewController = navigationController.topViewController as? NewFlipViewController {
                viewController.contacts.append(contact!)
            }
        }

        navigationController.topViewController?.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        
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
    @IBOutlet weak var buttonPanelView: UIView!
    @IBOutlet weak var buttonPanel2View: UIView!
    
    private var overlayView : UIImageView!

    let contactDataSource = ContactDataSource()
    var contacts: [Contact] {
        didSet {
            if (self.nextButton != nil) {
                updateNextButtonState()
            }
        }
    }
    
    var optionButtons : [FlipsSendButton]

    required init?(coder: NSCoder) {
        contacts = [Contact]()
        optionButtons = [FlipsSendButton]()
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWhiteNavBarWithCancelButton(TITLE)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.flipTextField.joinStringsTextFieldDelegate = self
        self.flipTextField.delegate = self;
        self.flipTextField.text = MESSAGE_PLACEHOLDER
        self.flipTextField.textColor = UIColor.lightGrayColor()
        
        self.contactPicker.datasource = self
        self.contactPicker.delegate = self
        self.contactPicker.backgroundColor = .sand()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.buttonPanel2View.hidden = true
        
        layoutSendButtons()
        updateNextButtonState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        registerForKeyboardNotifications()
        
        self.flipTextField.setupMenu()
        
        if shouldShowOnboarding()
        {
            setupOnboarding()
        }
        else if self.contacts.isEmpty
        {
            self.contactPicker.becomeFirstResponder()
        }
        else
        {
            self.flipTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        handleReplyTextFieldSize()
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
            
            overlayView = UIImageView(image: UIImage(named: "New Flip Overlay"))
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
    
    // MARK: - Private methods
    
    private func layoutSendButtons() {
        
        let firstRowButtonCount = 2
        let secondRowButtonCount = 3
        
        let flipsSendButton = FlipsSendButton(buttonCount: firstRowButtonCount,
                                              buttonOrder: 0,
                                              buttonHeight: self.buttonPanelView.frame.size.height,
                                              activeColor: UIColor.flipOrange(),
                                              buttonType: .Flips,
                                              imageName: "FlipWord",
                                              allowedToBeInactive: false)
        
        let smsSendButton = FlipsSendButton(buttonCount: firstRowButtonCount,
                                            buttonOrder: 1,
                                            buttonHeight: self.buttonPanelView.frame.size.height,
                                            activeColor: UIColor.avacado(),
                                            buttonType: .SMS,
                                            imageName: "smsicon",
                                            allowedToBeInactive: true)
        
        let facebookButton = FlipsSendButton(buttonCount: secondRowButtonCount,
                                            buttonOrder: 0,
                                            buttonHeight: self.buttonPanel2View.frame.size.height,
                                            activeColor: UIColor.facebookBlue(),
                                            buttonType: .Facebook,
                                            imageName: "Facebook",
                                            allowedToBeInactive: true)
        
        let twitterButton = FlipsSendButton(buttonCount: secondRowButtonCount,
                                            buttonOrder: 1,
                                            buttonHeight: self.buttonPanel2View.frame.size.height,
                                            activeColor: UIColor.twitterBlue(),
                                            buttonType: .Twitter,
                                            imageName: "Twitter",
                                            allowedToBeInactive: true)
        
        let instagramButton = FlipsSendButton(buttonCount: secondRowButtonCount,
                                            buttonOrder: 2,
                                            buttonHeight: self.buttonPanel2View.frame.size.height,
                                            activeColor: UIColor.instagramBlue(),
                                            buttonType: .Instagram,
                                            imageName: "Instagram",
                                            allowedToBeInactive: true)
        
        smsSendButton.makeInactive()
        facebookButton.makeInactive()
        twitterButton.makeInactive()
        instagramButton.makeInactive()
        
        self.optionButtons += [smsSendButton,facebookButton,twitterButton,instagramButton]
        
        self.buttonPanelView.addSubview(flipsSendButton)
        self.buttonPanelView.addSubview(smsSendButton)
        
        self.buttonPanel2View.addSubview(facebookButton)
        self.buttonPanel2View.addSubview(twitterButton)
        self.buttonPanel2View.addSubview(instagramButton)
        
    }
    
    private func updateSendOptions() {
        for contact : Contact in self.contacts {
            if contact.contactUser == nil {
                shouldLockSendOptions(true)
                return
            }
        }
        shouldLockSendOptions(false)
    }
    
    private func shouldLockSendOptions(lock: Bool) {
        if lock {
            for optionButton in self.optionButtons {
                if optionButton.sendButtonType == .SMS {
                    optionButton.makeActive()
                    optionButton.allowedToBeInactive = false
                }
            }
        }
        else {
            for optionButton in self.optionButtons {
                optionButton.allowedToBeInactive = true
            }
        }
        
    }
    
    private func retrieveSendOptions() -> [FlipsSendButtonOption] {
        var options = Array<FlipsSendButtonOption>()
        
        for optionButton : FlipsSendButton in self.optionButtons {
            if optionButton.isButtonActive {
                options += [optionButton.sendButtonType]
            }
        }
        
        return options
    }
    
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
        let textValue = flipTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let hasText = Bool(textValue != MESSAGE_PLACEHOLDER)
        
        nextButton.enabled = hasContacts && hasText
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonAction(sender: UIButton) {
        
        flipTextField.endEditing(true)
        
        if (self.contactPicker.invalidContact)
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                let alertView = UIAlertView(title: self.INVALID_CONTACT_TITLE,
                                            message: self.INVALID_CONTACT_MESSAGE,
                                            delegate: nil,
                                            cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                
            }
        }
        else if (flipTextField.text == MESSAGE_PLACEHOLDER)
        {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                let alertView = UIAlertView(title: self.EMPTY_MESSAGE_TITLE,
                    message: self.EMPTY_MESSAGE_MESSAGE,
                    delegate: nil,
                    cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                self.flipTextField.becomeFirstResponder()
                
            }
        }
        else
        {
            let createNewRoom = { () -> Void in
                
                let compositionController = FlipMessageCompositionVC(sendOptions: self.retrieveSendOptions(), contacts: self.contacts, words: self.flipTextField.getTextWords())
                compositionController.delegate = self
                compositionController.contacts = self.contacts
                
                self.navigationController?.pushViewController(compositionController, animated: true)
                
            }
            
            self.draftingTable!.resetDraftingTable()
            self.draftingTable!.contacts = self.contacts
            self.draftingTable!.sendOptions = self.retrieveSendOptions()
            
            var userIDs = [String]()
            for contact in self.contacts
            {
                if (contact.contactUser == nil)
                {
                    createNewRoom()
                    return
                }
                
                userIDs.append(contact.contactUser.userID)
            }
            
            let roomDataSource = RoomDataSource()
            let result = roomDataSource.hasRoomWithUserIDs(userIDs)
            if (result.hasRoom)
            {
                self.draftingTable!.room = result.room!
                
                let compositionController = FlipMessageCompositionVC(sendOptions: self.retrieveSendOptions(), roomID: result.room!.roomID, compositionTitle: result.room!.roomName(), words: flipTextField.getTextWords())
                compositionController.delegate = self
                compositionController.contacts = self.contacts
                
                self.navigationController?.pushViewController(compositionController, animated: true)
                
                return
            }
            
            createNewRoom()
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let kbFrame = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let keyboardFrame = kbFrame.CGRectValue()
            let height = CGRectGetHeight(keyboardFrame)

            self.bottomConstraint.constant = height
            self.view.animateConstraintWithDuration(animationDuration)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let info = notification.userInfo {
            let animationDuration = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            
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
            updateSendOptions()
        }
    }
    
    func contactCollectionView(contactCollectionView: MBContactCollectionView!, didRemoveContact model: MBContactPickerModelProtocol!) {
        if let contact = model as? Contact {
            if let index = contacts.indexOf(contact) {
                contacts.removeAtIndex(index)
                updateSendOptions()
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
    
    //MARK: UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        updateNextButtonState()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = MESSAGE_PLACEHOLDER
            textView.textColor = UIColor.lightGrayColor()
        }
        updateNextButtonState()
    }
    
    // MARK: - ComposeViewControllerDelegate
    
    func composeViewController(viewController: ComposeViewController, didSendMessageToRoom roomID: String, withExternal messageComposer: MessageComposerExternal?) {
        //delegate?.newFlipViewController(self, didSendMessageToRoom: roomID, withExternal: messageComposer)
    }
    
    func composeViewController(viewController: ComposeViewController, didChangeFlipWords words: [String]) {
        //self.flipTextField.setWords(words)
    }
    
    ////
    // MARK: - FlipsCompositionControllerDelegate
    // This is redundant with the above ComposeViewControllerDelegate. Since it can't be safely removed yet
    // I've had to create duplicate functionality. In the future the one of these should be removed
    ////
    
    func didBeginSendingMessageToRoom(roomID: String!) {
        delegate?.didBeginSendingMessageToRoom(roomID)
    }
    
    

}

protocol NewFlipViewControllerDelegate: class {
    func didBeginSendingMessageToRoom(roomID: String!)
}
