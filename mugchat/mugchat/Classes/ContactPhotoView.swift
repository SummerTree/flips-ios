//
//  ContactPhotoView.swift
//  mugchat
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


class ContactPhotoView: UIView {
    private let BORDER_COLOR = UIColor.whiteColor()
    private let BORDER_WIDTH: CGFloat = 1.0
    private let INITIAL_FONT_SIZE: CGFloat = 18.0
    
    var borderColor: UIColor {
        get {
            return UIColor(CGColor: self.layer.borderColor)
        }
        set {
            self.layer.borderColor = newValue.CGColor
        }
    }
    
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    var imageView: UIImageView!
    
    var initialLabel: UILabel!
    
    var initials: String! {
        didSet {
            initialLabel.text = initials
            initialLabel.hidden = (initials == nil || initials.isEmpty)
        }
    }
    
    init(frame: CGRect, borderWidth : CGFloat) {
        super.init(frame: frame)
        setup()
        
        self.borderWidth = borderWidth
        self.borderColor = .whiteColor()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setImageWithURL(url: NSURL) {
        let urlRequest = NSURLRequest(URL: url)
        self.imageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
            self.imageView.image = image
            self.initialLabel.hidden = true
            }, nil)
    }
    
    func reset() {
        self.borderColor = BORDER_COLOR
        self.imageView.cancelImageRequestOperation()
        self.imageView.image = nil
        self.initials = nil
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.borderColor = BORDER_COLOR
        self.clipsToBounds = true
        self.layer.borderWidth = BORDER_WIDTH
        
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
        
        self.imageView = UIImageView()
        
        self.addSubview(self.imageView)
        
        self.imageView.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.height.equalTo()(self)
            make.width.equalTo()(self)
        }
    }
}