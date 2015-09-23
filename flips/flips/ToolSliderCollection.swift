//
//  ToolSliderCollection.swift
//  flips
//
//  Created by Noah Labhart on 8/14/15.
//
//

import UIKit

class ToolSliderCollection: UIView {

    private var myFlips : AnyObject?
    private var stockFlips : AnyObject?
    
    init() {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        self.makeConstraints()
    }
    
    init(sliderPanels : [UIView]?) {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        self.makeConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addSubviews() {
        
    }
    
    func makeConstraints() {
        
    }
}
