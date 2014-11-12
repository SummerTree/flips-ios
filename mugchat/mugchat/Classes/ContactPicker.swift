//
//  ContactPicker.swift
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

class ContactPicker: MBContactPicker {
    
    // must match MBContactCollectionView's settings
    let CONTACT_CELL = "ContactCell"
    let CONTACT_ENTRY_CELL = "ContactEntryCell"
    let PROMPT_CELL = "ContactPromptCell"
    
    override var backgroundColor: UIColor? {
        didSet {
            contactCollectionView.backgroundColor = backgroundColor
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // overrides the class set in MBContactCollectionView's setup method
        self.contactCollectionView.registerClass(MBContactCollectionViewContactCell.self, forCellWithReuseIdentifier:CONTACT_CELL)
        self.contactCollectionView.registerClass(MBContactCollectionViewContactCell.self, forCellWithReuseIdentifier:CONTACT_CELL)
        self.contactCollectionView.registerClass(ContactCollectionViewPromptCell.self, forCellWithReuseIdentifier:PROMPT_CELL)
    }
}