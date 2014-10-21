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

class JoinStringsTextField : UITextField, UITextFieldDelegate {
    
    //var joinStringsTextFieldDelegate : JoinStringsTextFieldDelegate?
    //var mugTexts : [String] = [String]()
    var joinedTextRanges : [UITextRange] = [UITextRange]()
    
    override init() {
        super.init()
        self.delegate = self
        
        let menuController = UIMenuController.sharedMenuController()
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Join", comment: "Join"), action: "joinStrings")
        menuController.menuItems = NSArray(array: [lookupMenu])
        
        menuController.update();
        
        menuController.setMenuVisible(true, animated: true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func joinStrings() {
        var selectedRange: UITextRange = self.selectedTextRange!
        
        var selectedText = self.textInRange(selectedRange)
        println(">>> Joined: \(selectedText)")
        
        self.joinedTextRanges.append(selectedRange)
        
        //self.joinStringsTextFieldDelegate?.didJoinedWords(self, finalString: selectedText)
        //TODO
    }
    
    //TODO: consider joined words (self.joinedTextRanges ([UITextRange]))
    func getMugTexts() -> [String] {
        var mugTexts : [String] = [String]()
        
        var charIndex = 0
        var lastWord: String = ""
        let whitespace: Character = " "
        
        for character in self.text {
            println(">>> charIndex: \(charIndex); char: \(character)")
            
            if (character == whitespace) {
                mugTexts.append(lastWord)
                lastWord = ""
            } else if (isSpecialCharacter(character)) {
                if (hasSpecialCharacters(lastWord)) {
                    lastWord.append(character)
                } else {
                    mugTexts.append(lastWord)
                    lastWord = ""
                    lastWord.append(character)
                }
            } else {
                lastWord.append(character)
            }
            
            charIndex++
        }
        mugTexts.append(lastWord)
        
        return mugTexts
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print(self.text)
        
        //TODO: delete
        
        return true
    }
    
}

//protocol JoinStringsTextFieldDelegate {
//    
//    func didJoinedWords(joinStringsTextField: JoinStringsTextField!, finalString: String!)
//    
//}
