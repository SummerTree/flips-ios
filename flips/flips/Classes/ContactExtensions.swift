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

extension Contact: MBContactPickerModelProtocol {
    public var contactInitials: String {
        var initials = ""
        
        if (firstName != nil && !firstName.isEmpty) {
            let range = firstName.rangeOfComposedCharacterSequenceAtIndex(firstName.startIndex)
            initials = firstName.substringWithRange(range)
        }
        
        if (lastName != nil && !lastName.isEmpty) {
            let range = lastName.rangeOfComposedCharacterSequenceAtIndex(lastName.startIndex)
            initials += lastName.substringWithRange(range)
        }
        
        return initials
    }
    
    public var contactTitle: String? {
        var name = ""
        
        if (firstName != nil && !firstName.isEmpty) {
            name = firstName!
        }
        
        if (lastName != nil && !lastName.isEmpty) {
            if !name.isEmpty {
                name += " "
            }
            
            name += lastName!
        }
        
        return name
    }
    
    public var contactSubtitle: String? {
        var phone = ""
        
        if phoneNumber != nil {
            phone = phoneNumber
            
            if phoneType != nil {
                if (phoneType.isEmpty) {
                    phone += " (no label)"
                } else {
                    phone += " (\(phoneType))"
                }
            }
        }
        
        return phone
    }
    
    func formattedPhoneNumber() -> String {
        if let phoneNumber = self.phoneNumber {
            return phoneNumber.toFormattedPhoneNumber()
        }
        
        return ""
    }
    
}
