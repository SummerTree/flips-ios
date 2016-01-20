//
//  StockFlipsListViewController.swift
//  flips
//
//  Created by Noah Labhart on 1/19/16.
//
//

import UIKit

class StockFlipsListViewController: FlipsChatWebViewController {
    
    init() {
        super.init(view: StockFlipsListView(), title: "Stock Flips")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
