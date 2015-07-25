//
//  DraftingTable.swift
//  flips
//
//  Created by Noah Labhart on 7/24/15.
//
//

import Foundation

public class DraftingTable : NSObject {
    
    var flipBook : FlipBook?
    
    public class var sharedInstance : DraftingTable {
        struct Static {
            static let instance : DraftingTable = DraftingTable()
        }
        return Static.instance
    }
   
}
