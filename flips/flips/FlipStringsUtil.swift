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

private enum FlipCharType {
    case WORD
    case SPECIAL
    case WHITESPACE
}

class FlipStringsUtil {
    
    class func splitFlipString(flipString: String) -> [String] {
        let wordCharRegex = NSRegularExpression(pattern: WORD_CHARACTER_PATTERN, options: nil, error: nil)!
        var arrayOfFlips = [String]()
        var lastCharType = FlipCharType.WHITESPACE
        var newWord = ""
        for char in flipString {
            var currentCharType: FlipCharType
            if (char == " ") {
                currentCharType = FlipCharType.WHITESPACE
            } else {
                let str = String(char)
                let range = NSRange(location: 0, length: countElements(str))
                let isWordChar = wordCharRegex.numberOfMatchesInString(str, options: nil, range: range) > 0
                currentCharType = isWordChar ? FlipCharType.WORD : FlipCharType.SPECIAL
            }
            
            if (currentCharType == FlipCharType.WHITESPACE || currentCharType != lastCharType) {
                if (countElements(newWord) > 0) {
                    arrayOfFlips.append(newWord)
                    newWord = ""
                }
                if (currentCharType != FlipCharType.WHITESPACE) {
                    newWord = "\(char)"
                }
            } else {
                newWord.append(char)
            }
            
            lastCharType = currentCharType
        }
        
        if (countElements(newWord) > 0) {
            arrayOfFlips.append(newWord)
        }
        
        return arrayOfFlips
    }
    
}
