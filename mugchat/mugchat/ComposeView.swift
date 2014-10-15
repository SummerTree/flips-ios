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
    
    private let MUG_IMAGE_WIDTH: CGFloat = 240.0
    private let MUGWORD_MARGIN_BOTTOM: CGFloat = 40.0
    private let MUGWORD_LIST_HEIGHT: CGFloat = 50.0
    private let GRID_BUTTON_MARGIN_LEFT: CGFloat = 37.5
    private let GALLERY_BUTTON_MARGIN_RIGHT: CGFloat = 37.5
    private let MY_MUGS_LABEL_MARGIN_TOP: CGFloat = 5.0
    private let MY_MUGS_LABEL_MARGIN_LEFT: CGFloat = 10.0
    private let ADD_MUG_BUTTON_MARGIN_TOP: CGFloat = 5.0
    
    var delegate: ComposeViewDelegate?
    
    private var mugContainerView: UIView!
    private var mugImageView: UIImageView!
    private var mugWordLabel: UILabel!
    private var mugWordListView: UIView!
    
    private var mugsOrCameraView: UIView!
    
    private var cameraView: UIView!
    private var takePictureButton: UIButton!
    private var gridButton: UIButton!
    private var galleryButton: UIButton!
    
    private var mugsView: UIView!
    private var myMugsLabel: UILabel!
    private var addMugButton: UIButton!
    
    func viewDidLoad() {
        makeConstraints()
        self.layoutIfNeeded()
    }
    
    override init() {
        super.init()
        addSubviews()
        
        // just for debugging, since we don't have integration between the views
        addMugWords(["I", "love", "Mugchat"])
    }

    convenience init(words: [String]) {
        self.init()
        addMugWords(words)
    }
    
    private func addMugWords(words: [String]) {
        // this whole code will be replaced by Ghisi's view
        // do not waste your time reviewing it
        var button: UIButton!
        var lastButton: UIButton!
        for word in words {
            button = UIButton()
            button.addTarget(self, action: "wordTapped:", forControlEvents: .TouchUpInside)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.avacado().CGColor
            button.layer.cornerRadius = 14.0
            button.setTitle(word, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
            mugWordListView.addSubview(button)
            
            if (lastButton == nil) {
                button.mas_makeConstraints { (make) -> Void in
                    make.centerX.equalTo()(self.mugWordListView)
                    make.centerY.equalTo()(self.mugWordListView)
                    make.height.equalTo()(30)
                }
                
            } else {
                button.mas_makeConstraints { (make) -> Void in
                    make.left.equalTo()(lastButton.mas_right).with().offset()(12)
                    make.centerY.equalTo()(self.mugWordListView)
                    make.height.equalTo()(lastButton)
                }
            }
            
            lastButton = button
        }
    }
    
    private func addSubviews() {
        mugContainerView = UIView()
        self.addSubview(mugContainerView)
        
        mugImageView = UIImageView.imageWithColor(UIColor.avacado())
//        mugImageView = UIImageView(image: UIImage(named: "Church"))
        mugImageView.contentMode = UIViewContentMode.ScaleAspectFit
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
        mugsView = UIView()
        mugsOrCameraView.addSubview(mugsView)
        
        myMugsLabel = UILabel()
        myMugsLabel.numberOfLines = 1
        myMugsLabel.sizeToFit()
        myMugsLabel.text = NSLocalizedString("My Mugs", comment: "My Mugs")
        myMugsLabel.font = UIFont.avenirNextDemiBold(UIFont.HeadingSize.h3)
        myMugsLabel.textColor = UIColor.plum()
        mugsView.addSubview(myMugsLabel)
        
        addMugButton = UIButton()
        addMugButton.addTarget(self, action: "addMugButtonTapped:", forControlEvents: .TouchUpInside)
        addMugButton.setImage(UIImage(named: "AddMediaButton"), forState: .Normal)
        addMugButton.sizeToFit()
        mugsView.addSubview(addMugButton)
    }
    
    private func makeConstraints() {
        mugContainerView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self.mugImageView)
        }
        
        // asking help to delegate to align the container with navigation bar
        self.delegate?.composeViewMakeConstraintToNavigationBarBottom(mugContainerView)
        
        mugImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugContainerView)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.centerX.equalTo()(self.mugContainerView)
                make.width.equalTo()(self.MUG_IMAGE_WIDTH)
            } else {
                make.left.equalTo()(self.mugContainerView)
                make.right.equalTo()(self.mugContainerView)
            }
            
            make.height.equalTo()(self.mugImageView.mas_width)
        }
        
        mugWordLabel.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.mugContainerView)
            make.bottom.equalTo()(self.mugContainerView).with().offset()(-self.MUGWORD_MARGIN_BOTTOM)
        }
        
        mugWordListView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugContainerView.mas_bottom)
            make.height.equalTo()(self.MUGWORD_LIST_HEIGHT)
        }
        
        mugsOrCameraView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.top.equalTo()(self.mugWordListView.mas_bottom)
            make.bottom.equalTo()(self)
        }
        
        makeCameraViewConstraints()
        makeMugsViewConstraints()
    }
    
    private func makeCameraViewConstraints() {
        cameraView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.mugsView.mas_right)
            make.width.equalTo()(self.mugsOrCameraView)
            make.top.equalTo()(self.mugsOrCameraView)
            make.height.equalTo()(self.mugsOrCameraView)
        }
        
        gridButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.cameraView).with().offset()(self.GRID_BUTTON_MARGIN_LEFT)
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
            make.right.equalTo()(self.cameraView).with().offset()(-self.GALLERY_BUTTON_MARGIN_RIGHT)
            make.centerY.equalTo()(self.cameraView)
            
            // intentional use of grid button width/height
            make.width.equalTo()(self.gridButton.frame.width)
            make.height.equalTo()(self.gridButton.frame.height)
        }
    }
    
    private func makeMugsViewConstraints() {
        mugsView.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.mugsOrCameraView)
            make.right.equalTo()(self.mugsOrCameraView)
            make.top.equalTo()(self.mugsOrCameraView)
            make.height.equalTo()(self.mugsOrCameraView)
        }
        
        myMugsLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.mugsView).with().offset()(self.MY_MUGS_LABEL_MARGIN_TOP)
            make.left.equalTo()(self.mugsView).with().offset()(self.MY_MUGS_LABEL_MARGIN_LEFT)
        }
        
        addMugButton.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self.myMugsLabel)
            make.top.equalTo()(self.myMugsLabel.mas_bottom).with().offset()(self.ADD_MUG_BUTTON_MARGIN_TOP)
            
            if (DeviceHelper.sharedInstance.isDeviceModelLessOrEqualThaniPhone4S()) {
                make.width.equalTo()(self.addMugButton.frame.width / 3 * 2)
                make.height.equalTo()(self.addMugButton.mas_width)
            } else {
                make.width.equalTo()(self.addMugButton.frame.width)
                make.height.equalTo()(self.addMugButton.frame.height)
            }
        }
    }
    
    
    // MARK: - Nav Bar Delegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.delegate?.composeViewDidTapBackButton(self)
    }
    
    
    // MARK: - Button actions
    
    func addMugButtonTapped(sender: UIButton!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.mugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.width.equalTo()(self.mugsOrCameraView)
                make.right.equalTo()(self.cameraView.mas_left)
                make.top.equalTo()(self.mugsOrCameraView)
                make.height.equalTo()(self.mugsOrCameraView)
            })
            
            self.cameraView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsOrCameraView)
                make.right.equalTo()(self.mugsOrCameraView)
                make.top.equalTo()(self.mugsOrCameraView)
                make.height.equalTo()(self.mugsOrCameraView)
            })
            
            self.layoutIfNeeded()
        })
    }
    
    func takePictureButtonTapped(sender: UIButton!) {
        self.delegate?.composeViewDidTapTakePictureButton(self)
    }
    
    func gridButtonTapped(sender: UIButton!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.mugsView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsOrCameraView)
                make.right.equalTo()(self.mugsOrCameraView)
                make.top.equalTo()(self.mugsOrCameraView)
                make.height.equalTo()(self.mugsOrCameraView)
            })
            
            self.cameraView.mas_updateConstraints({ (make) -> Void in
                make.removeExisting = true
                make.left.equalTo()(self.mugsView.mas_right)
                make.width.equalTo()(self.mugsOrCameraView)
                make.top.equalTo()(self.mugsOrCameraView)
                make.height.equalTo()(self.mugsOrCameraView)
            })
            
            self.layoutIfNeeded()
        })
    }
    
    func galleryButtonTapped(sender: UIButton!) {
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
    func composeViewDidTapGalleryButton(composeView: ComposeView!)
    func composeViewMakeConstraintToNavigationBarBottom(containerView: UIView!)
}