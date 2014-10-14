//
// Copyright 2014 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import UIKit

class ComposeView : UIView, CustomNavigationBarDelegate {
    
    var delegate: ComposeViewDelegate?
    
    private var mugContainerView: UIView!
    private var mugImageView: UIImageView!
    private var mugWordLabel: UILabel!
    private var mugWordListView: UIView!
    private var mugsOrCameraView: UIView!
    private var cameraView: UIView!
    private var mugsView: UIView!
    private var takePictureButton: UIButton!
    private var gridButton: UIButton!
    private var galleryButton: UIButton!
    
    override init() {
        super.init()
        addSubviews()
        addMugWords(["I", "love", "Mugchat"])
    }

    convenience init(words: [String]) {
        self.init()
        addMugWords(words)
    }
    
    private func addSubviews() {
        mugContainerView = UIView()
        self.addSubview(mugContainerView)
        
        mugImageView = UIImageView.imageWithColor(UIColor.avacado())
        mugImageView.contentMode = UIViewContentMode.ScaleToFill
        mugImageView.sizeToFit()
        mugContainerView.addSubview(mugImageView)
        
        mugWordLabel = UILabel()
        mugWordLabel.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        mugWordLabel.textColor = UIColor.whiteColor()
        mugWordLabel.text = "I"
        mugContainerView.addSubview(mugWordLabel)
        
        mugWordListView = UIView()
        self.addSubview(mugWordListView)
        
        mugsOrCameraView = UIView()
        mugsOrCameraView.backgroundColor = UIColor.lightGreyF2()
        self.addSubview(mugsOrCameraView)
        
        addCameraViewSubviews()
        addMugsViewSubviews()
    }
    
    private func addCameraViewSubviews() {
        cameraView = UIView()
        mugsOrCameraView.addSubview(cameraView)
        
        takePictureButton = UIButton()
        takePictureButton.setImage(UIImage(named: "Capture"), forState: .Normal)
        takePictureButton.sizeToFit()
        takePictureButton.addTarget(self, action: "takePictureButtonTapped:", forControlEvents: .TouchUpInside)
        cameraView.addSubview(takePictureButton)
        
        gridButton = UIButton()
        gridButton.setImage(UIImage(named: "Grid"), forState: .Normal)
        gridButton.sizeToFit()
        gridButton.addTarget(self, action: "gridButtonTapped:", forControlEvents: .TouchUpInside)
        cameraView.addSubview(gridButton)
        
        galleryButton = UIButton()
        galleryButton.setImage(UIImage(named: "Church"), forState: .Normal)
        galleryButton.addTarget(self, action: "galleryButtonTapped:", forControlEvents: .TouchUpInside)
        cameraView.addSubview(galleryButton)
    }
    
    private func addMugsViewSubviews() {
//        mugsView
    }
    
    private func addMugWords(words: [String]) {
        var button: UIButton!
        var lastButton: UIButton!
        for word in words {
            button = UIButton()
            //iButton.backgroundColor = UIColor.avacado()
            button.addTarget(self, action: "wordTapped:", forControlEvents: .TouchUpInside)
            button.setTitle(word, forState: UIControlState.Normal)
            
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.avacado().CGColor
            button.layer.cornerRadius = 14.0
            button.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
            mugWordListView.addSubview(button)
            
            if (lastButton == nil) {
                button.backgroundColor = UIColor.avacado()
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                button.mas_makeConstraints { (make) -> Void in
                    make.centerX.equalTo()(self.mugWordListView)
                    make.centerY.equalTo()(self.mugWordListView)
                    make.height.equalTo()(30)
                    make.width.greaterThanOrEqualTo()(50)
                }
                
            } else {
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                button.mas_makeConstraints { (make) -> Void in
                    make.left.equalTo()(lastButton.mas_right).with().offset()(12)
                    make.centerY.equalTo()(self.mugWordListView)
                    make.height.equalTo()(lastButton)
                    make.width.greaterThanOrEqualTo()(lastButton)
                }
            }
            
            lastButton = button
        }
    }
    
    func viewDidLoad() {
        makeConstraints()
        self.layoutIfNeeded()
    }
    
    private func makeConstraints() {
        mugContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(320)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.composeViewMakeConstraintToNavigationBarBottom(mugContainerView)
        
        mugImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            make.left.equalTo()(self.mugContainerView)
            make.right.equalTo()(self.mugContainerView)
            make.bottom.equalTo()(self.mugContainerView)
        }
        
        mugWordLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.mugContainerView)
            make.bottom.equalTo()(self.mugContainerView).with().offset()(-40)
        }
        
        mugWordListView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugContainerView.mas_bottom)
            make.height.equalTo()(50)
        }
        
        mugsOrCameraView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugWordListView.mas_bottom)
            make.height.equalTo()(134)
        }
        
        cameraView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.mugsOrCameraView)
            make.right.equalTo()(self.mugsOrCameraView)
            make.top.equalTo()(self.mugsOrCameraView)
            make.height.equalTo()(self.mugsOrCameraView)
        }

        gridButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.cameraView).with().offset()(37.5)
            make.centerY.equalTo()(self.cameraView)
            make.width.equalTo()(self.gridButton.frame.width)
            make.height.equalTo()(self.gridButton.frame.height)
        }
        
        takePictureButton.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.cameraView)
            make.centerY.equalTo()(self.cameraView)
            make.width.equalTo()(self.takePictureButton.frame.width)
            make.height.equalTo()(self.takePictureButton.frame.height)
        }
        
        galleryButton.mas_makeConstraints { (make) -> Void in
            make.right.equalTo()(self.cameraView).with().offset()(-37.5)
            make.centerY.equalTo()(self.cameraView)
            
            // intentional use of grid button width/height
            make.width.equalTo()(self.gridButton.frame.width)
            make.height.equalTo()(self.gridButton.frame.height)
        }
    }
    
    
    // MARK: - Nav Bar Delegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.delegate?.composeViewDidTapBackButton(self)
    }
    
    
    // MARK: - Button actions
    
    func takePictureButtonTapped(sender: AnyObject?) {
        self.delegate?.composeViewDidTapTakePictureButton(self)
    }
    
    func gridButtonTapped(sender: AnyObject?) {
        self.delegate?.composeViewDidTapGridButton(self)
    }
    
    func galleryButtonTapped(sender: AnyObject?) {
        self.delegate?.composeViewDidTapGalleryButton(self)
    }
    
    func wordTapped(sender: UIButton!) {
        println("tapped \(sender.titleLabel?.text)")
    }

    // MARK: - Required inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - View Delegate

protocol ComposeViewDelegate {
    func composeViewDidTapBackButton(composeView: ComposeView!)
    func composeViewDidTapTakePictureButton(composeView: ComposeView!)
    func composeViewDidTapGridButton(composeView: ComposeView!)
    func composeViewDidTapGalleryButton(composeView: ComposeView!)
    func composeViewMakeConstraintToNavigationBarBottom(containerView: UIView!)
}