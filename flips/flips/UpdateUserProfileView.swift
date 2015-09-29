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

import Foundation

class UpdateUserProfileView: SignUpView {
    
    var updateUserProfileViewDelegate: UpdateUserProfileViewDelegate?
    
    private var isFormValid = false
    private var pictureHasChanged = false
    private var originalUser: User?

    override func addCustomNavigationBar() -> CustomNavigationBar! {
        let navigationBar = CustomNavigationBar.CustomLargeNavigationBar(UIImage(named: "AddProfilePhoto")!, isAvatarButtonInteractionEnabled: true, showBackButton: true, showSaveButton: true)
        navigationBar.setBackgroundImageColor(UIColor.whiteColor())
        return navigationBar
    }
    
    override func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.updateUserProfileViewDelegate?.updateUserProfileView(self, didTapBackButton: self.hasUserInfoChanged())
    }
    
    override func customNavigationBarDidTapRightButton(navBar: CustomNavigationBar) {
        self.userFormView.validateFields()
        
        if (isFormValid) {
            let userData = getUserData()
            self.updateUserProfileViewDelegate?.updateUserProfileView(self, didTapSaveButtonWith: userData.firstName, lastName: userData.lastName, email: userData.email, password: userData.password, avatar: navBar.getAvatarImage())
        }
    }
    
    override func getBackgroundColor() -> UIColor {
        return UIColor.deepSea()
    }
    
    override func initSubviews() {
        super.initSubviews()
        self.userFormView.setBirthdayFieldVisible(false)
    }

    func setUser(user: User!) {
        self.originalUser = user
        userFormView.setUserData(user)
        navigationBar.setRightButtonEnabled(false)
        
        if (user.facebookID == nil) {
            let changePasswdLabel = UILabel()
            changePasswdLabel.numberOfLines = 2
            changePasswdLabel.text = NSLocalizedString("To change your password, type a\nnew password above and tap \"Save\".")
            changePasswdLabel.textColor = UIColor.whiteColor()
            changePasswdLabel.textAlignment = NSTextAlignment.Center
            changePasswdLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h6)
            self.userFormView.addSubview(changePasswdLabel)
            
            changePasswdLabel.mas_updateConstraints { (update) -> Void in
                update.trailing.equalTo()(self.userFormView)
                update.leading.equalTo()(self.userFormView)
                update.height.equalTo()(44)
                update.bottom.equalTo()(self.userFormView)
            }
        } else {
            userFormView.setPasswordFieldVisible(false)
        }
        
        self.updateConstraints()
    }
    
    private func hasUserInfoChanged() -> Bool {
        if (originalUser == nil) {
            return true
        }
        
        return pictureHasChanged || self.originalUser!.firstName != self.userFormView.firstNameTextField.text ||
            self.originalUser!.lastName != self.userFormView.lastNameTextField.text ||
            self.originalUser!.username != self.userFormView.emailTextField.text ||
            !self.userFormView.passwordTextField.text!.isEmpty
    }
    
    override func setUserPicture(picture: UIImage) {
        super.setUserPicture(picture)

        pictureHasChanged = true
        navigationBar.setRightButtonEnabled(true)
    }
    
    override func enableRightButton(allFieldsCompleted: Bool) {
        if (self.userFormView.nameFilled && self.userFormView.nameValid &&
            self.userFormView.emailFilled && self.userFormView.emailValid &&
            (!self.userFormView.passwordFilled || self.userFormView.passwordValid)) {
                
            isFormValid = true
            navigationBar.setRightButtonEnabled(true)
        } else {
            isFormValid = false
            navigationBar.setRightButtonEnabled(false)
        }
    }
    
}

protocol UpdateUserProfileViewDelegate {
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapSaveButtonWith firstName: String, lastName: String, email: String, password: String, avatar: UIImage!)
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapBackButton withEditions: Bool)
}
