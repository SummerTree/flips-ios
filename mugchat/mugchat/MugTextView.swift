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

private let BUTTON_MARGIN_TOP : CGFloat = 7.0
private let EXTRAS_IMAGE_SIZE : CGFloat = 20.0

class MugTextView : UICollectionViewCell {
    
    var mugText : MugText!
    
    var delegate : MugTextViewDelegate?
    
    var mugButton: UIButton!
    
    var hasExtrasImageView: UIImageView! // "(...)"
    var hasExtrasImage : UIImage!

    
    // MARK: - Initialization Methods
    
    convenience init(mugText : MugText) {
        self.init(frame: CGRect.zeroRect)
        
        self.mugText = mugText
        
        self.initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMugText(mugText : MugText) {
        self.mugText = mugText
        initSubviews()
    }
    
    func initSubviews() {
        mugButton = UIButton()
        
        mugButton.addTarget(self, action: "mugButtonTapped", forControlEvents: .TouchUpInside)
        
        mugButton.layer.borderWidth = 1.0
        mugButton.layer.borderColor = UIColor.avacado().CGColor
        mugButton.layer.cornerRadius = 14.0
        mugButton.setTitle(self.mugText.text, forState: UIControlState.Normal)
        mugButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        mugButton.titleLabel?.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        self.addSubview(mugButton)
        
        var status : MugState = self.mugText.state
        switch status {
        case MugState.Default:
            mugButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            mugButton.backgroundColor = UIColor.whiteColor()
        case MugState.AssociatedImageOrVideo:
            mugButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            mugButton.backgroundColor = UIColor.whiteColor()
            addExtrasImage()
        case MugState.AssociatedWord:
            mugButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            mugButton.backgroundColor = UIColor.avacado()
        case MugState.AssociatedImageOrVideoWithAdditionalResources:
            mugButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            mugButton.backgroundColor = UIColor.avacado()
            addExtrasImage()
        }
        
        initConstraints()
    }
    
    func mugButtonTapped() {
        //TODO: When implementing scroll, see UICollectionViewDelegate Methods of this article (http://iphonedev.tv/blog/2014/4/17/show-the-uimenucontroller-and-display-custom-edit-menus-for-uiviewcontroller-uitableviewcontroller-and-uicollectionview-on-ios-7)
        
        self.delegate?.didTapMugText(self.mugText)

    }
    
    private func addExtrasImage() {
        hasExtrasImageView = UIImageView()
        hasExtrasImage = UIImage(named: "mug_options")
        hasExtrasImageView.image = hasExtrasImage
        self.addSubview(self.hasExtrasImageView)
    }
    
    private func initConstraints() {
        mugButton.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(BUTTON_MARGIN_TOP)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
        
        if (hasExtrasImageView != nil) {
            hasExtrasImageView.mas_makeConstraints { (make) -> Void in
                make.top.equalTo()(self)
                make.trailing.equalTo()(self)
                make.width.equalTo()(EXTRAS_IMAGE_SIZE)
                make.height.equalTo()(EXTRAS_IMAGE_SIZE)
            }
        }
    }
    
    func getTextWidth() -> CGFloat{
        let myString: NSString = self.mugText.text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }
    
}


// MARK: View Delegate

protocol MugTextViewDelegate {
    
    func didTapMugText(mugText : MugText!)
    
}