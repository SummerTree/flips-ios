//
//  ContactTableViewCell.swift
//  mugchat
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

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var numberLabel: UILabel!
	@IBOutlet weak var photoView: ContactPhotoView!
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.nameLabel.text = nil
		self.numberLabel.text = nil
		self.photoView.reset()
	}
	
	func layoutMargins() -> UIEdgeInsets {
		return UIEdgeInsetsZero
	}
}
