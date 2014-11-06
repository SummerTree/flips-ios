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

class SignUpView : UIView, CustomNavigationBarDelegate, UserFormViewDelegate, MessagesTopViewDelegate {
    
    private let MESSAGES_TOP_VIEW_ANIMATION_DURATION = 0.3
    
    private var navigationBar : CustomNavigationBar!
    private var messagesTopView : MessagesTopView!
    private var userFormView : UserFormView!
    
    var delegate : SignUpViewDelegate?
    
    
    // MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubviews()
        self.initConstraints()
        
        var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        self.messagesTopView.addGestureRecognizer(panGestureRecognizer)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        self.backgroundColor = UIColor.deepSea()
        
        navigationBar = CustomNavigationBar.CustomLargeNavigationBar(UIImage(named: "AddProfilePhoto"), isAvatarButtonInteractionEnabled: true, showBackButton: true, showNextButton: true)
        navigationBar.setRightButtonEnabled(false)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        messagesTopView = MessagesTopView()
        messagesTopView.delegate = self
        self.addSubview(messagesTopView)
        
        userFormView = UserFormView()
        userFormView.delegate = self
        self.addSubview(userFormView)
    }
    
    private func initConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        messagesTopView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.navigationBar.mas_top)
            make.centerX.equalTo()(self.navigationBar)
            make.width.equalTo()(self.navigationBar)
            make.height.equalTo()(self.navigationBar)
        }
        
        userFormView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
//            make.bottom.equalTo()(self)
        }
    }
    
    // MARK: - Life Cycle
    
    func loadView() {
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func viewDidAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func viewWillDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.signUpViewDidTapBackButton(self)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        if (userFormView.isAllFieldsValids()) {
            self.dismissKeyboard()
            var userData = userFormView.getUserData()
            delegate?.signUpView(self, didTapNextButtonWith: userData.firstName, lastName: userData.lastName, email: userData.email, password: userData.password, birthday: userData.birthday)
        }
    }
    
    func customNavigationBarDidTapAvatarButton(navBar : CustomNavigationBar) {
        delegate?.signUpViewDidTapTakePictureButton(self)
    }
    
    
    // MARK: - UserFormViewDelegate
    
    func userFormView(userFormView: UserFormView, didValidateEmailWithSuccess success: Bool) {
        if (success) {
            messagesTopView.hideInvalidEmailMessage()
        } else {
            messagesTopView.showInvalidEmailMessage()
            self.showTopMessagesView()
        }
    }
    
    func userFormView(userFormView: UserFormView, didValidatePasswordWithSuccess success: Bool) {
        if (success) {
            messagesTopView.hideInvalidPasswordMessage()
        } else {
            messagesTopView.showInvalidPasswordMessage()
            self.showTopMessagesView()
        }
    }
    
    func userFormView(userFormView: UserFormView, didValidateBirthdayWithSuccess success: Bool) {
        if (success) {
            messagesTopView.hideInvalidBirthdayMessage()
        } else {
            messagesTopView.showInvalidBirthdayMessage()
            self.showTopMessagesView()
        }
    }
    
    func userFormView(userFormView: UserFormView, didValidateAllFieldsWithSuccess success: Bool) {
        navigationBar.setRightButtonEnabled(success)
    }
    
    
    // MARK: - Messages Top View methods
    
    func showTopMessagesView() {
        UIGraphicsBeginImageContextWithOptions(navigationBar.frame.size, false, 0.0)
        navigationBar.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        messagesTopView.setMessagesTopViewBackgroundImage(image)
        
        delegate?.signUpView(self, setStatusBarHidden: true)
        
        self.messagesTopView.layoutIfNeeded()
        UIView.animateWithDuration(self.MESSAGES_TOP_VIEW_ANIMATION_DURATION, animations: { () -> Void in
            self.messagesTopView.mas_makeConstraints({ (make) -> Void in
                make.removeExisting = true
                make.bottom.equalTo()(self.navigationBar)
                make.centerX.equalTo()(self.navigationBar)
                make.width.equalTo()(self.navigationBar)
                make.height.equalTo()(self.navigationBar)
            })
            self.messagesTopView.layoutIfNeeded()
        })
    }
    
    
    // MARK: - Actions Handlers
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translationInView(self)
        let isMessagesTopViewAboveMaximumY = (recognizer.view!.center.y + translation.y) <= (recognizer.view!.frame.size.height/2)
        if (isMessagesTopViewAboveMaximumY) {
            // Don't move to bottom
            recognizer.view!.center = CGPoint(x:recognizer.view!.center.x, y:recognizer.view!.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPointZero, inView: self)
        
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            self.dismissMessagesTopView()
        }
    }
    
    private func dismissMessagesTopView() {
        delegate?.signUpView(self, setStatusBarHidden: false)
        self.layoutIfNeeded()
        UIView.animateWithDuration(MESSAGES_TOP_VIEW_ANIMATION_DURATION, animations: { () -> Void in
            self.messagesTopView.mas_updateConstraints { (update) -> Void in
                update.removeExisting = true
                update.bottom.equalTo()(self.navigationBar.mas_top)
                update.centerX.equalTo()(self.navigationBar)
                update.width.equalTo()(self.navigationBar)
                update.height.equalTo()(self.navigationBar)
            }
            self.layoutIfNeeded()
        })
    }
    
    // MARK - Keyboard Control
    
    func dismissKeyboard() {
        userFormView.dismissKeyboard()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardMinY = getKeyboardMinY(notification)
        self.slideViews(true, keyboardTop: keyboardMinY)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardMinY = getKeyboardMinY(notification)
        self.slideViews(false, keyboardTop: keyboardMinY)
    }
    
    private func getKeyboardMinY(notification: NSNotification) -> CGFloat {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        println(userInfo)
        let keyboardRect: CGRect = userInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue()
        println(userInfo.valueForKey(UIKeyboardFrameBeginUserInfoKey)!)
        return CGRectGetMaxY(self.frame) - CGRectGetHeight(keyboardRect)
    }
    
    func slideViews(movedUp: Bool, keyboardTop: CGFloat) {
        self.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            if (movedUp) {
                var userFormViewFrameBottom = self.userFormView.frame.origin.y + self.userFormView.frame.size.height
                var offsetValue = keyboardTop - userFormViewFrameBottom
                if (offsetValue < 0) {
                    self.navigationBar.mas_makeConstraints { (update) -> Void in
                        update.removeExisting = true
                        update.top.equalTo()(self).with().offset()(offsetValue)
                        update.trailing.equalTo()(self)
                        update.leading.equalTo()(self)
                        update.height.equalTo()(self.navigationBar.frame.size.height)
                    }
                }
            } else {
                self.navigationBar.mas_makeConstraints { (update) -> Void in
                    update.removeExisting = true
                    update.top.equalTo()(self)
                    update.trailing.equalTo()(self)
                    update.leading.equalTo()(self)
                    update.height.equalTo()(self.navigationBar.frame.size.height)
                }
            }
            self.layoutIfNeeded()
        })
    }
    
    // MARK: - MessageTopViewDelegate
    
    func dismissMessagesTopView(messageTopView: MessagesTopView) {
        self.dismissMessagesTopView()
    }
    
    
    // MARK: - Setters
    
    func setUserPicture(picture: UIImage) {
        self.navigationBar.setAvatarImage(picture.avatarProportional())
    }
}