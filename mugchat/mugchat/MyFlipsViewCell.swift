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

private let MY_FLIPS_CELL_WIDTH: CGFloat = 83.5
private let MY_FLIPS_CELL_HEIGHT: CGFloat = 83.5

class MyFlipsViewCell : UICollectionViewCell {
    
    private var flip: Flip! // TODO: change it to keep flipID instead of the NSManagedObject
    private var cellImageView: UIImageView!
    private var seletedOverlayView: SelectedFlipOverlayView!
    
    var isSelected: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellImageView = UIImageView()
        cellImageView.frame.size = CGSizeMake(MY_FLIPS_CELL_WIDTH, MY_FLIPS_CELL_HEIGHT)
        self.addSubview(cellImageView);
        
        self.seletedOverlayView = SelectedFlipOverlayView(frame: CGRectMake(0, 0, MY_FLIPS_CELL_WIDTH, MY_FLIPS_CELL_WIDTH))
        self.seletedOverlayView.alpha = 0
        self.addSubview(seletedOverlayView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFlip(flip: Flip) {
        self.flip = flip
        
        let flipContentPath = self.flip.backgroundContentLocalPath()
        if (self.flip.isBackgroundContentTypeVideo()) {
            let videoThumbnail = VideoHelper.generateThumbImageForFile(flipContentPath)
            self.cellImageView.image = videoThumbnail
        } else {
            let image = UIImage(contentsOfFile: flipContentPath)
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
