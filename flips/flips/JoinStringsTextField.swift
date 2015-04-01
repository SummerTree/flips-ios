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
    private var rangeThatWillChange: NSRange? = nil
    private let WHITESPACE: Character = " "
    let DEFAULT_HEIGHT: CGFloat = 38.0
    let DEFAULT_LINE_HEIGHT: CGFloat = 20.0
    let JOINED_COLOR: UIColor = UIColor.flipOrange()
    
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
        
        var newRanges = [NSRange]()
        for (var i = 0; i < self.joinedTextRanges.count; ++i) {
            let range = self.joinedTextRanges[i]
            let intersection = NSIntersectionRange(NSMakeRange(posInit, posEnd-posInit), range)
            if (intersection.length > 0) {
                posInit = min(posInit, range.location)
                posEnd = max(posEnd, range.location+range.length)
            } else {
                newRanges.append(range)
            }
        }
        newRanges.append(NSMakeRange(posInit, posEnd-posInit))
        self.joinedTextRanges = newRanges

        self.updateColorOnJoinedTexts()
    }
    
    private func updateColorOnJoinedTexts() {
        var selectedTextRange = self.selectedTextRange
        var attributedString = NSMutableAttributedString(string:self.text)
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSRange(location: 0, length: countElements(self.text)))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, countElements(self.text)))
        
        for joinedTextRange in joinedTextRanges {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: JOINED_COLOR, range: joinedTextRange)
        }

        self.attributedText = attributedString
        self.selectedTextRange = selectedTextRange
    }
    
    func getFlipTexts() -> [String] {
        self.resignFirstResponder()
        
        var flipTexts = [String]()
        
        var text = Array(self.text)
        var word: String = ""
        var index: Int = 0
        while (index < text.count) {
            let partOfRange = isPartOfJoinedTextRanges(index)
            if (partOfRange.isPart) {
                if (countElements(word) > 0) {
                    flipTexts.append(word)
                    word = ""
                }
                flipTexts.append((self.text as NSString).substringWithRange(partOfRange.range!))
                index = partOfRange.range!.location+partOfRange.range!.length
            } else {
                let i = index++
                if (countElements(word) > 0 && (text[i] == WHITESPACE || (isSpecialCharacter(Array(word)[0]) ^ isSpecialCharacter(text[i])))) {
                    flipTexts.append(word)
                    word = ""
                }
                
                if (text[i] != WHITESPACE) {
                    word.append(text[i])
                }
            }
        }
        
        if (word != "") {
            flipTexts.append(word)
        }
        
        self.becomeFirstResponder()
        
        return flipTexts
    }
    
    func isPartOfJoinedTextRanges(charIndex: Int) -> (isPart: Bool, range: NSRange?) {
        for textRange in self.joinedTextRanges {
            let posInit = textRange.location
            let posEnd = textRange.location + textRange.length
            if (posInit <= charIndex && charIndex < posEnd) {
                return (true, textRange)
            }
        }
        return (false, nil)
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
        
        var posInit: Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)
        var posEnd: Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
        var selectionTextRange = NSMakeRange(posInit, posEnd-posInit)
        
        let textNSString = self.text as NSString
        var stringFromSelection = textNSString.substringWithRange(selectionTextRange)
        
        var arrayOfWords = FlipStringsUtil.splitFlipString(stringFromSelection)
        return arrayOfWords.count > 1
    }
    
    func textViewDidChange(textView: UITextView) {
        if (self.text.rangeOfString("\n") != nil) {
            self.text = self.text.stringByReplacingOccurrencesOfString("\n", withString: " ")
        }
        
        if let range = self.rangeThatWillChange {
            var newRanges = [NSRange]()
            for (var i = 0; i < self.joinedTextRanges.count; ++i) {
                let joinedRange = self.joinedTextRanges[i]
                if (range.length == 0) {
                    if (range.location < joinedRange.location || range.location >= joinedRange.location+joinedRange.length) {
                        newRanges.append(joinedRange)
                    }
                } else {
                    let intersection = NSIntersectionRange(range, joinedRange)
                    if (intersection.length == 0) {
                        newRanges.append(joinedRange)
                    }
                }
            }
            self.joinedTextRanges = newRanges
            self.rangeThatWillChange = nil
            self.updateColorOnJoinedTexts()
        }
        
        joinStringsTextFieldDelegate?.joinStringsTextField?(self, didChangeText: text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.joinStringsTextFieldDelegate?.joinStringsTextFieldShouldReturn?(self)
                return
            })
            return false
        }
        
        self.rangeThatWillChange = range
        return true
    }
    
    func setWords(words: [String]) {
        let joiner = " "
        var text = "";
        var firstWord = true
        self.joinedTextRanges.removeAll(keepCapacity: false)
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
        self.updateColorOnJoinedTexts()
    }
    
    private func isCompoundText(word: String) -> Bool {
        let wordWithoutSpaces = word.removeWhiteSpaces()
        return wordWithoutSpaces != word
    }
    
}

// MARK: - View Delegate

@objc protocol JoinStringsTextFieldDelegate {
        
    optional func joinStringsTextFieldShouldReturn(joinStringsTextField: JoinStringsTextField) -> Bool
    
    optional func joinStringsTextField(joinStringsTextField: JoinStringsTextField, didChangeText: String!)

}
