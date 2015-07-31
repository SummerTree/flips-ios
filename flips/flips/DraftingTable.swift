//
//  DraftingTable.swift
//  flips
//
//  Created by Noah Labhart on 7/24/15.
//
//

import Foundation

public class DraftingTable : NSObject {
    
    var contacts : [Contact]?
    var sendOptions: [FlipsSendButtonOption]?
    var room : Room?
    var flipID : String?
    
    private var flipBook : FlipBook?
    private var myFlipsDictionary: Dictionary<String, [String]>!
    private var stockFlipsDictionary: Dictionary<String, [String]>!
    
    override init() {
        super.init()
        self.flipBook = FlipBook()
    }
    
    init(pages: [FlipPage]?) {
        super.init()
        if let pgs = pages {
            self.flipBook = FlipBook(pages: pgs)
        }
    }
    
    public class var sharedInstance : DraftingTable {
        struct Static {
            static let instance : DraftingTable = DraftingTable()
        }
        return Static.instance
    }
    
    //MARK: - Drafting Table setup methods

    func loadFlipsForWords() {
        if let flipBook = self.flipBook {
            let flipDataSource = FlipDataSource()
            
            var words = Array<String>()
            if let flipPages = flipBook.flipPages {
                for flipPage in flipPages {
                    words.append(flipPage.word)
                }
            }

            self.myFlipsDictionary = flipDataSource.getMyFlipsIdsForWords(words)
            self.stockFlipsDictionary = flipDataSource.getStockFlipsIdsForWords(words)
        }
    }
    
    func setFlipBookPagesState() {
        if let flipBook = self.flipBook {
            if let pages = flipBook.flipPages {
                for flipPage in pages {
                    let word = flipPage.word
                    let myFlipsForWord = myFlipsDictionary[word]
                    let stockFlipsForWord = stockFlipsDictionary[word]
                    
                    let numberOfFlipsForWord = myFlipsForWord!.count + stockFlipsForWord!.count
                    
                    if (flipPage.pageID == nil) {
                        if (numberOfFlipsForWord == 0) {
                            flipPage.state = .NotAssociatedAndNoResourcesAvailable
                        } else {
                            flipPage.state = .NotAssociatedButResourcesAvailable
                        }
                    } else {
                        if (numberOfFlipsForWord == 1) {
                            flipPage.state = .AssociatedAndNoResourcesAvailable
                        } else {
                            flipPage.state = .AssociatedAndResourcesAvailable
                        }
                    }
                }
            }
        }
    }
    
    internal func updateFlipWordsState() {
        
    }

    
    //MARK: - Drafting Table mgmt
    
    func addFlipToFlipBook(flip: FlipPage) {
        self.flipBook?.addFlip(flip)
    }
    
    func removeFlipFromFlipbook(index: Int) {
        self.flipBook?.removeFlip(atLocation: index)
    }
    
    //MARK: - Send Flip Message
    
    func sendFlipMessage() {
        
    }
    
    private func uploadFlipWord(flip: FlipPage, success: CreateFlipSuccessCompletion, failure: CreateFlipFailureCompletion) {
        
    }
    
    private func associateFlipsWords() {
        
    }
    
    //MARK: - Maintenance Methods
    
    func resetDraftingTable() {
        
        if let contacts = self.contacts {
            self.contacts?.removeAll(keepCapacity: false)
        }
        
        if let sendOptions = self.sendOptions {
            self.sendOptions?.removeAll(keepCapacity: false)
        }
        
        self.flipBook = nil
        self.room = nil
    }
    
    func dumpTableToConsole() {
        if let flipBook : FlipBook = self.flipBook {
            println("------ Dumping the Drafting Table --------")
            for flipPage : FlipPage in flipBook.flipPages! {
                println("\(flipPage.order). \(flipPage.word)")
                println("--> video: \(flipPage.videoURL?.absoluteString)")
                println("--> thumb: \(flipPage.thumbnailURL?.absoluteString)")
                println("--> id:    \(flipPage.pageID)")
                println("--> assoc: \(self.myFlipsDictionary[flipPage.word]!.count)")
            }
        }
    }
    
}
