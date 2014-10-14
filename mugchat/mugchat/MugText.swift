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

class MugText : UIView {
    
    private var mugText : String!
    private var status : String? //TODO: create enum
    
    var mugButton: UIButton!
    
    var hasExtrasImageView: UIImageView! // "(...)"
    var hasExtrasImage : UIImage!
    
    
    // MARK: - Initialization Methods
    
    convenience init(mugText : String, status : String) {
        self.init(frame: CGRect.zeroRect)
        
        self.mugText = mugText
        self.status = status
        
        self.initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        mugButton = UIButton()
        //mugButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
        //mugButton.addTarget(self, action: "mugButtonTapped:", forControlEvents: .TouchUpInside)
        mugButton.layer.borderWidth = 1.0
        mugButton.layer.borderColor = UIColor.avacado().CGColor
        mugButton.layer.cornerRadius = 14.0
        mugButton.setTitle(self.mugText, forState: UIControlState.Normal)
        mugButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        mugButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        self.addSubview(mugButton)
        
        //if status == ...
        hasExtrasImageView = UIImageView()
        hasExtrasImage = UIImage(named: "mug_options")
        hasExtrasImageView.image = hasExtrasImage
        self.addSubview(self.hasExtrasImageView)
        
        mugButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        mugButton.backgroundColor = UIColor.avacado()
        
        initConstraints()
    }
    
    private func initConstraints() {
        mugButton.mas_makeConstraints { (make) -> Void in
            //make.width.equalTo()(self.badgeView.frame.size.width)
            make.top.equalTo()(7)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        
        hasExtrasImageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.trailing.equalTo()(self)
            make.width.equalTo()(20)
            make.height.equalTo()(20)
        }
    }
    
    func getTextWidth() -> CGFloat{
        let myString: NSString = mugText as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }
    
}