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

import Foundation


class ContactPhotoView: RoundImageView {
    private let BORDER_COLOR = UIColor.lightGreyD8()
    private let BORDER_WIDTH: CGFloat = 1.0
    private let INITIAL_FONT_SIZE: CGFloat = 18.0
    
    var initialLabel: UILabel!
    
    var initials: String! {
        didSet {
            initialLabel.text = initials
            initialLabel.hidden = (initials == nil || initials.isEmpty)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
        
    override func setImageWithURL(url: NSURL!, success: ((request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage) -> Void)? = nil) {
        super.setImageWithURL(url) { (request, response, image) -> Void in
            self.initialLabel.hidden = true
            success?(request: request, response: response, image: image)
        }
    }
    
    override func reset() {
        super.reset()
        self.initials = nil
    }
    
    // MARK: - Private methods
    
    override func setup() {
        super.setup()
        self.borderColor = BORDER_COLOR
        self.borderWidth = BORDER_WIDTH
        
        self.initialLabel = UILabel()
        self.initialLabel.backgroundColor = .lightGreyF2()
        self.initialLabel.font = UIFont.avenirNextRegular(INITIAL_FONT_SIZE)
        self.initialLabel.textAlignment = .Center
        self.initialLabel.hidden = true
        
        self.addSubview(self.initialLabel)
        
        self.initialLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.height.equalTo()(self)
            make.width.equalTo()(self)
        }
    }
}