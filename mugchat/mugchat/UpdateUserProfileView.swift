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

import Foundation

class UpdateUserProfileView: SignUpView {
    
    var updateUserProfileViewDelegate: UpdateUserProfileViewDelegate?
    
    private var isUserProfileChanged = false
    
    override func addCustomNavigationBar() -> CustomNavigationBar! {
        let navigationBar = CustomNavigationBar.CustomLargeNavigationBar(UIImage(named: "AddProfilePhoto")!, isAvatarButtonInteractionEnabled: true, showBackButton: true, showSaveButton: true)
        navigationBar.setBackgroundImageColor(UIColor.whiteColor())
        return navigationBar
    }
    
    override func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.updateUserProfileViewDelegate?.updateUserProfileView(self, didTapBackButton: isUserProfileChanged)
    }
    
    override func customNavigationBarDidTapRightButton(navBar: CustomNavigationBar) {
        let userData = getUserData()
        self.updateUserProfileViewDelegate?.updateUserProfileView(self, didTapSaveButtonWith: userData.firstName, lastName: userData.lastName, email: userData.email, password: userData.password, birthday: userData.birthday)
    }
    
    override func getBackgroundColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func setUser(user: User!) {
        userFormView.setUserData(user)
        navigationBar.setRightButtonEnabled(false)
    }
    
    override func enableRightButton(allFieldsCompleted: Bool) {
        if (allFieldsCompleted && isUserProfileChanged) {
            navigationBar.setRightButtonEnabled(true)
        } else {
            navigationBar.setRightButtonEnabled(false)
        }
    }
    
    
    // MARK: - UserFormViewDelegate
    
    override func userFormViewDidUpdateField(userFormView: UserFormView) {
        isUserProfileChanged = true
    }
}

protocol UpdateUserProfileViewDelegate {
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapSaveButtonWith firstName: String, lastName: String, email: String, password: String, birthday: String)
    func updateUserProfileView(updateUserProfileView: UpdateUserProfileView!, didTapBackButton withEditions: Bool)
}
