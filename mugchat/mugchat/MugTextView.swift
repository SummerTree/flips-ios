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

private let LABEL_MARGIN_TOP : CGFloat = 7.0
private let EXTRAS_IMAGE_SIZE : CGFloat = 20.0

class MugTextView : UIView {
    
    var mugText : MugText!
    var textLabel: UILabel!
    
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
        self.backgroundColor = UIColor.clearColor()
        
        textLabel = UILabel()
        textLabel.layer.borderWidth = 1.0
        textLabel.layer.borderColor = UIColor.avacado().CGColor
        textLabel.layer.cornerRadius = 14.0
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.text = self.mugText.text
        textLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        textLabel.textColor = UIColor.blackColor()
        textLabel.sizeToFit()
        self.addSubview(textLabel)
        
        var status : MugState = self.mugText.state
        switch status {
        case MugState.Default:
            textLabel.textColor = UIColor.blackColor()
            textLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
        case MugState.AssociatedImageOrVideo:
            textLabel.textColor = UIColor.blackColor()
            textLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
            addExtrasImage()
        case MugState.AssociatedWord:
            textLabel.textColor = UIColor.whiteColor()
            textLabel.layer.backgroundColor = UIColor.avacado().CGColor
        case MugState.AssociatedImageOrVideoWithAdditionalResources:
            textLabel.textColor = UIColor.whiteColor()
            textLabel.layer.backgroundColor = UIColor.avacado().CGColor
            addExtrasImage()
        }
        
        initConstraints()
    }
    
   private func addExtrasImage() {
        hasExtrasImageView = UIImageView()
        hasExtrasImage = UIImage(named: "mug_options")
        hasExtrasImageView.image = hasExtrasImage
        self.addSubview(self.hasExtrasImageView)
    }
    
    private func initConstraints() {
        textLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(LABEL_MARGIN_TOP)
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