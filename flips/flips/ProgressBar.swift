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

    var progressBarFillSpacing: CGFloat = 2.0

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

    override func layoutSubviews() {
        let height = self.bounds.size.height

        self.progressBarFillSpacing = height * 0.2

        self.layer.cornerRadius = height / 2.0
        self.layer.borderWidth = height * 0.1
        self.progressFill.layer.cornerRadius = self.layer.cornerRadius - self.progressBarFillSpacing

        self.progressFill.mas_updateConstraints { (make) -> Void in
            make.left.equalTo()(self).with().offset()(self.progressBarFillSpacing)
            make.top.equalTo()(self).with().offset()(self.progressBarFillSpacing)
            make.bottom.equalTo()(self).with().offset()(-self.progressBarFillSpacing)
        }
        self.updateConstraintsIfNeeded()
        
        super.layoutSubviews()
    }

    private func addSubviews() {
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.backgroundColor = UIColor.blackColor()

        self.progressFill = UIView()
        self.progressFill.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.progressFill)
    }

    private func makeConstraints() {
        self.progressFill.mas_makeConstraints { (make) -> Void in
            make.width.equalTo()(0)
            return
        }
    }

    private func updateProgressFill() {
        let maxWidth = Float(self.bounds.width - (self.progressBarFillSpacing * 2))
        let fillWidth = maxWidth * self.progress

        self.progressFill.mas_updateConstraints { (make) -> Void in
            make.width.equalTo()(fillWidth)
            return
        }
    }

    func setProgress(progress: Float, animated: Bool) {
        self.setProgress(progress, animated: animated, completion: nil)
    }

    func setProgress(progress: Float, animated: Bool, completion:(() -> Void)?) {
        self.setProgress(progress, animated: animated, duration: 0.3, completion: completion)
    }

    func setProgress(progress: Float, animated: Bool, duration: NSTimeInterval, completion:(() -> Void)?) {
        self.progress = progress

        if (animated) {
            UIView.animateWithDuration(duration,
                animations: { () -> Void in
                    self.setNeedsLayout()
                    self.layoutIfNeeded()

            }) { (finish) -> Void in
                completion?()
                return
            }
        } else {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            completion?()
        }
    }

}
