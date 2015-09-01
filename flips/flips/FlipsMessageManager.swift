//
//  FlipsMessageManager.swift
//  flips
//
//  Created by Taylor Bell on 8/28/15.
//
//

import Foundation

class FlipMessageManager : FlipMessageWordListViewDataSource, FlipsViewDataSource {
    
    private var messageWords : [FlipMessageWord]!
    private var messageWordIndex : Int = 0
    
    private var userFlips : Dictionary<String, [String]>!
    private var stockFlips : Dictionary<String, [String]>!
    
    weak var draftingTable : DraftingTable!
    
    
    
    ////
    // MARK: - Init
    ////
    
    init(words: [String], draftingTable: DraftingTable!) {
        
        messageWords = Array()
        messageWordIndex = 0
        
        userFlips = Dictionary<String, [String]>()
        stockFlips = Dictionary<String, [String]>()
        
        for (var pos = 0; pos < words.count; pos++) {
            
            let word = words[pos]
            messageWords.append(FlipMessageWord(word: FlipText(position: pos, text: word, state: .NotAssociatedAndNoResourcesAvailable)))
            
            userFlips[word] = Array<String>()
            stockFlips[word] = Array<String>()
            
            let flipPage = FlipPage(word: word, order: pos)
            draftingTable.addFlipToFlipBook(flipPage)
            
        }
        
        self.draftingTable = draftingTable
        
    }
    
    
    
    ////
    // Mark: - Public Interface
    ////
    
    func reloadFlips() {
        
        let flipDataSource = FlipDataSource()
        
        let words = messageWords.map({ (messageWord) -> String in
            return messageWord.word.text;
        })
        
        userFlips = flipDataSource.getMyFlipsIdsForWords(words)
        stockFlips = flipDataSource.getStockFlipsIdsForWords(words)
        
        draftingTable.loadFlipsForWords()
        
    }
    
    func updateFlips() {
        
        for messageWord in messageWords {
            
            let word = messageWord.word.text
            let position = messageWord.word.position
            
            let userFlipsForWord = userFlips[word]
            let stockFlipsForWord = stockFlips[word]
            
            let flipPage = draftingTable.flipPageAtIndex(position)
            let localFlipsCount = (flipPage.videoURL != nil ? 1 : 0)
            let availableFlipsCount = localFlipsCount + userFlipsForWord!.count + stockFlipsForWord!.count
            
            if (messageWord.word.associatedFlipId == nil && localFlipsCount == 0)
            {
                messageWord.word.state = availableFlipsCount == 0 ? .NotAssociatedAndNoResourcesAvailable : .NotAssociatedButResourcesAvailable
            }
            else
            {
                messageWord.word.state = availableFlipsCount == 1 ? .AssociatedAndNoResourcesAvailable : .AssociatedAndResourcesAvailable
            }
            
        }
        
        draftingTable.setFlipBookPagesState()
        
    }
    
    func matchFlipWordsToFirstAvailableFlip() {
        
        for messageWord in messageWords {
            
            if let firstFlipId = userFlips[messageWord.word.text]?.first {
                messageWord.setFlipId(firstFlipId)
            }
            
        }
        
        draftingTable.mapWordsToFirstAvailableFlip()
        
    }
    
    
    
    ////
    // MARK: - Pre-Made Flip Accessors
    ////
    
    func getUserFlipsForCurrentWord() -> ([String]!) {
        return getUserFlipsForWord(getCurrentFlipWord())
    }
    
    func getStockFlipsForCurrentWord() -> ([String]!) {
        return getStockFlipsForWord(getCurrentFlipWord())
    }
    
    func getUserFlipsForWord(word: String) -> ([String]!) {
        return userFlips[word]
    }
    
    func getUserFlipsForWord(flipWord: FlipText) -> ([String]!) {
        return getUserFlipsForWord(flipWord.text)
    }
    
    func getStockFlipsForWord(word: String) -> ([String]!) {
        return stockFlips[word]
    }
    
    func getStockFlipsForWord(flipWord: FlipText) -> ([String]!) {
        return getStockFlipsForWord(flipWord.text)
    }
    
    
    
    ////
    // MARK: - Current Word Accessors
    ////
    
    func getCurrentFlipWord() -> (FlipText) {
        return messageWords[messageWordIndex].word
    }
    
