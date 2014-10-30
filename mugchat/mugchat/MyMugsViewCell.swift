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

class MyMugsViewCell : UICollectionViewCell {
    
    var mug: Mug!
    var cellImageView: UIImageView!
    var seletedOverlayView: SelectedMugOverlayView!
    
    var cellIsSelected = false
    
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
    
    func toggleCellState() {
        if (self.cellIsSelected) {
            self.seletedOverlayView.alpha = 0
        } else {
            self.seletedOverlayView.alpha = 1
        }
        self.cellIsSelected = !self.cellIsSelected
    }
    
    func deselectCell() {
        if (self.cellIsSelected) {
            self.seletedOverlayView.alpha = 0
            self.cellIsSelected = false
        }
    }
    
}
