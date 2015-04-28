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

extension ReadFlipMessage {


    // MARK: - Message Handler
    
    func toJSON() -> Dictionary<String, AnyObject> {
        var messageDictionary = Dictionary<String, AnyObject>()
        
        messageDictionary.updateValue(MESSAGE_READ_INFO_TYPE, forKey: MESSAGE_TYPE)
        messageDictionary.updateValue(self.flipMessageID, forKey: ReadFlipMessageJsonParams.FLIP_MESSAGE_ID)
        
        var contentDictionary = Dictionary<String, AnyObject>()
        contentDictionary.updateValue(messageDictionary, forKey: MESSAGE_DATA)
        
        return contentDictionary
    }
}
