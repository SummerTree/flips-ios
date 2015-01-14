//
//  SyncView.swift
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

class SyncView: UIView {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var image: UIImage? {
        get {
            return backgroundImageView.image
        }
        set {
            backgroundImageView.image = newValue?.applyLightEffect()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.font = .avenirNextRegular(UIFont.HeadingSize.h1)
        headerLabel.textColor = .deepSea()
        
        detailLabel.font = .avenirNextRegular(UIFont.HeadingSize.h3)
        detailLabel.textColor = .deepSea()
        
        downloadLabel.font = .avenirNextRegular(UIFont.HeadingSize.h6)
        downloadLabel.textColor = .deepSea()
        
        progressView.tintColor = .deepSea()
        
        setDownloadCount(0, ofTotal: 0)
    }
    
    func setDownloadCount(count: Int, ofTotal total: Int) {
        downloadLabel.text = "Downloading \(count) of \(total)"
        
        let progress: Float = total == 0 ? 0 : Float(count)/Float(total)
        progressView.setProgress(progress, animated: true)
    }
}
