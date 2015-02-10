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

struct BuilderWordAttributes {
    static let WORD = "word"
    static let FROM_SERVER = "fromServer"
    static let ADDED_AT = "addedAt"
}

class BuilderWordDataSource: BaseDataSource {
    
    func cleanWordsFromServer() {
        var predicate = NSPredicate(format: "\(BuilderWordAttributes.FROM_SERVER) == true")
        BuilderWord.deleteAllMatchingPredicate(predicate, inContext: currentContext)
//        self.save()
    }
    
    func addWords(words: [String], fromServer: Bool) {
        for word in words {
            var predicate = NSPredicate(format: "%K like %@", BuilderWordAttributes.WORD, word)
            var existingWord = BuilderWord.findAllWithPredicate(predicate, inContext: currentContext)
            if (existingWord.count == 0) {
                var builderWord = BuilderWord.createInContext(currentContext) as BuilderWord
                builderWord.word = word
                builderWord.fromServer = fromServer
                builderWord.addedAt = NSDate()
            }
        }
//        self.save()
    }
    
    func addWord(word: String, fromServer: Bool) -> Bool {
        var result: Bool!
        var predicate = NSPredicate(format: "%K like %@", BuilderWordAttributes.WORD, word)
        var existingWord = BuilderWord.findAllWithPredicate(predicate, inContext: currentContext)
        if (existingWord.count > 0) {
            result = false // DO NOT DUPLICATE
        } else {
            var builderWord = BuilderWord.createInContext(currentContext) as BuilderWord
            builderWord.word = word
            builderWord.fromServer = fromServer
            builderWord.addedAt = NSDate()
            result = true
        }
//        self.save()
        
        return result
    }
    
    func getWords() -> [BuilderWord] {
        return BuilderWord.findAllSortedBy(BuilderWordAttributes.ADDED_AT, ascending: false, inContext: currentContext) as [BuilderWord]
    }
    
    func removeBuilderWordWithWord(word: String) {
        println("\nRemoving builder word: \(word)")
        var predicate = NSPredicate(format: "%K like %@", BuilderWordAttributes.WORD, word)
        BuilderWord.deleteAllMatchingPredicate(predicate, inContext: currentContext)

//        self.save()
    }
}
