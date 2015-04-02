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

class SettingsTableViewCell: UITableViewCell {
    
    private let ICONS_WIDTH: CGFloat = 92.0

    private var imageContainerView: UIView!
    private var labelContainerView: UIView!
    private var actionImageView: UIImageView!
    private var actionLabel: UILabel!
    private var actionDetailLabel: UILabel!
    
    convenience init(image: UIImage!, labelText: String!, detailLabel: String?) {
        self.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "tableActionsCell")
        
        self.actionImageView = UIImageView(image: image)
        self.actionImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.actionLabel = UILabel()
        self.actionLabel.text = labelText
        self.actionLabel.sizeToFit()
        
        if let detail = detailLabel {
            self.actionDetailLabel = UILabel()
            self.actionDetailLabel.text = detail
            self.actionDetailLabel.numberOfLines = 2
            self.actionDetailLabel.sizeToFit()
        }
        
        addSubviews()
        makeContraints()
    }
    
    func addSubviews() {
        
        self.backgroundColor = UIColor.sand()
        
        self.imageContainerView = UIView()
        self.contentView.addSubview(imageContainerView)
        
        self.actionImageView.sizeToFit()
        self.imageContainerView.addSubview(actionImageView)
        
        self.labelContainerView = UIView()
        self.contentView.addSubview(labelContainerView)
        
        self.actionLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        self.actionLabel.textColor = UIColor.deepSea()
        self.labelContainerView.addSubview(actionLabel)
        
        if (actionDetailLabel != nil) {
            self.actionDetailLabel.font = UIFont.avenirNextUltraLight(UIFont.HeadingSize.h6)
            self.actionDetailLabel.textColor = UIColor.deepSea()
            self.labelContainerView.addSubview(actionDetailLabel)
        }
    }
    
    func makeContraints() {
        imageContainerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.left.equalTo()(self)
            make.bottom.equalTo()(self.contentView)
            make.width.equalTo()(self.ICONS_WIDTH)
        }
        
        actionImageView.mas_makeConstraints { (make) -> Void in
            make.center.equalTo()(self.imageContainerView)
            make.width.equalTo()(self.actionImageView.frame.width)
            make.height.equalTo()(self.actionImageView.frame.height)
        }
        
        labelContainerView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.contentView)
            make.left.equalTo()(self.imageContainerView.mas_right)
            make.bottom.equalTo()(self.contentView)
            make.right.equalTo()(self)
        }
        
        if (actionDetailLabel != nil) {
            actionLabel.mas_makeConstraints { (make) -> Void in
                make.left.equalTo()(self.imageContainerView.mas_right)
                make.right.equalTo()(self.contentView)
                make.bottom.equalTo()(self.mas_centerY)
            }
            
            actionDetailLabel.mas_makeConstraints({ (make) -> Void in
                make.top.equalTo()(self.mas_centerY)
                make.left.equalTo()(self.actionLabel)
            })
        } else {
            actionLabel.mas_makeConstraints { (make) -> Void in
                make.left.equalTo()(self.imageContainerView.mas_right)
                make.right.equalTo()(self.contentView)
                make.centerY.equalTo()(self.contentView)
                make.height.equalTo()(self)
            }
        }
    }
    
    func setActionLabelText(text: String!) {
        self.actionLabel.text = text
    }
    
    func setActionDetailLabelText(text: String!) {
        self.actionDetailLabel.text = text
    }
    
    func setAvatarURL(url: String!) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.actionImageView, style: UIActivityIndicatorViewStyle.White)
        self.actionImageView.layer.cornerRadius = self.actionImageView.frame.size.width / 2
        self.actionImageView.layer.masksToBounds = true
        self.actionImageView.setImageWithURL(NSURL(string: url), success: { (request, response, image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.actionImageView)
                self.actionImageView.mas_updateConstraints({ (update) -> Void in
                    update.removeExisting = true
                    update.center.equalTo()(self.imageContainerView)
                    update.width.equalTo()(self.actionImageView.frame.width)
                    update.height.equalTo()(self.actionImageView.frame.height)
                })
            })
        })
    }
}
