//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

class TutorialPageViewController : UIViewController {

    var pageIndex: Int = 0
    var pageImage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.flipOrangeBackground()

        var imageView = UIImageView(image: UIImage(named: self.pageImage))
        imageView.contentMode = .ScaleAspectFit
        self.view.addSubview(imageView)

        imageView.mas_makeConstraints({ (make) -> Void in
            make.top.equalTo()(self.view).with().offset()(44)
            make.left.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
            make.right.equalTo()(self.view)
        })

    }

}
