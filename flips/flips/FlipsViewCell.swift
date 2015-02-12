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

private let FLIPS_CELL_WIDTH: CGFloat = 83.5
private let FLIPS_CELL_HEIGHT: CGFloat = 83.5

class FlipsViewCell : UICollectionViewCell {
    
    private var flipID: String! // TODO: change it to keep flipID instead of the NSManagedObject
    private var cellImageView: UIImageView!
    private var seletedOverlayView: SelectedFlipOverlayView!
    
    var isSelected: Bool!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellImageView = UIImageView()
        cellImageView.frame.size = CGSizeMake(FLIPS_CELL_WIDTH, FLIPS_CELL_HEIGHT)
        self.addSubview(cellImageView);
        
        self.seletedOverlayView = SelectedFlipOverlayView(frame: CGRectMake(0, 0, FLIPS_CELL_WIDTH, FLIPS_CELL_WIDTH))
        self.seletedOverlayView.alpha = 0
        self.addSubview(seletedOverlayView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFlipId(flipID: String) {
        self.flipID = flipID
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let flipDataSource = FlipDataSource()
            var flip = flipDataSource.retrieveFlipWithId(self.flipID)
            
            if (flip.isPrivate.boolValue) {
                let useLocalPathFunction: (path: String) -> Void = {
                    (path) in
                    var image: UIImage!
                    if (flip.isBackgroundContentTypeVideo()) {
                        image = VideoHelper.generateThumbImageForFile(path)
                    } else {
                        image = UIImage(contentsOfFile: path)
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.cellImageView.image = image
                    })
                }
                
                if (flip.owner.userID == User.loggedUser()?.userID) {
                    let userFlipsCache = UserFlipsCache.sharedInstance
                    userFlipsCache.get(NSURL(fileURLWithPath: flip.backgroundURL)!,
                        success: {
                            (localPath: String!) in
                            useLocalPathFunction(localPath)
                        },
                        failure: {
                            (error: FlipError) in
                            println("Failed to get resource from cache, error: \(error)")
                            //TODO enhance error handling
                    })
                } else {
                    useLocalPathFunction(flip.backgroundContentLocalPath())
                }
            } else {
                let url = NSURL(string: flip.thumbnailURL)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    ActivityIndicatorHelper.showActivityIndicatorAtView(self.cellImageView, style: UIActivityIndicatorViewStyle.White)
                    self.cellImageView.setImageWithURL(url, success: { (request, response, image) -> Void in
                        ActivityIndicatorHelper.hideActivityIndicatorAtView(self.cellImageView)
                    })
                })
            }
        })
    }
    
    func setSelected(var selected: Bool) {
        if (selected) {
            self.seletedOverlayView.alpha = 1
        } else {
            self.seletedOverlayView.alpha = 0
        }
        self.isSelected = selected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellImageView.image = UIImage()
        self.isSelected = false
    }
}
