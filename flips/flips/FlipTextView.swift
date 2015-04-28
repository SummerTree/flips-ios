//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

let LABEL_MARGIN_TOP : CGFloat = 7.0
private let EXTRAS_IMAGE_SIZE : CGFloat = 20.0

class FlipTextView : UIView {
    
    var flipText : FlipText!
    var textLabel: UILabel!
    
    var hasExtrasImageView: UIImageView! // "(...)"
    var hasExtrasImage : UIImage!

    
    // MARK: - Initialization Methods
    
    convenience init(flipText : FlipText) {
        self.init(frame: CGRect.zeroRect)
        
        self.flipText = flipText
        
        self.initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFlipText(flipText : FlipText) {
        self.flipText = flipText
        initSubviews()
    }
    
    func initSubviews() {
        self.backgroundColor = UIColor.clearColor()
        
        textLabel = UILabel()
        textLabel.layer.borderWidth = 1.0
        textLabel.layer.borderColor = UIColor.avacado().CGColor
        textLabel.layer.cornerRadius = 14.0
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.text = self.flipText.text
        textLabel.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        textLabel.textColor = UIColor.blackColor()
        textLabel.sizeToFit()
        self.addSubview(textLabel)
        
        hasExtrasImageView = UIImageView()
        hasExtrasImageView.alpha = 0.0
        hasExtrasImage = UIImage(named: "mug_options")
        hasExtrasImageView.image = hasExtrasImage
        self.addSubview(self.hasExtrasImageView)

        initConstraints()
        updateLayout()
    }
    
    func updateLayout() {
        var status : FlipState = self.flipText.state
        switch status {
        case FlipState.NotAssociatedAndNoResourcesAvailable:
            textLabel.textColor =   UIColor.blackColor()
            textLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
            hasExtrasImageView.alpha = 0.0
        case FlipState.NotAssociatedButResourcesAvailable:
            textLabel.textColor = UIColor.blackColor()
            textLabel.layer.backgroundColor = UIColor.whiteColor().CGColor
            hasExtrasImageView.alpha = 1.0
        case FlipState.AssociatedAndNoResourcesAvailable:
            textLabel.textColor = UIColor.whiteColor()
            textLabel.layer.backgroundColor = UIColor.avacado().CGColor
            hasExtrasImageView.alpha = 0.0
        case FlipState.AssociatedAndResourcesAvailable:
            textLabel.textColor = UIColor.whiteColor()
            textLabel.layer.backgroundColor = UIColor.avacado().CGColor
            hasExtrasImageView.alpha = 1.0
        }
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
        let myString: NSString = self.flipText.text as NSString
        var font: UIFont = UIFont.avenirNextRegular(UIFont.HeadingSize.h2)
        let size: CGSize = myString.sizeWithAttributes([NSFontAttributeName: font])
        return size.width
    }
    
    
    // MARK: - Overridden Methods
    
    override func layoutSubviews() {
        self.updateLayout()
        super.layoutSubviews()
    }
}