//
//  StockFlipsListView.swift
//  flips
//
//  Created by Noah Labhart on 1/19/16.
//
//

import UIKit

class StockFlipsListView: FlipsWebView {
    
    let STOCK_FLIPS_URL = "http://www.pictureyourwords.com"
    
    init() {
        super.init(URL: STOCK_FLIPS_URL)
        self.webView.scalesPageToFit = true
    }
    
    
    // MARK: Required methods
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

