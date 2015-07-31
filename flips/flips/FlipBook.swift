//
//  FlipBook.swift
//  flips
//
//  Created by Noah Labhart on 7/24/15.
//
//

import Foundation

class FlipBook {

    var flipID : String?
    var flipPages : [FlipPage]?
    var flipMessage : String {
        get {
            var message : String = ""
            for (index, flip) in enumerate(self.flipPages!) {
                message += "\(flip.word) "
            }
            return message
        }
    }
    var flipWords : [String]? {
        get {
            var words : [String] = []
            for (index, flip) in enumerate(self.flipPages!) {
                words += [flip.word]
            }
            return words
        }
    }
    
    // MARK: - Init methods
    
    init () {
        self.flipPages = []
    }
    
    init (pages: [FlipPage]?) {
        self.flipPages = pages
    }
    
    // MARK: - Flipbook mgmt methods
    
    func addFlip(flip: FlipPage, atLocation location: Int = -1) {
        if let pages = self.flipPages {
            if location != -1 {
                self.flipPages?.insert(flip, atIndex: location)
            }
            else {
                self.flipPages?.append(flip)
            }
        }
    }
    
    func removeFlip(atLocation location: Int = -1) {
        if let pages = self.flipPages {
            if location != -1 {
                self.flipPages?.removeAtIndex(location)
            }
            else if self.flipPages?.count > 0 {
                self.flipPages?.removeLast()
            }
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
}
