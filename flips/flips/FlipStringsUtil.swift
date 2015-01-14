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

class FlipStringsUtil {
    
    class func splitFlipString(flipString: String) -> [String] {
        var newString = Array(flipString).reduce("") { $0 + (String($1) == "!" ? " !" : String($1)) }
        newString = Array(newString).reduce("") { $0 + (String($1) == "?" ? " ?" : String($1)) }
        newString = Array(newString).reduce("") { $0 + (String($1) == "." ? " ." : String($1)) }
        newString = Array(newString).reduce("") { $0 + (String($1) == "," ? " ," : String($1)) }
        newString = Array(newString).reduce("") { $0 + (String($1) == ";" ? " ;" : String($1)) }
        
        var arrayOfFlips : [String] = newString.componentsSeparatedByCharactersInSet(NSCharacterSet (charactersInString: " "))
        
        //TODO: Strings of punctuation without whitespace in between are joined together and treated as one word (such as "!!!" or "?!?!").
        
        return arrayOfFlips
    }
    
}
