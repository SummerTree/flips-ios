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
        
        if firstName != nil {
            let range = firstName.rangeOfComposedCharacterSequenceAtIndex(firstName.startIndex)
            initials = firstName.substringWithRange(range)
        }
        
        if lastName != nil {
            let range = lastName.rangeOfComposedCharacterSequenceAtIndex(lastName.startIndex)
            initials += lastName.substringWithRange(range)
        }
        
        return initials
    }
    
    public var contactTitle: String? {
        var name = ""
        
        if firstName != nil {
            name = firstName!
        }
        
        if lastName != nil {
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
                phone += " (\(phoneType))"
            }
        }
        
        return phone
    }
}
