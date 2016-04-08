//
//  ToolSliderAction.swift
//  flips
//
//  Created by Noah Labhart on 8/14/15.
//
//

import UIKit

class ToolSliderAction: UIView {

    private var actionButton : UIButton?
    private var actionImage : UIImage?
    
    var delegate : ToolSliderActionDelegate?
    
    init() {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        self.makeConstraints()
    }
    
    init(actionImage: UIImage) {
        super.init(frame: CGRectZero)
        
        self.actionImage = actionImage
        
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addSubviews() {
        self.actionButton = UIButton(type: .System) as? UIButton
        self.actionButton!.setTitle("testing", forState: .Normal)
        self.actionButton!.imageView!.image = self.actionImage!
        self.actionButton!.addTarget(self, action: #selector(ToolSliderAction.didTapToolSliderActionButton), forControlEvents: .TouchUpInside)
        self.addSubview(self.actionButton!)
    }
    
    func makeConstraints() {
        self.actionButton!.mas_makeConstraints({ (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.height.equalTo()(50)
            make.width.equalTo()(50)
        })
    }
    
    func didTapToolSliderActionButton() {
        self.delegate!.didTapToolSliderActionButton(self)
    }
    
}

protocol ToolSliderActionDelegate {
    
    func didTapToolSliderActionButton(sender: ToolSliderAction);
}
