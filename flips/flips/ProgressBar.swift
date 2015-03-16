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

import UIKit

class ProgressBar: UIView {

    let PROGRESS_BAR_FILL_SPACING: CGFloat = 4.0

    private var _progress: Float = 0.0
    var progress: Float {
        get {
            return self._progress
        }
        set(value) {
            if (value > 1) {
                self._progress = 1
            } else if (value < 0) {
                self._progress = 0
            } else {
                self._progress = value
            }

            self.updateProgressFill()
        }
    }

    private var progressFill: UIView!

    override init() {
        super.init(frame: CGRectZero)

        self.addSubviews()
        self.makeConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.addSubviews()
        self.makeConstraints()
    }

    private func addSubviews() {
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2.0
        self.backgroundColor = UIColor.blackColor()

        self.progressFill = UIView()
        self.progressFill.backgroundColor = UIColor.whiteColor()
        self.progressFill.layer.cornerRadius = self.layer.cornerRadius - self.PROGRESS_BAR_FILL_SPACING
        self.addSubview(self.progressFill)
    }

    private func makeConstraints() {
        self.progressFill.mas_makeConstraints { (make) -> Void in
            make.left.equalTo()(self).with().offset()(self.PROGRESS_BAR_FILL_SPACING)
            make.top.equalTo()(self).with().offset()(self.PROGRESS_BAR_FILL_SPACING)
            make.bottom.equalTo()(self).with().offset()(-self.PROGRESS_BAR_FILL_SPACING)
            make.width.equalTo()(0)
        }
    }

    private func updateProgressFill() {
        let maxWidth = Float(self.bounds.width - (self.PROGRESS_BAR_FILL_SPACING * 2))
        let fillWidth = maxWidth * self.progress

        self.progressFill.mas_updateConstraints { (make) -> Void in
            make.top.equalTo()(self).with().offset()(self.PROGRESS_BAR_FILL_SPACING)
            make.width.equalTo()(fillWidth)
        }
    }

    func setProgress(progress: Float, animated: Bool) {
        self.setProgress(progress, animated: animated, completion: nil)
    }

    func setProgress(progress: Float, animated: Bool, completion:(() -> Void)?) {
        self.progress = progress

        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.setNeedsLayout()
                self.layoutIfNeeded()

        }) { (finish) -> Void in
            completion?()
            return
        }
    }

}
