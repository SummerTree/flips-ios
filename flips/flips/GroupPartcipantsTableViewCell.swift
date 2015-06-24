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

class GroupPartcipantsTableViewCell: UITableViewCell {
    
    private let AVATAR_LEFT_MARGIN: CGFloat = 20
    private let NAME_HORIZONTAL_MARGIN: CGFloat = 10
    
    private var nameLabel: UILabel!
    private var avatarView: ContactPhotoView!
    

    // MARK: - Required initializers
    
    required internal init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: reuseIdentifier)
        
        self.addSubviews()
        self.addConstraints()
    }
    
    
    // MARK: View Layout Methods
    
    private func addSubviews() {
        self.nameLabel = UILabel()
        self.nameLabel.font = UIFont.avenirNextMedium(UIFont.HeadingSize.h4)
        self.nameLabel.textColor = UIColor.deepSea()
        self.contentView.addSubview(self.nameLabel)
        
        self.avatarView = ContactPhotoView()
        self.contentView.addSubview(self.avatarView)
    }
    
    private func addConstraints() {
        self.avatarView.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.centerY.equalTo()(self.contentView)
            make.leading.equalTo()(self.contentView).with().offset()(self.AVATAR_LEFT_MARGIN)
            make.width.equalTo()(self.avatarView.frame.size.width)
            make.height.equalTo()(self.avatarView.frame.size.height)
        }
        
        self.nameLabel.mas_makeConstraints { (make: MASConstraintMaker!) -> Void in
            make.leading.equalTo()(self.avatarView.mas_trailing).with().offset()(self.NAME_HORIZONTAL_MARGIN)
            make.trailing.equalTo()(self.contentView).with().offset()(-self.NAME_HORIZONTAL_MARGIN)
            make.centerY.equalTo()(self.contentView)
        }
    }
    
    
    // MARK: - Cell Configuration Methods
    
    func configureCellWithUser(user: User) {
        var fullName: String = ""
        if (user.isTemporary.boolValue) {
            if (user.contacts.count > 0) {
                if let contact: Contact = user.contacts.first as? Contact {
                    fullName = contact.contactTitle!
                    self.avatarView.initials = contact.contactInitials
                }
            } else {
                // If you invited a contact in another device, you will not have him on this one.
                fullName = user.phoneNumber
                self.avatarView.initials = "+"
            }
        } else {
            fullName = user.fullName()
            self.avatarView.setAvatarWithURL(NSURL(string: user.photoURL))
        }
        
        self.nameLabel.text = fullName
        self.updateConstraintsIfNeeded()
        self.layoutIfNeeded()
    }
}
