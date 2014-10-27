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

public class ConfirmFlipView : UIView {
    
    var delegate: ConfirmFlipViewDelegate?
    
    private let MUG_IMAGE_WIDTH: CGFloat = 240.0
    private let MUG_WORD_LABEL_MARGIN_BOTTOM: CGFloat = 40.0
    
    private var mugContainerView: UIView!
    private var flipImageView: UIImageView!
    private var flipWordLabel: UILabel!
    private var rejectButton: UIButton!
    private var acceptButton: UIButton!
    
    convenience init(flipPicture: UIImage!, flipWord: String!) {
        self.init()
        self.flipImageView = UIImageView(image: flipPicture)
        self.flipWordLabel = UILabel()
        self.flipWordLabel.text = flipWord
        
        self.addSubviews()
    }
    
    
    // MARK: - Life cycle
    
    func viewDidLoad() {
        self.makeConstraints()
        self.layoutIfNeeded()
    }
    
    func addSubviews() {
        mugContainerView = UIView()
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "playOrPausePreview")
        mugContainerView.addGestureRecognizer(tapGestureRecognizer)
        
        self.addSubview(mugContainerView)
        
        flipImageView.contentMode = UIViewContentMode.ScaleAspectFit
        mugContainerView.addSubview(self.flipImageView)
        
        flipWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        flipWordLabel.textColor = UIColor.whiteColor()
        
        mugContainerView.addSubview(self.flipWordLabel)
        
        rejectButton = UIButton()
        rejectButton.setImage(UIImage(named: "Deny"), forState: UIControlState.Normal)
        rejectButton.backgroundColor = UIColor.mugOrange()
        rejectButton.addTarget(self, action: "rejectButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(rejectButton)
        
        acceptButton = UIButton()
        acceptButton.setImage(UIImage(named: "Approve"), forState: UIControlState.Normal)
        acceptButton.backgroundColor = UIColor.avacado()
        acceptButton.addTarget(self, action: "acceptButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(acceptButton)
    }
    
    func playOrPausePreview() {
        self.delegate?.confirmFlipViewDidTapPlayOrPausePreviewButton(self)
    }
    
    func makeConstraints() {
        mugContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.flipImageView)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.confirmFlipViewMakeConstraintToNavigationBarBottom(mugContainerView)
        
        flipImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.mugContainerView)
                make.width.equalTo()(self.MUG_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.mugContainerView)
                make.right.equalTo()(self.mugContainerView)
            }

            make.height.equalTo()(self.flipImageView.mas_width)
        }
        
        flipWordLabel.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.mugContainerView).with().offset()(-self.MUG_WORD_LABEL_MARGIN_BOTTOM)
            make.centerX.equalTo()(self.mugContainerView)
        }
        
        rejectButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self.mas_centerX)
            make.bottom.equalTo()(self)
        }
        
        acceptButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.rejectButton)
            make.left.equalTo()(self.rejectButton.mas_right)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    
    // MARK: - Action buttons
    
    func rejectButtonTapped() {
        self.delegate?.confirmFlipViewDidTapRejectButton(self)
    }
    
    func acceptButtonTapped() {
        self.delegate?.confirmFlipViewDidTapAcceptButton(self)
    }
}

protocol ConfirmFlipViewDelegate {
    func confirmFlipViewMakeConstraintToNavigationBarBottom(pictureContainerView: UIView!)
    func confirmFlipViewDidTapRejectButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapAcceptButton(flipView: ConfirmFlipView!)
    func confirmFlipViewDidTapPlayOrPausePreviewButton(flipView: ConfirmFlipView!)
}