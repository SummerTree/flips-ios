//
//  RoundImageView.swift
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

let A1_BORDER_WIDTH : CGFloat = 3
// Sets avatar capture width to be 90% of camera view's width
let A1_AVATAR_SIZE = DeviceHelper.DeviceScreenSize.screenRect.width * 0.9 + A1_BORDER_WIDTH
let A2_BORDER_WIDTH : CGFloat = 3
let A2_AVATAR_SIZE = 90 + A2_BORDER_WIDTH
let A3_BORDER_WIDTH : CGFloat = 2
let A3_AVATAR_SIZE = 50 + A3_BORDER_WIDTH
let A4_BORDER_WIDTH : CGFloat = 2
let A4_AVATAR_SIZE = 40 + A4_BORDER_WIDTH


class RoundImageView: UIView {
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
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set(image) {
            let imageWidth = CGRectGetWidth(imageView.frame)
            let imageHeight = CGRectGetHeight(imageView.frame)
            
            if ((image?.size.width > imageWidth) || (image?.size.height >  imageHeight)) {
                var resizedImage = image?.resizedImageWithWidth(imageWidth, andHeight: imageHeight)
                imageView.image = resizedImage
            } else {
                imageView.image = image
            }
        }
    }
    
    var imageView: UIImageView!

    // MARK: - Public class methods
    
    class func avatarA1() -> RoundImageView {
        return RoundImageView(frame: CGRectMake(0, 0, A1_AVATAR_SIZE, A1_AVATAR_SIZE), borderWidth: A1_BORDER_WIDTH)
    }
    
    class func avatarA2() -> RoundImageView {
        return RoundImageView(frame: CGRectMake(0, 0, A2_AVATAR_SIZE, A2_AVATAR_SIZE), borderWidth: A2_BORDER_WIDTH)
    }
    
    class func avatarA3() -> RoundImageView {
        return RoundImageView(frame: CGRectMake(0, 0, A3_AVATAR_SIZE, A3_AVATAR_SIZE), borderWidth: A3_BORDER_WIDTH)
    }

    class func avatarA4() -> RoundImageView {
        return RoundImageView(frame: CGRectMake(0, 0, A4_AVATAR_SIZE, A4_AVATAR_SIZE), borderWidth: A4_BORDER_WIDTH)
    }

    // MARK: - Public instance methods
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, borderWidth: CGFloat! = nil, borderColor: UIColor! = nil) {
        super.init(frame: frame)
        setup()
        
        if (borderWidth != nil) {
            self.borderWidth = borderWidth
        }
        
        if (borderColor != nil) {
            self.borderColor = borderColor
        } else {
            self.borderColor = .whiteColor()
        }
    }
    
    func reset() {
        self.imageView.cancelImageRequestOperation()
        self.imageView.image = nil
    }
    
    func setImageWithURL(url: NSURL!, success: ((request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage) -> Void)? = nil) {
        if url != nil {
            let urlRequest = NSURLRequest(URL: url)
            self.imageView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: { (request, response, image) -> Void in
                self.imageView.image = image
                success?(request: request, response: response, image: image)
                }, nil)
        } else {
            self.imageView.cancelImageRequestOperation()
        }
    }

    // MARK: - Private instance methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = CGRectGetWidth(frame) / 2
        layer.cornerRadius = radius
        imageView.layer.cornerRadius = radius
    }
    
    func setup() {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.shouldRasterize = true
        self.imageView = UIImageView()
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.shouldRasterize = true
        
        self.addSubview(self.imageView)

        let padding = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0)
        
        self.imageView.mas_makeConstraints { (make) -> Void in
            make.edges.equalTo()(self).with().setInsets(padding)
        }
        
        self.layoutIfNeeded()
    }
}
