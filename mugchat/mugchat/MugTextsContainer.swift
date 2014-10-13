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

class MugTextsContainer : UIScrollView {
    
    var mugTexts: [MugText]?
    
    private var texts : [String]! //Mugs?
    
    
    // MARK: - Initialization Methods
    
    convenience init(texts : [String]) {
        self.init(frame: CGRect.zeroRect) //TODO
        
        self.texts = texts
        
        self.scrollEnabled = true;
        self.pagingEnabled = true;
        //self.contentSize = CGSizeMake(320, 50); //CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
        //self.contentSize = CGSize(width:320, height: 50)
        //self.contentOffset = CGPoint(x: 10, y: 20)

        self.initSubviews()
        
        self.updateConstraintsIfNeeded()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        for text in self.texts {
            var mugText = MugText(mugText: text, status: "default")
            self.addSubview(mugText)
            mugText.mas_makeConstraints { (make) -> Void in
                make.height.equalTo()(40)
                make.width.equalTo()(40)
            }
        }
    }
    
}
