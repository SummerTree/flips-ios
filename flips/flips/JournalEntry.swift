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

public class JournalEntry {
    
    let key: String
    let size: UInt64
    var timestamp: Int
    
    init(key: String, size: UInt64, timestamp: Int) {
        self.key = key
        self.size = size
        self.timestamp = timestamp
    }
    
    func toString(sep: Character, eol: Character) -> String {
        return "\(self.key)\(sep)\(self.size)\(sep)\(self.timestamp)\(eol)"
    }
    
}