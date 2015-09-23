//
//  FlipBook.swift
//  flips
//
//  Created by Noah Labhart on 7/24/15.
//
//

import Foundation

class FlipBook : NSObject {

    var flipID : String?
    var flipPages : [FlipPage]
    var flipMessage : String {
        get {
            var message : String = ""
            for (index, flip) in self.flipPages.enumerate() {
                message += "\(flip.word) "
            }
            return message
        }
    }
    var flipWords : [String]? {
        get {
            var words : [String] = []
            for (index, flip) in self.flipPages.enumerate() {
                words += [flip.word]
            }
            return words
        }
    }
    
    // MARK: - Init methods
    
    override init () {
        self.flipPages = Array<FlipPage>()
        super.init()
    }
    
    init (pages: [FlipPage]) {
        self.flipPages = pages
        super.init()
    }
    
    // MARK: - Flipbook mgmt methods
    
    func addFlip(flip: FlipPage, atLocation location: Int = -1) {
        if location != -1 {
            self.flipPages.insert(flip, atIndex: location)
        }
        else {
            self.flipPages.append(flip)
        }
    }
    
    func replaceFlip(flip: FlipPage) {
            self.flipPages[flip.order] = flip
    }
    
    func removeFlip(atLocation location: Int = -1) {
        if location != -1 {
            self.flipPages.removeAtIndex(location)
        }
        else if self.flipPages.count > 0 {
            self.flipPages.removeLast()
        }
    }
}

class FlipPage {
    var pageID : String?
    var videoURL : NSURL?
    var thumbnailURL : NSURL?
    var word : String
    var order : Int
    var state : FlipState
    
    init(word: String, order: Int) {
        self.word = word
        self.order = order
        self.state = FlipState.NotAssociatedAndNoResourcesAvailable
    }
    
    init(videoURL: NSURL, thumbnailURL: NSURL, word: String) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.word = word
        self.order = -1
        self.state = FlipState.AssociatedAndNoResourcesAvailable
    }
    
    init(videoURL: NSURL, thumbnailURL: NSURL, word: String, order: Int) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.word = word
        self.order = order
        self.state = FlipState.AssociatedAndNoResourcesAvailable
    }
    
    func createFlip() -> Flip! {
        let flipDataSource = FlipDataSource()
        let flip = flipDataSource.createEmptyFlipWithWord(self.word)
        flip.flipID = "\(self.word)_createdFromFlipPage"
        flip.backgroundURL = self.videoURL!.absoluteString
        flip.thumbnailURL = self.thumbnailURL!.absoluteString
        return flip
    }
}
