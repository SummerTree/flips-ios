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

class TutorialView: UIView, CustomNavigationBarDelegate {
    
    weak var delegate: TutorialViewDelegate?
    
    private var navigationBar: CustomNavigationBar!
    private var imageView: UIImageView!
    
    override init() {
        super.init()
        
        self.addSubviews()
    }
    
    func viewDidLoad() {
        self.makeConstraints()
    }
    
    func viewWillAppear() {
    }
    
    func addSubviews() {
        self.backgroundColor = UIColor.flipOrange()
        
        navigationBar = CustomNavigationBar.CustomSmallNavigationBar("", showBackButton: true)
        navigationBar.delegate = self
        self.addSubview(navigationBar)
        
        imageView = UIImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = UIImage(named: "Slide1")
        self.addSubview(imageView)
    }
    
    func makeConstraints() {
        navigationBar.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.leading.equalTo()(self)
            make.height.equalTo()(self.navigationBar.frame.size.height)
        }
        
        imageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.navigationBar.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.bottom.equalTo()(self)
        }
    }
    
    
    // MARK: - Custom Nav Delegate
    
    func customNavigationBarDidTapLeftButton(navBar: CustomNavigationBar) {
        self.delegate?.tutorialViewDidTapBackButton(self)
    }
    
    
    // MARK: - Required inits
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

protocol TutorialViewDelegate: class {
    func tutorialViewDidTapBackButton(tutorialView: TutorialView!)
}