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

class JoinStringsTextField : UITextView, UITextViewDelegate {
    
    private var joinedTextRanges : [NSRange] = [NSRange]()
    private let wordCharRegex = NSRegularExpression(pattern: "\\w", options: nil, error: nil)!
    private let WHITESPACE: Character = " "
    let DEFAULT_HEIGHT: CGFloat = 42.0
    
    weak var joinStringsTextFieldDelegate: JoinStringsTextFieldDelegate?
    
    override init() {
        super.init(frame: CGRect.zeroRect, textContainer: nil)
        self.returnKeyType = .Next
        self.delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer!) {
        super.init(frame: frame, textContainer: textContainer)
        self.returnKeyType = .Next
    }
    
    required init(coder: NSCoder) {
		super.init(coder: coder)
        self.returnKeyType = .Next
		self.delegate = self
    }
    
    func setupMenu() {
        let menuController = UIMenuController.sharedMenuController()
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Join", comment: "Join"), action: "joinStrings")
        menuController.menuItems = NSArray(array: [lookupMenu])
        menuController.update()
        menuController.setMenuVisible(true, animated: true)
    }
    
    func joinStrings() {
        var selectedTextRange: UITextRange = self.selectedTextRange!
        
        var string = Array(self.text)
        
        var posInit : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)
        var posEnd : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
        
        for (var i = posInit; i < posEnd; ++i) {
            if (string[i] != WHITESPACE) {
                break
            }
            ++posInit
        }
        
        for (var i = posEnd-1; i >= posInit; --i) {
            if (string[i] != WHITESPACE) {
                break
            }
            --posEnd
        }
        
        if (posInit == posEnd) {
            return
        }
        
        let firstCharIsSpecial = isSpecialCharacter(string[posInit])
        for (var i = posInit-1; i >= 0; --i) {
            if (string[i] == WHITESPACE || isSpecialCharacter(string[i]) ^ firstCharIsSpecial) {
                break
            }
            --posInit
        }
        
        let lastCharIsSpecial = isSpecialCharacter(string[posEnd-1])
        for (var i = posEnd; i < string.count; ++i) {
            if (string[i] == WHITESPACE || isSpecialCharacter(string[i]) ^ lastCharIsSpecial) {
                break
            }
            ++posEnd
        }
        
        var newRange = NSMakeRange(posInit, posEnd-posInit)
        var intersections = [(Int,NSRange)]()
        for (var i = 0; i < self.joinedTextRanges.count; ++i) {
            let intersection = NSIntersectionRange(newRange, self.joinedTextRanges[i])
            if (intersection.length > 0) {
                intersections.append((i, self.joinedTextRanges[i]))
            }
        }
        
        var minimum = newRange.location
        var maximum = newRange.location+newRange.length
        for intersection in intersections {
            minimum = min(minimum, intersection.1.location)
            maximum = max(maximum, intersection.1.location+intersection.1.length)
            self.joinedTextRanges.removeAtIndex(intersection.0)
        }
        
        var joinedTextRange = NSMakeRange(minimum, maximum-minimum)
        self.joinedTextRanges.append(joinedTextRange)