    func getCurrentFlipPage() -> (FlipPage) {
        return draftingTable.flipPageAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordIndex() -> (Int) {
        return messageWordIndex
    }
    
    func getCurrentFlipWordImage() -> (UIImage!) {
        return messageWords[messageWordIndex].getImage()
    }
    
    func getCurrentFlipWordVideoURL() -> (NSURL!) {
        return messageWords[messageWordIndex].getVideo()
    }
    
    func getCurrentFlipWordAudioURL() -> (NSURL!) {
        return messageWords[messageWordIndex].getAudio()
    }
    
    
    
    ////
    // MARK: - Utility Accessors
    ////
    
    func getFlipWords() -> ([FlipText]!) {
        return messageWords.map({ (messageWord) -> FlipText in
            return messageWord.word
        })
    }
    
    func getFlipPageForWordAtIndex(index: Int) -> (FlipPage) {
        return draftingTable.flipPageAtIndex(index)
    }
    
    func getIndexForNextEmptyFlipWord() -> (Int) {
        
        for messageWord in messageWords {
            
            let currentPage = getFlipPageForWordAtIndex(messageWord.word.position)
            
            if messageWord.word.associatedFlipId == nil && currentPage.videoURL == nil && messageWordIndex != messageWord.word.position
            {
                return messageWord.word.position
            }
            
        }
        
        return messageWords.count - 1
        
    }
    
    
    
    ////
    // MARK: - Current Word Setters
    ////
    
    func setCurrentFlipWordImage(image: UIImage?) {
        messageWords[messageWordIndex].setImage(image)
    }
    
    func setCurrentFlipWordAudioURL(audioURL: NSURL?) {
        messageWords[messageWordIndex].setAudio(audioURL)
    }
    
    func setCurrentFlipWordVideoURL(videoURL: NSURL?) {
        messageWords[messageWordIndex].setVideo(videoURL)
    }
    
    func setCurrentFlipWordFlip(flip: Flip) {
        messageWords[messageWordIndex].setFlipId(flip.flipID)
        updateFlips()
    }
    
    func setCurrentFlipWordIndex(index: Int) {
        
        if index < messageWords.count {
            messageWordIndex = index
        }
        
    }
    
    func resetCurrentFlipWord() {
        resetFlipWordAtIndex(getCurrentFlipWordIndex())
    }
    
    func resetFlipWordAtIndex(index: Int) {
        
        let messageWord = messageWords[index]
        
        messageWord.clear()
        
        let newFlipPage = FlipPage(word: messageWord.word.text, order: messageWord.word.position)
        updateFlipPage(newFlipPage)
        
    }
    
    func updateFlipPage(flipPage: FlipPage) {
        
        // Replace the existing flip page
        draftingTable.updateFlipInFlipBook(flipPage)
        
        // Update flips data
        updateFlips()
        reloadFlips()
        
    }
    
    
    
    
    ////
    // MARK: - Utility
    ////
    
    internal func shouldCreateFlipForCurrentWord() -> (Bool) {
        
        let currentWord = getCurrentFlipWord()
        let currentPage = getCurrentFlipPage()
        
        return currentWord.associatedFlipId == nil && currentPage.videoURL == nil && currentFlipWordHasContent()
        
    }
    
    internal func currentFlipWordHasContent() -> (Bool) {
        
        let currentWord = messageWords[messageWordIndex]
        let currentPage = getCurrentFlipPage()
        
        // Don't worry about audioURL since a word can only have audio if it already has an image
        return currentWord.getFlipId() != nil || currentWord.getImage() != nil || currentWord.getVideo() != nil || currentPage.videoURL != nil
        
    }
    
    
    
    ////
    // Mark: - FlipMessageWordListViewDataSource
    ////
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> FlipText {
        return messageWords[index].word
    }
    
    func numberOfFlipWords() -> Int {
        return messageWords.count
    }
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int {
        return messageWordIndex
    }
   
    
    
    ////
    // MARK: - FlipsViewDelegate
    ////
    
    func flipsViewNumberOfFlips() -> Int {
        return self.getUserFlipsForWord(self.getCurrentFlipWord()).count
    }
    
    func flipsView(flipsView: FlipsView, flipIdAtIndex index: Int) -> String {
        return self.getUserFlipsForWord(self.getCurrentFlipWord())[index]
    }
    
    func flipsViewNumberOfStockFlips() -> Int {
        return self.getStockFlipsForWord(self.getCurrentFlipWord()).count
    }
    
    func flipsView(flipsView: FlipsView, stockFlipIdAtIndex index: Int) -> String {
        return self.getStockFlipsForWord(self.getCurrentFlipWord())[index]
    }
    
    func flipsViewSelectedFlipId() -> String? {
        return self.getCurrentFlipWord().associatedFlipId!
    }
    
}

private class FlipMessageWord {
    
    var word : FlipText!
    var wordImage : UIImage!
    var wordVideo : NSURL!
    var wordAudio : NSURL!
    
    
    
    ////
    // MARK: - Init
    ////
    
    init(word : FlipText) {
        self.word = word
    }
    
    
    
    ////
    // MARK: - Clear
    ////
    
    func clear() {
        
        wordVideo = nil
        wordImage = nil
        wordAudio = nil
        
        word.associatedFlipId = nil
        
    }
    
    
    
    ////
    // MARK: - Setters
    ////
    
    func setFlipId(flipId: String) {
        
        word.associatedFlipId = flipId
        
        wordVideo = nil
        wordImage = nil
        wordAudio = nil
        
    }
    
    func setImage(image: UIImage?) {
        
        if let image = image
        {
            // Set the video URL
            wordImage = image
            
            // Clear the image and audio
            wordVideo = nil
            
            // Clear any associated flips
            word.associatedFlipId = nil
        }
        
    }
    
    func setAudio(audioURL: NSURL?) {
        
        if let audioURL = audioURL
        {
            // Set the video URL
            wordAudio = audioURL
            
            // Clear the video
            wordVideo = nil
            
            // Clear any associated flips
            word.associatedFlipId = nil
        }
        
    }
    
    func setVideo(videoURL: NSURL?) {
        
        if let videoURL = videoURL
        {
            // Set the video URL
            wordVideo = videoURL
            
            // Clear the image and audio
            wordAudio = nil
            wordImage = nil
            
            // Clear any associated flips
            word.associatedFlipId = nil
        }
        
    }
    
    
    
    ////
    // MARK: - Getters
    ////
    
    func getFlipId() -> (String?) {
        return word.associatedFlipId
    }
    
    func getVideo() -> (NSURL?) {
        return wordVideo
    }
    
    func getImage() -> (UIImage?) {
        return wordImage
    }
    
    func getAudio() -> (NSURL?) {
        return wordAudio
    }
    
}