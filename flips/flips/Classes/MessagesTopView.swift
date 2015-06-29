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

class MessagesTopView : UIView, UITableViewDataSource, UITableViewDelegate {
    
    private let PASSWORD_MESSAGE_KEY = "password"
    private let BIRTHDAY_MESSAGE_KEY = "birthday"
    private let EMAIL_MESSAGE_KEY = "email"
    private let PICTURE_MESSAGE_KEY = "picture"
    
    private let CELL_IDENTIFIER = "conversationCell"
    private let FIELDS_MARGIN : CGFloat = 12.5
    
    private let STATUS_BAR_HEIGHT = UIApplication.sharedApplication().statusBarFrame.size.height
    private let DISMISS_ARROW_BOTTOM_MARGIN : CGFloat = -10
    
    private var backgroundBlurImageView: UIImageView!
    private var tableView: UITableView!
    private var arrowDismissImageView : UIImageView!
    
    private var messages: Dictionary<String, NSAttributedString>!
    
    weak var delegate: MessagesTopViewDelegate?
    
    
    // MARK: - Initialization Methods
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messages = Dictionary<String, NSAttributedString>()
        
        self.initSubviews()
        self.initConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        self.backgroundColor = UIColor.clearColor()
        
        backgroundBlurImageView = UIImageView()
        backgroundBlurImageView.contentMode = UIViewContentMode.Center
        self.addSubview(backgroundBlurImageView)
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.registerClass(MessagesTopViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.bounces = false
        tableView.separatorStyle = .None
        self.addSubview(tableView)
        
        arrowDismissImageView = UIImageView(image: UIImage(named: "Arrow_Up"))
        arrowDismissImageView.backgroundColor = UIColor.clearColor()
        arrowDismissImageView.sizeToFit()
        self.addSubview(arrowDismissImageView)
    }
    
    private func initConstraints() {
        backgroundBlurImageView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        
        tableView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self).with().offset()(self.STATUS_BAR_HEIGHT / 2)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self).with().offset()(self.FIELDS_MARGIN)
            make.trailing.equalTo()(self).with().offset()(-self.FIELDS_MARGIN)
        }
        
        arrowDismissImageView.mas_makeConstraints { (make) -> Void in
            make.removeExisting = true
            make.centerX.equalTo()(self)
            make.bottom.equalTo()(self).with().offset()(self.DISMISS_ARROW_BOTTOM_MARGIN)
            make.width.equalTo()(self.arrowDismissImageView)
            make.height.equalTo()(self.arrowDismissImageView)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MessagesTopViewCell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as! MessagesTopViewCell
        cell.setAttributedMessage(Array(messages.values)[indexPath.row])
        return cell;
    }
    
    
    // MARK: - Messages Handler
    
    func showInvalidPasswordMessage() {
        self.showMessage("Your password should be\n", secondLineKey: "8+ Characters, Mixed Case, 1 Number", dictionaryKey: PASSWORD_MESSAGE_KEY)
    }
    
    func hideInvalidPasswordMessage() {
        self.hideMessageForKey(PASSWORD_MESSAGE_KEY)
    }
    
    func showInvalidEmailMessage() {
        self.showMessage("Your email should look like this\n", secondLineKey: "flip@mail.com", dictionaryKey: EMAIL_MESSAGE_KEY)
    }
    
    func hideInvalidEmailMessage() {
        self.hideMessageForKey(EMAIL_MESSAGE_KEY)
    }
    
    func showInvalidBirthdayMessage() {
        self.showMessage("You must be at least\n", secondLineKey: "13 years old", dictionaryKey: BIRTHDAY_MESSAGE_KEY)
    }
    
    func hideInvalidBirthdayMessage() {
        self.hideMessageForKey(BIRTHDAY_MESSAGE_KEY)
    }
    
    func showMissingPictureMessage() {
        self.showMessage("Looks like your photo is missing!", secondLineKey: "", dictionaryKey: PICTURE_MESSAGE_KEY)
    }
    
    func hideMissingPictureMessage() {
        self.hideMessageForKey(PICTURE_MESSAGE_KEY)
    }
    
    private func showMessage(firstLineKey: String, secondLineKey: String, dictionaryKey: String) {
        var message = self.formatUsingUltraLightFont(NSLocalizedString(firstLineKey, comment: firstLineKey))
        message.appendAttributedString(self.formatUsingMediumFont(NSLocalizedString(secondLineKey, comment: secondLineKey)))
        
        messages.updateValue(message, forKey: dictionaryKey)
        tableView.reloadData()
    }
    
    private func hideMessageForKey(dictionaryKey: String) {
        if (messages.indexForKey(dictionaryKey) != nil) {
            messages.removeValueForKey(dictionaryKey)
            tableView.reloadData()
        }
        
        if (messages.count == 0) {
            delegate?.dismissMessagesTopView(self)
        }
    }
    
    
    // MARK: - AttributedString Handlers
    
    func formatUsingUltraLightFont(text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)])
        
    }
    
    func formatUsingMediumFont(text: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: text, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.avenirNextMedium(UIFont.HeadingSize.h6)])
    }
    
    
    // MARK: - Blur Background hanlder
    
    func setMessagesTopViewBackgroundImage(image: UIImage) {
        backgroundBlurImageView.image = image.applyTintEffectWithColor(UIColor.flipOrange())
        backgroundBlurImageView.alpha = 0.98
    }
}