        self.updateColorOnJoinedTexts(UIColor.flipOrange())
    }
    
    func updateColorOnJoinedTexts(color: UIColor) {
        var attributedString = NSMutableAttributedString(string:self.text + " ")
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: 0, length: countElements(self.text)))
        
        for joinedTextRange in joinedTextRanges {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: joinedTextRange)
        }
        
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: countElements(self.text), length: 1))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSRange(location: countElements(self.text), length: 1))
        
        self.attributedText = attributedString
    }
    
    func resetTextColor() {
        var attributedString = NSMutableAttributedString(string:self.text)
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: 0, length: countElements(self.text)))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, countElements(self.text)))
        self.attributedText = attributedString
    }
    
    func getFlipTexts() -> [String] {
        self.resignFirstResponder()
        
        var flipTexts : [String] = [String]()
        
        var charIndex = 0
        var lastWord: String = ""
        
        for character in self.text {
            if (character == WHITESPACE) {
                let result = isPartOfJoinedTextRanges(charIndex)
                //Avoids that joining a word with a space before or after to join the previous or next word respectivelly
                var locationFirst: Int?
                var locationLast: Int?
                if (result.textRange != nil) {
                    locationFirst = result.textRange!.location
                    locationLast = locationFirst! + result.textRange!.length-1
                }

                let isTheFirstCharacterOfJoinedText = (charIndex == locationFirst)
                let isTheLastCharacterOfJoinedText = (charIndex == locationLast)
                if (result.isPart && !isTheFirstCharacterOfJoinedText && !isTheLastCharacterOfJoinedText) {
                    lastWord.append(character)
                } else {
                    if (lastWord != "") {
                        flipTexts.append(lastWord)
                        lastWord = ""
                    }
                }
            } else if (isSpecialCharacter(character)) {
                if (hasSpecialCharacters(lastWord)) {
                    lastWord.append(character)
                } else {
                    let result = isPartOfJoinedTextRanges(charIndex)
                    if (result.isPart) {
                        lastWord.append(character)
                    } else {
                        if (lastWord != "") {
                            flipTexts.append(lastWord)
                            lastWord = ""
                            lastWord.append(character)
                        } else {
                            lastWord.append(character)
                        }
                    }
                }
            } else {
                lastWord.append(character)
            }
            
            charIndex++
        }
        
        if (lastWord != "") {
            flipTexts.append(lastWord)
        }
        
        self.becomeFirstResponder()
        
        return flipTexts
    }
    
    func isPartOfJoinedTextRanges(charIndex: Int) -> (isPart: Bool, textRange: NSRange?) {
        for textRange in self.joinedTextRanges {
            var posInit : Int = textRange.location
            var posEnd : Int = textRange.location + textRange.length
            if (posInit <= charIndex && charIndex < posEnd) {
                return (true, textRange)
            }
        }
        return (false, nil)
    }
    
    func hasSpecialCharacters(text : String) -> Bool {
        for character in text {
            if (isSpecialCharacter(character)) {
                return true
            }
        }
        return false
    }
    
    func isSpecialCharacter(char : Character) -> Bool {
        let str = String(char)
        let range = NSRange(location: 0, length: countElements(str))
        return wordCharRegex.numberOfMatchesInString(str, options: nil, range: range) == 0
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool     {
        if action == "cut:" {
            return false
        }
            
        if action == "copy:" {
            return true
        }
            
        if action == "paste:" {
            return true
        }
            
        if action == "_define:" {
            return false
        }
        
        if action == "joinStrings" {
            return self.selectedTextCanBeJoined()
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    func selectedTextCanBeJoined() -> Bool {
        var selectedTextRange: UITextRange = self.selectedTextRange!
        
        var posInit : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)
        var posEnd : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
        var selectionLength : Int = posEnd - posInit
        var selectionTextRange = NSMakeRange(posInit, selectionLength)
        
        let textNSString = self.text as NSString
        var stringFromSelection = textNSString.substringWithRange(selectionTextRange)
        
        var arrayOfWords : [String] = FlipStringsUtil.splitFlipString(stringFromSelection)
        if (arrayOfWords.count > 1) {
            return true
        }
        
        return false
    }
    
    func textViewDidChange(textView: UITextView) {
        joinStringsTextFieldDelegate?.joinStringsTextField?(self, didChangeText: text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (range.location < countElements(self.text)) {
            joinedTextRanges.removeAll(keepCapacity: false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.resetTextColor()
            })
        }
        
        if (text == "\n") {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.joinStringsTextFieldDelegate?.joinStringsTextFieldShouldReturn?(self)
                return
            })
            return false
        }
        
        if (text.rangeOfString("\n") != nil) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.text = self.text.stringByReplacingOccurrencesOfString("\n", withString: " ")
            })
        }
        
        return true
    }
    
    func setWords(words: [String]) {
        let joiner = " "
        var text = "";
        var firstWord = true
        joinedTextRanges = []
        for word in words {
            if (!firstWord) {
                text += " "
            } else {
                firstWord = false
            }
            if (isCompoundText(word)) {
                var compoundTextRange = NSMakeRange(countElements(text), countElements(word))
                joinedTextRanges.append(compoundTextRange)
            }
            text += word
        }
        self.text = text
        self.updateColorOnJoinedTexts(UIColor.flipOrange())
    }
    
    private func isCompoundText(word: String) -> Bool {
        let wordWithoutSpaces = word.removeWhiteSpaces()
        if (wordWithoutSpaces != word) {
            return true
        } else {
            return false
        }
    }
    
}

// MARK: - View Delegate

@objc protocol JoinStringsTextFieldDelegate {
        
    optional func joinStringsTextFieldShouldReturn(joinStringsTextField: JoinStringsTextField) -> Bool
    
    optional func joinStringsTextField(joinStringsTextField: JoinStringsTextField, didChangeText: String!)

}
