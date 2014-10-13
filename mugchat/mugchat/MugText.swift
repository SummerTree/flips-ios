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
    
    private var mugText : String?
    private var status : String? //TODO: create enum
    
    var mugTextField: UITextField?
    var innerView: UIView? //with rounded corners
    var extrasView: UIView? // "(...)"
    
    
    // MARK: - Initialization Methods
    
    convenience init(mugText : String, status : String) {
        self.init(frame: CGRect.zeroRect) //TODO
        
        self.mugText = mugText
        self.status = status
        
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
        self.mugTextField = UITextField()
        self.mugTextField?.text = self.mugText
        
        self.backgroundColor = UIColor.yellowColor()
        
        mugTextField?.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
        }
    }
    
}