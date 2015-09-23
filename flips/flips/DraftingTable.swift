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
    
    var flipBook : FlipBook
    
    private var myFlipsDictionary: Dictionary<String, [String]>!
    private var stockFlipsDictionary: Dictionary<String, [String]>!
    
    override private init() {
        self.flipBook = FlipBook()
        super.init()
    }
    
    private init(pages: [FlipPage]) {
        self.flipBook = FlipBook(pages: pages)
        super.init()
    }
    
    public class var sharedInstance : DraftingTable {
        struct Static {
            static let instance : DraftingTable = DraftingTable()
        }
        return Static.instance
    }
    
    //MARK: - Drafting Table setup methods

    func loadFlipsForWords() {
        let flipDataSource = FlipDataSource()
        
        var words = Array<String>()
        for flipPage in self.flipBook.flipPages {
            words.append(flipPage.word)
        }

        self.myFlipsDictionary = flipDataSource.getMyFlipsIdsForWords(words)
        self.stockFlipsDictionary = flipDataSource.getStockFlipsIdsForWords(words)
    }
    
    func setFlipBookPagesState() {

        for flipPage in self.flipBook.flipPages {
            let word = flipPage.word
            let myFlipsForWord = myFlipsDictionary[word]
            let stockFlipsForWord = stockFlipsDictionary[word]
            
            let numberOfLocalFlips = (flipPage.videoURL != nil ? 1 : 0)
            let numberOfFlipsForWord = myFlipsForWord!.count + stockFlipsForWord!.count + numberOfLocalFlips
            
            if (flipPage.pageID == nil && flipPage.videoURL == nil) {
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
    
    func mapWordsToFirstAvailableFlip() {
        for flipPage in self.flipBook.flipPages {
            if let firstFlipId : String = self.myFlipsDictionary[flipPage.word]?.first {
                flipPage.pageID = firstFlipId
            }
        }
    }
    
    private let NO_FLIP_SELECTED_INDEX = -1
    
    func nextEmptyFlipPage() -> Int {

        for flipPage in self.flipBook.flipPages {
            if (flipPage.pageID == nil && flipPage.videoURL == nil) {
                return flipPage.order
            }
        }
        return NO_FLIP_SELECTED_INDEX
    }
    
    //MARK: - Drafting Table mgmt
    
    func addFlipToFlipBook(flip: FlipPage) {
        self.flipBook.addFlip(flip)
    }
    
    func updateFlipInFlipBook(flip: FlipPage) {
        self.flipBook.replaceFlip(flip)
    }
    
    func removeFlipFromFlipbook(index: Int) {
        self.flipBook.removeFlip(atLocation: index)
    }
    
    func flipPageAtIndex(index: Int) -> FlipPage {
        return self.flipBook.flipPages[index]
    }
    
    //MARK: - Send Flip Message
    
    func sendFlipMessage() {
        
    }
    
    func uploadFlipPage(flipPage: FlipPage?) {
        if let page = flipPage {
            
        }
    }
    
    func uploadFlipBook(flipBook: FlipBook?) {
        if let book = flipBook {
            
        }
    }
    
    //MARK: - Maintenance Methods
    
    func resetDraftingTable() {
        
        if let contacts = self.contacts {
            self.contacts?.removeAll(keepCapacity: false)
        }
        
        if let sendOptions = self.sendOptions {
            self.sendOptions?.removeAll(keepCapacity: false)
        }
        
        if let room = self.room {
            self.room = nil;
        }
        
        self.flipBook = FlipBook()
    }
    
    func dumpTableToConsole() {
        print("------ Dumping the Drafting Table --------")
        
        for flipPage : FlipPage in self.flipBook.flipPages {
            print("\(flipPage.order). \(flipPage.word)")
            
            if let myFlipID = flipPage.pageID {
                print("--> id:\t\(flipPage.pageID!)")
            }
            
                print("--> state:\t\(flipPage.state.rawValue)")
            
            if let thumbURL = flipPage.thumbnailURL {
                print("--> thumb:\t\(flipPage.thumbnailURL!.absoluteString.lastPathComponent)")
            }
            
            if let vidURL = flipPage.videoURL {
                print("--> video:\t\(flipPage.videoURL!.absoluteString.lastPathComponent)")
            }
            
            if let myFlips = self.myFlipsDictionary {
                print("--> assoc:\t\(myFlips[flipPage.word]!.count)")
            }
            
            if let stockFlips = self.stockFlipsDictionary {
                print("--> stock:\t\(stockFlips[flipPage.word]!.count)")
            }
        }
    }
    
}
