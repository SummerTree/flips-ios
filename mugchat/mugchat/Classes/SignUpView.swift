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

class SignUpView : UIView, CustomNavigationBarDelegate, UserFormViewDelegate {
    
    private var navigationBar : CustomNavigationBar!
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
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        self.backgroundColor = UIColor.deepSea()
        
        navigationBar = CustomNavigationBar.CustomLargeNavigationBar(UIImage(named: "AddProfilePhoto"), isAvatarButtonInteractionEnabled: true, showBackButton: true, showNextButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        userFormView = UserFormView()
        self.addSubview(userFormView)
    }
    
    private func initConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        userFormView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    
    // MARK: - Overriden Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: check if it should false or not. For now, false
        // navigationBar.setRightButtonEnabled(false)
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.signUpViewDidTapBackButton(self)
    }
    
    func customNavigationBarDidTapRightButton(navBar : CustomNavigationBar) {
        var userData = userFormView.getUserData()
        delegate?.signUpView(self, didTapNextButtonWith: userData.firstName, lastName: userData.lastName, email: userData.email, password: userData.password, birthday: userData.birthday)
    }

    
    // MARK: - UserFormViewDelegate
    
    func userFormView(userFormView: UserFormView, didFailValidationWithErrorMessages errorMessages: NSArray) {
        println("didFailValidationWithErrorMessages")
    }
    
    func userFormViewDidValidateAllFieldsSuccessfully(userFormView: UserFormView) {
        println("userFormViewDidValidateAllFieldsSuccessfully")
    }
}