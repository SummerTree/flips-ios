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

private let MY_MUGS_CELL_WIDTH: CGFloat = 83.5
private let MY_MUGS_CELL_HEIGHT: CGFloat = 83.5

class MyFlipsViewCell : UICollectionViewCell {
    
    private var mug: Mug!
    private var cellImageView: UIImageView!
    private var seletedOverlayView: SelectedMugOverlayView!
    
    var isSelected: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellImageView = UIImageView()
        cellImageView.frame.size = CGSizeMake(MY_MUGS_CELL_WIDTH, MY_MUGS_CELL_HEIGHT)
        self.addSubview(cellImageView);
        
        self.seletedOverlayView = SelectedMugOverlayView(frame: CGRectMake(0, 0, MY_MUGS_CELL_WIDTH, MY_MUGS_CELL_WIDTH))
        self.seletedOverlayView.alpha = 0
        self.addSubview(seletedOverlayView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMug(mug: Mug) {
        self.mug = mug
        println("mug: \(mug.mugID)")
        
        let mugContentPath = self.mug.backgroundContentLocalPath()
        if (self.mug.isBackgroundContentTypeVideo()) {
            let videoThumbnail = VideoHelper.generateThumbImageForFile(mugContentPath)
            self.cellImageView.image = videoThumbnail
        } else {
            let image = UIImage(contentsOfFile: mugContentPath)
            self.cellImageView.image = image
        }
    }
    
    func setSelected(var selected: Bool) {
        if (selected) {
            self.seletedOverlayView.alpha = 1
        } else {
            self.seletedOverlayView.alpha = 0
        }
        self.isSelected = selected
    }
}
