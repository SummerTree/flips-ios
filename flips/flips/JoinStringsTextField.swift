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
    
    weak var joinStringsTextFieldDelegate: JoinStringsTextFieldDelegate?
    
    override init() {
        super.init(frame: CGRect.zeroRect, textContainer: nil)
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
        
        var posInit : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)
        var posEnd : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
        
        var newPosInit = posInit
        var newPosEnd = posEnd
        var string = Array(self.text)
        let firstCharIsSpecial = isSpecialCharacter(string[posInit])
        if (string[posInit] != WHITESPACE) {
            for var i = posInit-1; i >= 0; --i {
                if (string[i] == WHITESPACE || isSpecialCharacter(string[i]) ^ firstCharIsSpecial) {
                    break
                }
                --newPosInit
            }
        }
        
        let lastCharIsSpecial = isSpecialCharacter(string[posEnd-1])
        if (string[posEnd-1] != WHITESPACE) {
            for var i = posEnd; i < string.count; ++i {
                if (string[i] == WHITESPACE || isSpecialCharacter(string[i]) ^ lastCharIsSpecial) {
                    break
                }
                ++newPosEnd
            }
        }
        
        var joinedTextRange = NSMakeRange(newPosInit, newPosEnd-newPosInit)
        
        self.joinedTextRanges.append(joinedTextRange)

        self.updateColorOnJoinedTexts(UIColor.flipOrange())
    }
    
    func updateColorOnJoinedTexts(color: UIColor) {
        var attributedString = NSMutableAttributedString(string:self.text + " ")
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: 0, length: countElements(self.text))) //looses the current font, if we don't set here explicitly
        
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
            
        else if action == "copy:" {
            return true
        }
            
        else if action == "paste:" {
            return true
        }
            
        else if action == "_define:" {
            return false
        }
        
        else if action == "joinStrings" {
            if (self.selectedTextCanBeJoined()) {
                return true
            }
            return false
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
        var currentFrameHeight: CGFloat = self.frame.size.height
        var neededFrameHeight = self.contentSize.height

        if (neededFrameHeight != currentFrameHeight) {
            joinStringsTextFieldDelegate?.joinStringsTextFieldNeedsToHaveItsHeightUpdated(self)
        }
        
        joinStringsTextFieldDelegate?.joinStringsTextField?(self, didChangeText: text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //For now, to simplify, after joining some words, the user can only type new text in the end of the text view
        //If the user removes or inserts characters changing the current text, the previously joined texts are lost
        if (range.location < countElements(self.text)) {
            joinedTextRanges.removeAll(keepCapacity: false)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.resetTextColor()
            })
        }
        
        //handling when user changes (delete or replace) parts of a previously joined text
        /*var deprecatedJoinedTextRange : UITextRange?
        var index : Int = 0
        for textRange in joinedTextRanges {
            var posInit : Int = textRange.location
            var posEnd : Int = textRange.location + textRange.length
            
            if (range.location >= posInit && range.location < posEnd) {
                deprecatedJoinedTextRange = textRange
                break
            }
            index++
        }
        
        if (deprecatedJoinedTextRange != nil) {
            joinedTextRanges.removeAtIndex(index)
            //If the position of this character is part of a joined text, this text should have its color changed to black again.
            self.setColorOnTextRange(deprecatedJoinedTextRange!, color: UIColor.blackColor())
        }*/
        
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
    
    optional func joinStringsTextFieldNeedsToHaveItsHeightUpdated(joinStringsTextField: JoinStringsTextField!)
    
    optional func joinStringsTextFieldShouldReturn(joinStringsTextField: JoinStringsTextField) -> Bool
    
    optional func joinStringsTextField(joinStringsTextField: JoinStringsTextField, didChangeText: String!)

}
