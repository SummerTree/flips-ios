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

class MugMessage: NSObject {
    
    var sender: String!
    var mugs: [Mug]!
    
    init(sender: String!, mugs: [Mug]!) {
        super.init()
        self.sender = sender
        self.mugs = mugs
    }
    
    init(json: JSON) {
        super.init()
        var mugs = [Mug]()
        var sender = json[MessageParams.SENDER].stringValue
        var content = json[MessageParams.CONTENT]
        for (index: String, mug: JSON) in content {
            mugs.append(Mug.createEntityWithJson(mug))
        }
        
        self.sender = sender
        self.mugs = mugs
    }
}

private enum MessageParams {
    static let SENDER = "sender"
    static let CONTENT = "content"
}