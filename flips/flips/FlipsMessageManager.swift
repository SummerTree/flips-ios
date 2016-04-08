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
        
        for pos in (0 ..< words.count) {
            
            let word = words[pos]
            messageWords.append(FlipMessageWord(word: FlipText(position: pos, text: word, state: .NotAssociatedAndNoResourcesAvailable)))
            
            userFlips[word] = Array<String>()
            stockFlips[word] = Array<String>()
            
            let flipPage = FlipPage(word: word, order: pos)
            draftingTable.addFlipToFlipBook(flipPage)
            
        }
        
        self.draftingTable = draftingTable
        
        initFlipsData()
        
    }
    
    func initFlipsData() {
        reloadFlips()
        matchFlipWordsToFirstAvailableFlip()
        updateFlips()
    }
    
    
    
    ////
    // MARK: - Flip Word Data Management
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
    // MARK: - State Setters
    ////
    
    func setCurrentFlipWordIndex(index: Int) {
        
        if index >= 0 && index < messageWords.count {
            messageWordIndex = index
        }
        
    }
    
    
    
    ////
    // MARK: - Current Flip Word Accessors
    ////
    
    func currentFlipWordHasContent() -> (Bool) {
        return flipWordAtIndexHasContent(messageWordIndex)
    }
    
    func currentFlipWordHasPendingChanges() -> (Bool) {
        return flipWordAtIndexHasPendingChanges(messageWordIndex)
    }
    
    func getCurrentFlipWordFlipPage() -> (FlipPage!) {
        return getFlipPageForFlipWordAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordIndex() -> (Int) {
        return messageWordIndex
    }
    
    func getCurrentFlipWord() -> (FlipText) {
        return getFlipWordAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordFlipId() -> (String!) {
        return getFlipIdForFlipWordAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordImage() -> (UIImage!) {
        return getImageForFlipWordAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordAudioURL() -> (NSURL!) {
        return getAudioURLForFlipWordAtIndex(messageWordIndex)
    }
    
    func getCurrentFlipWordVideoURL() -> (NSURL!) {
        return getVideoURLForFlipWordAtIndex(messageWordIndex)
    }
    
    
    
    ////
    // MARK: - Current Flip Word Setters
    ////
    
    func resetCurrentFlipWord() {
        resetFlipWordAtIndex(messageWordIndex)
    }
    
    func setCurrentFlipWordFlipId(flipId: String!) {
        setFlipIdForFlipWordAtIndex(messageWordIndex, flipId: flipId)
        updateFlips()
    }
    
    func setCurrentFlipWordImage(image: UIImage!) {
        setImageForFlipWordAtIndex(messageWordIndex, image: image)
    }
    
    func setCurrentFlipWordAudioURL(audioURL: NSURL!) {
        setAudioURLForFlipWordAtIndex(messageWordIndex, audioURL: audioURL)
    }
    
    func setCurrentFlipWordVideoURL(audioURL: NSURL!) {
        setVideoURLForFlipWordAtIndex(messageWordIndex, videoURL: audioURL)
    }
    
    
    
    ////
    // MARK: - Flip Word Accesssors
    ////
    
    func flipWordAtIndexHasContent(index: Int) -> (Bool) {
        
        let currentWord = messageWords[index]
        let currentPage = getFlipPageForFlipWordAtIndex(index)
        
        // Don't worry about audioURL since a word can only have audio if it already has an image
        return currentWord.getFlipId() != nil || currentWord.getImage() != nil || currentWord.getVideo() != nil || currentPage.videoURL != nil
        
    }
    
    func flipWordAtIndexHasPendingChanges(index: Int) -> (Bool) {
        return index >= 0 && index < messageWords.count ? messageWords[index].hasPendingChanges() : false
    }
    
    func getFlipPageForFlipWordAtIndex(index: Int) -> (FlipPage!) {
        return index >= 0 && index < messageWords.count ? draftingTable.flipPageAtIndex(index) : nil
    }
    
    func getFlipWordAtIndex(index: Int) -> (FlipText!) {
        return index >= 0 && index < messageWords.count ? messageWords[index].word : nil
    }
    
    func getFlipIdForFlipWordAtIndex(index: Int) -> (String!) {
        return index >= 0 && index < messageWords.count ? messageWords[index].getFlipId() : nil
    }
    
    func getImageForFlipWordAtIndex(index: Int) -> (UIImage!) {
        return index >= 0 && index < messageWords.count ? messageWords[index].getImage() : nil
    }
    
    func getAudioURLForFlipWordAtIndex(index: Int) -> (NSURL!) {
        return index >= 0 && index < messageWords.count ? messageWords[index].getAudio() : nil
    }
    
    func getVideoURLForFlipWordAtIndex(index: Int) -> (NSURL!) {
        return index >= 0 && index < messageWords.count ? messageWords[index].getVideo() : nil
    }
    
    
    
    ////
    // MARK: - Flip Word Setters
    ////
    
    func resetFlipWordAtIndex(index: Int) {
        
        if index >= 0 && index < messageWords.count {
            
            let flipWord = messageWords[index]
            flipWord.clear()
            
            let newFlipPage = FlipPage(word: flipWord.word.text, order: flipWord.word.position)
            updateFlipPage(newFlipPage)
            
        }
        
    }
    
    func setFlipIdForFlipWordAtIndex(index: Int, flipId: String!) {
        
        if index >= 0 && index < messageWords.count {
            messageWords[index].setFlipId(flipId)
            draftingTable.flipBook.flipPages[index].pageID = flipId
        }
        
    }
    
    func setImageForFlipWordAtIndex(index: Int, image: UIImage!) {
        
        if index >= 0 && index < messageWords.count {
            messageWords[index].setImage(image)
        }
        
    }
    
    func setAudioURLForFlipWordAtIndex(index: Int, audioURL: NSURL!) {
        
        if index >= 0 && index < messageWords.count {
            messageWords[index].setAudio(audioURL)
        }
        
    }
    
    func setVideoURLForFlipWordAtIndex(index: Int, videoURL: NSURL!) {
        
        if index >= 0 && index < messageWords.count {
            messageWords[index].setVideo(videoURL)
        }
        
    }
    
    
    
    ////
    // MARK: - Flips Data Accessors
    ////
    
    func getUserFlipIdsForCurrentFlipWord() -> ([String]!) {
        return getUserFlipIdsForFlipWordAtIndex(messageWordIndex)
    }
    
    func getUserFlipIdsForFlipWordAtIndex(index: Int) -> ([String]!) {
        
        if index >= 0 && index < messageWords.count {
            
            let flipWord = messageWords[index].word
            
            return userFlips[flipWord.text]
            
        }
        
        return nil
        
    }
    
    func getStockFlipIdsForCurrentFlipWord() -> ([String]!) {
        return getStockFlipIdsForFlipWordAtIndex(messageWordIndex)
    }
    
    func getStockFlipIdsForFlipWordAtIndex(index: Int) -> ([String]!) {
        
        if index >= 0 && index < messageWords.count {
            
            let flipWord = messageWords[index].word
            
            return stockFlips[flipWord.text]
            
        }
        
        return nil
        
    }
    
    
    
    ////
    // MARK: - Message Accessors
    ////
    
    func getFlipWords() -> ([FlipText]!) {
        return messageWords.map({ (messageWord) -> FlipText in
            return messageWord.word
        })
    }
    
    func getFlipWordsCount() -> (Int) {
        return messageWords.count
    }
    
    
    
    ////
    // MARK: - Message State
    ////
    
    func messageHasEmptyFlipWords() -> (Bool) {
        return getIndexForFirstEmptyFlipWord() != -1
    }
    
    func getIndexForFirstEmptyFlipWord() -> (Int) {
        
        for messageWord in messageWords {
            
            let currentPage = getFlipPageForFlipWordAtIndex(messageWord.word.position)
            
            if messageWord.word.associatedFlipId == nil && currentPage.videoURL == nil
            {
                return messageWord.word.position
            }
            
        }
        
        return -1
        
    }
    
    func getIndexForNextEmptyFlipWord() -> (Int) {
        
        for messageWord in messageWords {
            
            if messageWord.word.position == messageWordIndex {
                continue
            }
            
            let currentPage = getFlipPageForFlipWordAtIndex(messageWord.word.position)
            
            if messageWord.word.associatedFlipId == nil && currentPage.videoURL == nil && messageWordIndex != messageWord.word.position
            {
                return messageWord.word.position
            }
            
        }
        
        return -1
        
    }
    
    func messageHasPendingChanges() -> (Bool) {
        
        for messageWord in messageWords {
            
            if messageWord.hasPendingChanges()
            {
                return true
            }
            
        }
        
        return false
        
    }
    
    func getIndexForFirstFlipWordWithPendingChanges() -> (Int) {
        
        for messageWord in messageWords {
            
            if messageWord.hasPendingChanges() {
                return messageWord.word.position
            }
            
        }
        
        return -1
        
    }
    
    
    
    ////
    // MARK: - Flip Page
    ////
    
    func updateFlipPage(flipPage: FlipPage) {
        
        // Replace the existing flip page
        draftingTable.updateFlipInFlipBook(flipPage)
        
        // Update flips data
        updateFlips()
        reloadFlips()
        
    }
    
    
    
    ////
    // MARK: - Flip Video Creation
    ////
    
    internal func createFlipVideoForCurrentWord(successHandler: VideoComposerSuccess) {
        createFlipVideoForWordAtIndex(messageWordIndex, successHandler: successHandler)
    }
    
    internal func createFlipVideoForWordAtIndex(index: Int, successHandler: VideoComposerSuccess) {
        
        let composer = VideoComposer()
        let messageWord = messageWords[index]
        
        messageWord.setHasPendingChanges(false)
        
        if let video = messageWord.getVideo()
        {
            composer.flipVideoFromVideo(video, successHandler: successHandler)
        }
        else if let img = messageWord.getImage(), aud = messageWord.getAudio()
        {
            composer.flipVideoFromImage(img, andAudioURL: aud, successHandler: successHandler)
        }
        else if let img = messageWord.getImage()
        {
            composer.flipVideoFromImage(img, andAudioURL: nil, successHandler: successHandler)
        }
        else
        {
            composer.flipVideoFromImage(nil, andAudioURL: nil, successHandler: successHandler)
        }
        
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
        return getUserFlipIdsForCurrentFlipWord().count
    }
    
    func flipsView(flipsView: FlipsView, flipIdAtIndex index: Int) -> String {
        return getUserFlipIdsForCurrentFlipWord()[index]
    }
    
    func flipsViewNumberOfStockFlips() -> Int {
        return getStockFlipIdsForCurrentFlipWord().count
    }
    
    func flipsView(flipsView: FlipsView, stockFlipIdAtIndex index: Int) -> String {
        return getStockFlipIdsForCurrentFlipWord()[index]
    }
    
    func flipsViewSelectedFlipId() -> String? {
        return getCurrentFlipWordFlipId()
    }
    
}

private class FlipMessageWord {
    
    var word : FlipText!
    var wordImage : UIImage!
    var wordVideo : NSURL!
    var wordAudio : NSURL!
    var pendingChanges: Bool = false
    
    
    
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
        pendingChanges = false
        
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
            
            pendingChanges = true
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
            
            pendingChanges = true
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
            
            pendingChanges = true
        }
        
    }
    
    func setHasPendingChanges(pendingChanges: Bool) {
        self.pendingChanges = pendingChanges
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
    
    
    
    ////
    // MARK: - Utility
    ////
    
    func hasFlip() -> (Bool) {
        return getFlipId() != nil
    }
    
    func hasVideo() -> (Bool) {
        return getVideo() != nil
    }
    
    func hasAudio() -> (Bool) {
        return getAudio() != nil
    }
    
    func hasImage() -> (Bool) {
        return getImage() != nil
    }
    
    func hasPendingChanges() -> (Bool) {
        return pendingChanges
    }
    
}