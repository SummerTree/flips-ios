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
    FlipsCompositionControllerDelegate,
    UITableViewDelegate,
    UITableViewDataSource {

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
    @IBOutlet weak var suggestedTable: UITableView!
    @IBOutlet weak var cellView: UIView!

    let contactDataSource = ContactDataSource()
    var contacts: [Contact] {
        didSet {
            if (self.nextButton != nil) {
                updateNextButtonState()
            }
        }
    }
    
    var optionButtons : [FlipsSendButton]
    var allFlips : [Flip]
    var filteredFlips : [Flip]
    var flipsAppended : [String]
    var manuallyJoinedFlips : [String]
    var flipsManuallyJoinedPlusAppended : [String]
    var flipAppended : Bool
    

    required init?(coder: NSCoder) {
        contacts = [Contact]()
        optionButtons = [FlipsSendButton]()
        allFlips = [Flip]()
        filteredFlips = [Flip]()
        flipsAppended = [String]()
        manuallyJoinedFlips = [String]()
        flipsManuallyJoinedPlusAppended = [String]()
        flipAppended = false
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
        loadAllFlipsArray()
        layoutSendButtons()
        updateNextButtonState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        registerForKeyboardNotifications()
        
        self.flipTextField.setupMenu()
        
        if shouldShowOnboarding(self.ONBOARDING_KEY)
        {
            setupOnboardingInNavigationController(self.ONBOARDING_KEY, onboardingImage: UIImage(named: "New Flip Overlay")!)
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
        notificationCenter.addObserver(self, selector: #selector(NewFlipViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(NewFlipViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
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
    
    private func loadAllFlipsArray(){
        let flips = Flip.findAll() as! [Flip]
        allFlips.appendContentsOf(flips)
    }
    private func filterFlipsForTable(word: String) {        
        if (flipsManuallyJoinedPlusAppended.count > 0){
            var trimmedWord = word.stringByRemovingStringsIn(flipsManuallyJoinedPlusAppended)
            trimmedWord = trimmedWord.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            filteredFlips = self.allFlips.filter { flip in
                return flip.word.lowercaseString.hasPrefix(trimmedWord.lowercaseString)
            }
        } else {
            filteredFlips = self.allFlips.filter { flip in
                return flip.word.lowercaseString.hasPrefix(word.lowercaseString)
            }
        }
    }
    
    // MARK: - suggestedTable functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFlips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("suggestedCell", forIndexPath: indexPath)
//        cell.textLabel!.layer.borderColor = UIColor.avacado().CGColor
        cell.textLabel!.layer.backgroundColor = UIColor.avacado().CGColor
        cell.textLabel!.layer.cornerRadius = 11.0
        cell.textLabel!.textAlignment = NSTextAlignment.Center
        cell.textLabel!.text = filteredFlips[indexPath.row].word
        cell.textLabel!.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.textLabel!.sizeToFit()
        cell.textLabel!.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(cell.contentView)
            make.top.equalTo()(cell.contentView).offset()(7)
            make.bottom.equalTo()(cell.contentView).offset()(-7)
        }
        return cell
    }
    
    func updateTableContentInset () {
        let numberOfRows = suggestedTable.numberOfRowsInSection(0);
        var contentInsetTop = suggestedTable.bounds.size.height
        for i in 0 ..< numberOfRows {
            let indexPath = NSIndexPath.init(forRow: i, inSection: 0)
            contentInsetTop -= suggestedTable.rectForRowAtIndexPath(indexPath).size.height
            if (contentInsetTop <= 0) {
                contentInsetTop = 0
                break
            }
        }
        suggestedTable.contentInset = UIEdgeInsetsMake(contentInsetTop, 0, 0, 0)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        //add selection to appended array.
        flipsAppended.append(filteredFlips[row].word)
        //add to all array
        flipsManuallyJoinedPlusAppended.append(filteredFlips[row].word)
        
        //set the field to the flipsAppended.
        flipTextField.text = ""
        for i in flipsManuallyJoinedPlusAppended {
            flipTextField.text.appendContentsOf(i)
            //put a space at the end.
            let space: Character = " "
            flipTextField.text.append(space)
        }
        
        //get position of flip just appended.
        let range: NSRange = (flipTextField.text! as NSString).rangeOfString(filteredFlips[row].word)
        
        
        //if the flip contains a space - it must be selected and joined.
        if(filteredFlips[row].word.containsString(" ")){
            
            //get position of flip just appended.
            let beginning = flipTextField.beginningOfDocument
            let start = flipTextField.positionFromPosition(beginning, offset: range.location)
            let end = flipTextField.positionFromPosition(start!, offset: range.length)
            let textRange = flipTextField.textRangeFromPosition(start!, toPosition: end!)
            //before joining the text set flag to true.
            flipAppended = true
            
            //select it and join.
            flipTextField.selectedTextRange = textRange
            flipTextField.joinStrings(true)
            
            flipAppended = false
            //unselect everything.
            flipTextField.selectedTextRange = flipTextField.textRangeFromPosition(flipTextField.endOfDocument, toPosition: flipTextField.endOfDocument)
        } else {
            flipTextField.appendJoinedTextRange(range)
        }
        
        //then the color can be changed to green or orange for all the phrases.
        let attributedString = NSMutableAttributedString(string: flipTextField.text)
        for i in flipsManuallyJoinedPlusAppended {
            let flipRange: NSRange = (flipTextField.text! as NSString).rangeOfString(i)
            //if it was a manually joined string - don't change it's color.
            if (!manuallyJoinedFlips.contains(i)){
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.avacado(), range: flipRange)
            } else {
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.flipOrange(), range: flipRange)
            }
            attributedString.addAttribute(NSFontAttributeName, value: flipTextField.font!, range: flipRange)
        }
        flipTextField.attributedText = attributedString
        suggestedTable.hidden = true
        buttonPanelView.alpha = 1
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
    
    func getAppendedFlips() -> [String] {
        return flipsAppended
    }
    
    func getManuallyJoinedFlips() -> [String] {
        return manuallyJoinedFlips
    }
    
    func setManuallyJoined(flipText: String){
        manuallyJoinedFlips.append(flipText)
    }
    
    func setManualPlusAppended(flipText: String) {
        flipsManuallyJoinedPlusAppended.append(flipText)
    }
    
    func removeFlipFromArrays(flipText: String){
            if (flipsManuallyJoinedPlusAppended.contains(flipText)){
                
                flipsManuallyJoinedPlusAppended.removeAtIndex(flipsManuallyJoinedPlusAppended.indexOf(flipText)!)
                
                if (flipsAppended.contains(flipText)){
                    flipsAppended.removeAtIndex(flipsAppended.indexOf(flipText)!)
                } else {
                    manuallyJoinedFlips.removeAtIndex(manuallyJoinedFlips.indexOf(flipText)!)
                }
            }
    }
    
    func flipJustAppended() -> Bool{
        return flipAppended
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
        //We need to check if the field still contains flips that are in appendedFlips
        //if not remove the appendedFlip
        //TODO: and change left over's text color?
        for i in flipsManuallyJoinedPlusAppended{
            if (!flipTextField.text.containsString(i)){
                
                flipsManuallyJoinedPlusAppended.removeAtIndex(flipsManuallyJoinedPlusAppended.indexOf(i)!)
                
                if (flipsAppended.contains(i)){
                    flipsAppended.removeAtIndex(flipsAppended.indexOf(i)!)
                } else {
                    manuallyJoinedFlips.removeAtIndex(manuallyJoinedFlips.indexOf(i)!)
                }
            }
        }
        
        //change text back to black if there aren't any letters.
        if (flipTextField.text == "" || flipTextField.text == " "){
            flipTextField.textColor = UIColor.blackColor()
        }
        
        updateNextButtonState()
        filterFlipsForTable(textView.text)
        suggestedTable.reloadData()
        updateTableContentInset()
        
        if (suggestedTable.visibleCells.count > 0){
            buttonPanelView.alpha = 0.25
        } else {
            buttonPanelView.alpha = 1
        }
        
        suggestedTable.hidden = false
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
    
    ////
    //
    ////
    
    override func onOnboardingOverlayClick() {
        super.onOnboardingOverlayClick()
        contactPicker.becomeFirstResponder()
    }
    

}

protocol NewFlipViewControllerDelegate: class {
    func didBeginSendingMessageToRoom(roomID: String!)
}
