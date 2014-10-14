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


// UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
// http://stackoverflow.com/questions/26233999/uiscrollview-and-its-children-why-are-they-placed-on-top-of-each-other-autol

private let MIN_BUTTON_WIDTH : CGFloat = 70.0

class MugTextsContainer : UIView { //UIScrollView
    
    var mugTexts: [MugText]! = [MugText]()
    
    private var texts : [String]! //TODO: use object Mug instead of string
    
    
    // MARK: - Initialization Methods
    
    convenience init(texts : [String]) {
        self.init(frame: CGRect.zeroRect)
        
        self.texts = texts
        
        self.backgroundColor = UIColor.whiteColor()

        self.initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        var leadingValue : CGFloat = 5.0
        var lastMugText: MugText!
        
        for text in self.texts {

            var mugText : MugText = MugText(mugText: text, status: "default")
            mugTexts.append(mugText)
            
            self.addSubview(mugText)
            
            var textWidth : CGFloat = mugText.getTextWidth()
            var buttonWidth : CGFloat = textWidth + 20;

            mugText.mas_makeConstraints { (make) -> Void in
                make.height.equalTo()(36)
                make.centerY.equalTo()(self.mas_centerY)
                make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(12)
                make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
            }

            lastMugText = mugText;
        }
    }
    
}
