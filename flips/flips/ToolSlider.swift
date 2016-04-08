//
//  ToolSlider.swift
//  flips
//
//  Created by Noah Labhart on 8/14/15.
//
//

import UIKit

class ToolSlider: UIView, ToolSliderActionDelegate {

    private var slider              : UIScrollView?
    private var sliderContentView   : UIView?
    private var sliderCollection    : ToolSliderCollection?
    private var sapVideoAction      : ToolSliderAction?
    private var sapImageAction      : ToolSliderAction?
    private var sapLibraryAction    : ToolSliderAction?
    private var panelHeight         : CGFloat = 0
    
    private var delegate : ToolSliderDelegate?
    
    init() {
        super.init(frame: CGRectZero)
        
        self.addSubviews()
        self.makeConstraints()
        
        self.backgroundColor = UIColor.avacado()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Setup Methods
    
    func addSubviews() {
        
        if (self.slider) != nil {
            self.panelHeight = self.slider!.frame.height
        }

        self.slider = UIScrollView()
        self.slider!.backgroundColor = UIColor.clearColor()
        self.slider!.userInteractionEnabled = true
        self.slider!.pagingEnabled = true
        self.slider!.scrollEnabled = true
        self.addSubview(self.slider!)
        
        self.sliderContentView = UIView()
        self.sliderContentView!.backgroundColor = UIColor.clearColor()
        self.slider!.addSubview(self.sliderContentView!)
        
//        self.sliderCollection = ToolSliderCollection()
//        self.slider!.addSubview(self.sliderCollection!)
        
        self.sapVideoAction = ToolSliderAction(actionImage: UIImage(named: "Capture")!)
        self.sapVideoAction!.backgroundColor = UIColor.brownColor()
        self.sliderContentView!.addSubview(self.sapVideoAction!)
        
        self.sapImageAction = ToolSliderAction(actionImage: UIImage(named: "Capture")!)
        self.sapImageAction!.backgroundColor = UIColor.redColor()
        self.sliderContentView!.addSubview(self.sapImageAction!)
        
        self.sapLibraryAction = ToolSliderAction(actionImage: UIImage(named: "Capture")!)
        self.sapLibraryAction!.backgroundColor = UIColor.yellowColor()
        self.sapLibraryAction!.alpha = 0.5
        self.sliderContentView!.addSubview(self.sapLibraryAction!)
        
    }
    
    func makeConstraints() {
        
        self.slider!.mas_makeConstraints { (make) -> Void in
            make.edges.equalTo()(self)
        }
        
        self.sliderContentView!.mas_makeConstraints { (make) -> Void in
            make.edges.equalTo()(self.slider!)
            make.width.equalTo()(self)
        }
        
        self.sapVideoAction!.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(0)
            make.left.equalTo()(0)
            make.width.equalTo()(self)
            make.height.equalTo()(self.panelHeight)
        }
        
        self.sapImageAction!.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.sapVideoAction!.mas_bottom)
            make.left.equalTo()(0)
            make.width.equalTo()(self)
            make.height.equalTo()(self.panelHeight)
        }
        
        self.sapLibraryAction!.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.sapImageAction!.mas_bottom)
            make.left.equalTo()(0)
            make.width.equalTo()(self)
            make.height.equalTo()(self.panelHeight)
        }
        
        self.sliderContentView!.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self.sapLibraryAction!.mas_bottom)
        }
    }
    
    // MARK: - Tool Slider Action Delegate
    
    func didTapToolSliderActionButton(sender: ToolSliderAction) {
        if sender == self.sapImageAction! {
            
        }
        else if sender == self.sapLibraryAction! {
            
        }
        else if sender == self.sapVideoAction! {
            
        }
    }
}

protocol ToolSliderDelegate {
    
    func didStartRecordingVideo()
    func didStartCapturingImage()
    func didFinishRecordingVideo()
    func didFinishCapturingImage()
    func didChooseCameraRoll()
}
