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

class BuilderView : UIView, BuilderIntroductionViewDelegate {
    
    var delegate: BuilderViewDelegate?
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    private let ALREADY_SEEN_INTRODUCTION_KEY: String! = "builder.introduction"
    private var alreadySeenIntroduction: Bool!
    private var backgroundImageView: UIImageView!
    private var builderIntroductionView: BuilderIntroductionView!
    
    override init() {
        super.init()
        
        addSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func viewDidLoad() {
        makeConstraints()
    }
    
    func viewDidAppear() {
        self.alreadySeenIntroduction = userDefaults.objectForKey(ALREADY_SEEN_INTRODUCTION_KEY) as Bool?
        if (alreadySeenIntroduction == nil || !alreadySeenIntroduction!) {
            userDefaults.setObject(true, forKey: ALREADY_SEEN_INTRODUCTION_KEY)
            builderIntroductionView = BuilderIntroductionView(viewBackground: self.snapshot())
            builderIntroductionView.alpha = 0.0
            builderIntroductionView.delegate = self
            self.bringSubviewToFront(builderIntroductionView)
            self.addSubview(builderIntroductionView)
            
            self.builderIntroductionView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self)
                make.bottom.equalTo()(self)
                make.left.equalTo()(self)
                make.right.equalTo()(self)
            }
            
            self.layoutIfNeeded()
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.builderIntroductionView.alpha = 1.0
            })
        }
    }
    
    func addSubviews() {
        var backgroundImage = UIImage(named: "BuilderBackground")
        self.backgroundImageView = UIImageView(image: backgroundImage)
        self.addSubview(backgroundImageView)
    }
    
    func makeConstraints() {
        self.backgroundImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        }
    }
    
    func builderIntroductionViewDidTapOkSweetButton(builderIntroductionView: BuilderIntroductionView!) {
        self.delegate?.builderViewDidTapOkSweetButton(self)
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.builderIntroductionView.alpha = 0.0
        }) { (completed) -> Void in
            self.bringSubviewToFront(self.backgroundImageView)
        }
    }
}

protocol BuilderViewDelegate {
    func builderViewDidTapOkSweetButton(builderView: BuilderView!)
}