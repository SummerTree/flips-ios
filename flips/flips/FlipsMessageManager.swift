//
//  FlipsMessageManager.swift
//  flips
//
//  Created by Taylor Bell on 8/28/15.
//
//

import Foundation

class FlipMessageManager : FlipMessageWordListViewDataSource, FlipsViewDataSource {
    
    private var flipWords : [FlipText]!
    private var flipWordIndex : Int = 0
    private var flipWordImage : UIImage!
    private var flipWordVideo : NSURL!
    private var flipWordAudio : NSURL!
    
    private var userFlips : Dictionary<String, [String]>!
    private var stockFlips : Dictionary<String, [String]>!
    
    weak var draftingTable : DraftingTable!
    
    
    
    ////
    // MARK: - Init
    ////
    
    init(words: [String], draftingTable: DraftingTable!) {
        
        flipWords = Array()
        flipWordIndex = 0
        
        userFlips = Dictionary<String, [String]>()
        stockFlips = Dictionary<String, [String]>()
        
        for (var pos = 0; pos < words.count; pos++) {
            
            let word = words[pos]
            let flipWord = FlipText(position: pos, text: word, state: .NotAssociatedAndNoResourcesAvailable)
            
            flipWords.append(flipWord)
            
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
        
        let words = flipWords.map({ (flipWord) -> String in
            return flipWord.text;
        })
        
        userFlips = flipDataSource.getMyFlipsIdsForWords(words)
        stockFlips = flipDataSource.getStockFlipsIdsForWords(words)
        
        draftingTable.loadFlipsForWords()
        
    }
    
    func updateFlips() {
        
        for flipWord in flipWords {
            
            let flipPage = draftingTable.flipPageAtIndex(flipWord.position)
            let userFlipsForWord = userFlips[flipWord.text]
            let stockFlipsForWord = stockFlips[flipWord.text]
            let localFlipsCount = (flipPage.videoURL != nil ? 1 : 0)
            let availableFlipsCount = localFlipsCount + userFlipsForWord!.count + stockFlipsForWord!.count
            
            if (flipWord.associatedFlipId == nil && localFlipsCount == 0)
            {
                flipWord.state = availableFlipsCount == 0 ? .NotAssociatedAndNoResourcesAvailable : .NotAssociatedButResourcesAvailable
            }
            else
            {
                flipWord.state = availableFlipsCount == 1 ? .AssociatedAndNoResourcesAvailable : .AssociatedAndResourcesAvailable
            }
            
        }
        
        draftingTable.setFlipBookPagesState()
        
    }
    
    func matchFlipWordsToFirstAvailableFlip() {
        
        for flipWord in flipWords {
            
            if let firstFlipId = userFlips[flipWord.text]?.first {
                flipWord.associatedFlipId = firstFlipId
            }
            
        }
        
        draftingTable.mapWordsToFirstAvailableFlip()
        
    }
    
    
    
    ////
    // MARK: - Getters
    ////
    
    func getUserFlipsForWord(word: String) -> ([String]!) {
        return userFlips[word]
    }
    
    func getUserFlipsForWord(flipWord: FlipText) -> ([String]!) {
        return getUserFlipsForWord(flipWord.text)
    }
    
    func getUserFlipsForCurrentWord() -> ([String]!) {
        return getUserFlipsForWord(getCurrentFlipWord())
    }
    
    func getStockFlipsForWord(word: String) -> ([String]!) {
        return stockFlips[word]
    }
    
    func getStockFlipsForWord(flipWord: FlipText) -> ([String]!) {
        return getStockFlipsForWord(flipWord.text)
    }
    
    func getStockFlipsForCurrentWord() -> ([String]!) {
        return getStockFlipsForWord(getCurrentFlipWord())
    }
    
    func getFlipWords() -> ([FlipText]!) {
        return flipWords
    }
    
    func getCurrentFlipWord() -> (FlipText) {
        return flipWords[flipWordIndex]
    }
    
    func getFlipPageForWordAtIndex(index: Int) -> (FlipPage) {
        return draftingTable.flipPageAtIndex(index)
    }
    
    func getCurrentFlipPage() -> (FlipPage) {
        return draftingTable.flipPageAtIndex(flipWordIndex)
    }
    
    func getCurrentFlipWordIndex() -> (Int) {
        return flipWordIndex
    }
    
    func getCurrentFlipWordImage() -> (UIImage!) {
        return flipWordImage
    }
    
    func getCurrentFlipWordVideoURL() -> (NSURL!) {
        return flipWordVideo
    }
    
    func getCurrentFlipWordAudioURL() -> (NSURL!) {
        return flipWordAudio
    }
    
    func getIndexForNextEmptyFlipWord() -> (Int) {
        
        for flipWord in flipWords {
            
            let currentPage = getFlipPageForWordAtIndex(flipWord.position)
            
            if flipWord.associatedFlipId == nil && currentPage.videoURL == nil && flipWordIndex != flipWord.position
            {
                return flipWord.position
            }
            
        }
        
        return flipWords.count - 1
        
    }
    
    
    
    ////
    // MARK: - Setters
    ////
    
    func setCurrentFlipWordFlip(flip: Flip) {
        
        let currentWord = getCurrentFlipWord()
        currentWord.associatedFlipId = flip.flipID
        
        updateFlips()
        
    }
    
    func setCurrentFlipWordIndex(index: Int) {
        
        if index < flipWords.count {
            flipWordIndex = index
            flipWordImage = nil
        }
        
    }
    
    func resetCurrentFlipWord() {
        resetFlipWordAtIndex(getCurrentFlipWordIndex())
    }
    
    func resetFlipWordAtIndex(index: Int) {
        
        // Reset the FlipPage for the current word
        let flipWord = flipWords[index]
        flipWord.associatedFlipId = nil
        
        let newFlipPage = FlipPage(word: flipWord.text, order: flipWord.position)
        updateFlipPage(newFlipPage)
        
        // Disassociate the current image
        setCurrentFlipWordVideoURL(nil)
        setCurrentFlipWordAudioURL(nil)
        setCurrentFlipWordImage(nil)
        
    }
    
    func updateFlipPage(flipPage: FlipPage) {
        
        // Replace the existing flip page
        draftingTable.updateFlipInFlipBook(flipPage)
        
        // Update flips data
        updateFlips()
        reloadFlips()
        
    }
    
    func setCurrentFlipWordImage(image: UIImage?) {
        flipWordImage = image
    }
    
    func setCurrentFlipWordAudioURL(audioURL: NSURL?) {
        flipWordAudio = audioURL
    }
    
    func setCurrentFlipWordVideoURL(videoURL: NSURL?) {
        flipWordVideo = videoURL
    }
    
    
    
    ////
    // MARK: - Utility
    ////
    
    internal func shouldCreateFlipForCurrentWord() -> (Bool) {
        
        let currentWord = getCurrentFlipWord()
        let currentPage = getCurrentFlipPage()
        
        return currentWord.associatedFlipId == nil && currentPage.videoURL == nil
        
    }
    
    internal func currentFlipWordHasContent() -> (Bool) {
        
        let currentWord = getCurrentFlipWord()
        let currentPage = getCurrentFlipPage()
        
        return currentWord.associatedFlipId != nil || flipWordImage != nil || flipWordVideo != nil || flipWordAudio != nil || currentPage.videoURL != nil
        
    }
    
    
    
    ////
    // Mark: - FlipMessageWordListViewDataSource
    ////
    
    func flipMessageWordListView(flipMessageWordListView: FlipMessageWordListView, flipWordAtIndex index: Int) -> FlipText {
        return flipWords[index]
    }
    
    func numberOfFlipWords() -> Int {
        return flipWords.count
    }
    
    func flipMessageWordListViewHighlightedWordIndex(flipMessageWordListView: FlipMessageWordListView) -> Int {
        return flipWordIndex
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