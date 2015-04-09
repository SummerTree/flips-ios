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

class ConfirmPictureView : UIView, CustomNavigationBarDelegate {
    
    private var navigationBar: CustomNavigationBar!
    
    private var pictureContainerView: UIView!
    private var pictureImageView: RoundImageView!
    
    private var bottomButtonsContainerView: UIView!
    private var rejectButton: UIButton!
    private var acceptButton: UIButton!
    
    private var picture: UIImage!
    
    weak var delegate: ConfirmPictureViewDelegate?
    
    
    // MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.initSubviews()
        self.updateConstraintsIfNeeded()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubviews() {
        navigationBar = CustomNavigationBar.CustomNormalNavigationBar(NSLocalizedString("Confirm Picture", comment: "Confirm Picture"), showBackButton: false)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        pictureContainerView = UIView()
        self.addSubview(pictureContainerView)
        
        pictureImageView = RoundImageView.avatarA1()
        pictureContainerView.addSubview(pictureImageView)
        
        bottomButtonsContainerView = UIView()
        self.addSubview(bottomButtonsContainerView)
        
        rejectButton = UIButton()
        rejectButton.setImage(UIImage(named: "Deny"), forState: UIControlState.Normal)
        rejectButton.backgroundColor = UIColor.flipOrange()
        rejectButton.addTarget(self, action: "rejectButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        bottomButtonsContainerView.addSubview(rejectButton)
        
        acceptButton = UIButton()
        acceptButton.setImage(UIImage(named: "Approve"), forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.avacado()
        acceptButton.addTarget(self, action: "acceptButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        bottomButtonsContainerView.addSubview(acceptButton)
    }
    
    
    // MARK: - Overridden Methods
    
    override func updateConstraints() {
        super.updateConstraints()
        
        navigationBar.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        pictureContainerView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.centerX.equalTo()(self)
            make.width.equalTo()(self.frame.width)
            make.height.equalTo()(self.frame.width)
        }
        
        pictureImageView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.center.equalTo()(self.pictureContainerView)
            make.width.equalTo()(self.pictureImageView.frame.width)
            make.height.equalTo()(self.pictureImageView.frame.height)
        }
        
        bottomButtonsContainerView.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.pictureContainerView.mas_bottom)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.bottom.equalTo()(self)
        }
        
        rejectButton.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.bottomButtonsContainerView)
            make.bottom.equalTo()(self.bottomButtonsContainerView)
            make.leading.equalTo()(self.bottomButtonsContainerView)
            make.width.equalTo()(self.bottomButtonsContainerView.frame.width / 2)
        }
        
        acceptButton.mas_updateConstraints { (make) -> Void in
            make.removeExisting = true
            make.top.equalTo()(self.bottomButtonsContainerView)
            make.bottom.equalTo()(self.bottomButtonsContainerView)
            make.trailing.equalTo()(self.bottomButtonsContainerView)
            make.width.equalTo()(self.bottomButtonsContainerView.frame.width / 2)
        }
    }
    
    
    // MARK: - Setters
    
    func setPicture(picture: UIImage) {
        pictureImageView.image = picture
        self.updateConstraints()
    }
    
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        delegate?.confirmPictureViewDidTapBackButton(self)
    }
    
    
    // MARK: - Button Actions
    
    func rejectButtonTapped() {
        delegate?.confirmPictureViewDidTapBackButton(self)
    }
    
    func acceptButtonTapped() {
        delegate?.confirmPictureViewDidApprovePicture(self)
    }
}
