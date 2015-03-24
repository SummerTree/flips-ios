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

let ContactTableViewCellIdentifier = "ContactTableViewCell"

class ContactTableViewCell: UITableViewCell {
    let LOW_PRIORITY: UILayoutPriority = 1
    let HIGH_PRIORITY: UILayoutPriority = 751
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameLabelEqualHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var photoView: ContactPhotoView!
    @IBOutlet weak var labelView: UIView!
    
    var contact: Contact! {
        didSet {
            self.nameLabel.text = contact.contactTitle
            self.numberLabel.text = contact.contactSubtitle
            
            if let flipUser = contact.contactUser {
                if (!flipUser.isTemporary.boolValue) {
                    self.photoView.setImageWithURL(NSURL(string:contact.contactUser.photoURL))
                    self.numberLabel.text = "(\(flipUser.fullName()))"
                } else {
                    self.photoView.initials = contact.contactInitials
                }
            } else {
                self.photoView.initials = contact.contactInitials
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel.text = nil
        self.nameLabelEqualHeightConstraint.priority = LOW_PRIORITY
        self.numberLabel.text = nil
        self.numberLabel.hidden = false
        self.photoView.reset()
        self.photoView.borderColor = .lightGreyD8()
    }
    
    func layoutMargins() -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func hideNumberLabel() {
        self.numberLabel?.hidden = true
        self.nameLabelEqualHeightConstraint.priority = HIGH_PRIORITY
    }
}
