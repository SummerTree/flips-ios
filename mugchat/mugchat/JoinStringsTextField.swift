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
    
    var joinedTextRanges : [NSRange] = [NSRange]()
    
    override init() {
        super.init(frame: CGRect.zeroRect, textContainer: nil)
        
        self.delegate = self
        
        self.setUpMenu()
        
        //self.backgroundColor = UIColor.redColor()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer!) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpMenu() {
        let menuController = UIMenuController.sharedMenuController()
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Join", comment: "Join"), action: "joinStrings")
        menuController.menuItems = NSArray(array: [lookupMenu])
        menuController.update();
        menuController.setMenuVisible(true, animated: true)
    }
    
    func joinStrings() {
        var selectedTextRange: UITextRange = self.selectedTextRange!
        
        var posInit : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.start)
        var posEnd : Int = self.offsetFromPosition(self.beginningOfDocument, toPosition: selectedTextRange.end)
        var selectionLength : Int = posEnd - posInit
        var joinedTextRange = NSMakeRange(posInit, selectionLength)
        
        self.joinedTextRanges.append(joinedTextRange)

        self.updateColorOnJoinedTexts(UIColor.mugOrange())
    }
    
    func updateColorOnJoinedTexts(color: UIColor) {
        var attributedString = NSMutableAttributedString(string:self.text)
        
        for joinedTextRange in joinedTextRanges {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color, range: joinedTextRange)
        }
        
        self.attributedText = attributedString
    }
    
    func resetTextColor() {
        var attributedString = NSMutableAttributedString(string:self.text)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, self.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        self.attributedText = attributedString
    }
    
    func getMugTexts() -> [String] {
        var mugTexts : [String] = [String]()
        
        var charIndex = 0
        var lastWord: String = ""
        let whitespace: Character = " "
        
        for character in self.text {
            if (character == whitespace) {
                if (isPartOfJoinedTextRanges(charIndex)) {
                    lastWord.append(character)
                } else {
                    mugTexts.append(lastWord)
                    lastWord = ""
                }
            } else if (isSpecialCharacter(character)) {
                if (hasSpecialCharacters(lastWord)) {
                    lastWord.append(character)
                } else {
                    if (isPartOfJoinedTextRanges(charIndex)) {
                        lastWord.append(character)
                    } else {
                        mugTexts.append(lastWord)
                        lastWord = ""
                        lastWord.append(character)
                    }
                }
            } else {
                lastWord.append(character)
            }
            
            charIndex++
        }
        mugTexts.append(lastWord)
        
        return mugTexts
    }
    
    func isPartOfJoinedTextRanges(charIndex: Int) -> Bool {
        for textRange in self.joinedTextRanges {
            var posInit : Int = textRange.location
            var posEnd : Int = textRange.location + textRange.length
            if (posInit <= charIndex && charIndex < posEnd) {
                return true
            }
        }
        return false
    }
    
    func hasSpecialCharacters(text : String) -> Bool {
        for character in text {
            if (isSpecialCharacter(character)) {
                return true
            }
        }
        return false
    }
    
    func isSpecialCharacter(charac : Character) -> Bool {
        if (charac == Character(",") || charac == Character(";") || charac == Character(".") || charac == Character("!") || charac == Character("?") ) {
            return true
        }
        return false
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool     {
        if action == "cut:" {
            return false;
        }
            
        else if action == "copy:" {
            return false;
        }
            
        else if action == "paste:" {
            return false;
        }
            
        else if action == "_define:" {
            return false;
        }
        
        else if action == "Join" {
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    //func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //For now, to simplify, after joining some words, the user can only type new text in the end of the text view
        //If the user removes or inserts characters changing the current text, the previously joined texts are lost
        if (range.location < self.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) {
            self.resetTextColor()
            joinedTextRanges.removeAll(keepCapacity: false)
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
        
        return true
    }
    
}
