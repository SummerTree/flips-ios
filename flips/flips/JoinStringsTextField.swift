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
    
    private let NUM_WORDS_LIMIT = 60
    
    private var joinedTextRanges : [NSRange] = [NSRange]()
    private let wordCharRegex = NSRegularExpression(pattern: "\\w", options: nil, error: nil)!
    private var rangeThatWillChange: NSRange? = nil
    private let WHITESPACE: Character = " "
    let DEFAULT_HEIGHT: CGFloat = 38.0
    let DEFAULT_LINE_HEIGHT: CGFloat = 20.0
    let JOINED_COLOR: UIColor = UIColor.flipOrange()
    
    weak var joinStringsTextFieldDelegate: JoinStringsTextFieldDelegate?
    
    var numberOfLines: Int {
        get {
            return Int(self.contentSize.height/self.font.lineHeight)
        }
    }
    
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
        var attributedString = NSMutableAttributedString(string: self.text)
        let textLength = (self.text as NSString).length
        attributedString.addAttribute(NSFontAttributeName, value: self.font, range: NSMakeRange(0, textLength))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, textLength))
        
        for joinedTextRange in joinedTextRanges {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: JOINED_COLOR, range: joinedTextRange)
        }

        self.attributedText = attributedString
        self.selectedTextRange = selectedTextRange
    }
    
    private func getTextWords(text: String, limit: Int = -1) -> (words: [String], truncatedText: String) {
        var words = [String]()
        var textArray = Array(text)
        var word: String = ""
        var index: Int = 0
        var limitIndex: Int = -1
        
        while (index < textArray.count) {
            if (limitIndex == -1 && limit >= 0 && words.count >= limit) {
                limitIndex = index
            }
            
            let partOfRange = isPartOfJoinedTextRanges(index)
            if (partOfRange.isPart) {
                if (countElements(word) > 0) {
                    words.append(word)
                    word = ""
                }
                words.append((text as NSString).substringWithRange(partOfRange.range!))
                index = partOfRange.range!.location+partOfRange.range!.length
            } else {
                let i = index++
                if (countElements(word) > 0 && (textArray[i] == WHITESPACE || (isSpecialCharacter(Array(word)[0]) ^ isSpecialCharacter(textArray[i])))) {
                    words.append(word)
                    word = ""
                }
                
                if (textArray[i] != WHITESPACE) {
                    word.append(textArray[i])
                }
            }
        }
        
        if (word != "") {
            words.append(word)
        }
        
        var truncatedText = text
        if (limitIndex >= 0) {
            truncatedText = text.substringToIndex(advance(text.startIndex, limitIndex))
        }

        return (words, truncatedText)
    }
    
    func getTextWords() -> [String] {
        self.resignFirstResponder()
        let textWords = self.getTextWords(self.text)
        self.becomeFirstResponder()
        
        return textWords.words
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
        let range = NSRange(location: 0, length: (str as NSString).length)
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
    
    func handleMultipleLines(height: CGFloat) {
        if (numberOfLines > 1) {
            let y = self.contentSize.height-height
            let cursorRect = self.caretRectForPosition(self.selectedTextRange?.start)
            if (cursorRect.origin.y < y) {
                let cursorLineRect = CGRectMake(0, cursorRect.origin.y, self.contentSize.width, cursorRect.size.height)
                self.scrollRectToVisible(cursorLineRect, animated: false)
            } else {
                let lastLinesRect = CGRectMake(0, y, self.contentSize.width, height)
                self.scrollRectToVisible(lastLinesRect, animated: false)
            }
        }
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
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let textWords = self.getTextWords(newText, limit: NUM_WORDS_LIMIT)
        
        if (textWords.words.count > NUM_WORDS_LIMIT) {
            self.text = textWords.truncatedText // " ".join(words[0..<NUM_WORDS_LIMIT])
            
            let limitAlert = UIAlertView(title: NSLocalizedString("Flips"), message: NSLocalizedString("Flip Messages cannot be longer than 60 words."), delegate: nil, cancelButtonTitle: NSLocalizedString("OK"))
            limitAlert.show()
            
            joinStringsTextFieldDelegate?.joinStringsTextField?(self, didChangeText: self.text)
            
            return false
        }
        
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
                var compoundTextRange = NSMakeRange((text as NSString).length, (word as NSString).length)
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
