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

import MediaPlayer

class TutorialPageVideoViewController : TutorialPageViewController {

    var pageVideo: String = ""

    private var videoPlayer: MPMoviePlayerController!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.videoPlayer = MPMoviePlayerController(contentURL: self.videoURL())
        self.videoPlayer.allowsAirPlay = false
        self.videoPlayer.controlStyle = MPMovieControlStyle.None
        self.videoPlayer.backgroundView.backgroundColor = self.view.backgroundColor
        self.videoPlayer.view.backgroundColor = self.view.backgroundColor
        self.view.addSubview(self.videoPlayer.view)

        self.videoPlayer.view.mas_makeConstraints({ (make) -> Void in
            make.top.equalTo()(self.view).with().offset()(44)
            make.left.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
            make.right.equalTo()(self.view)
        })

        self.videoPlayer.prepareToPlay()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.videoPlayer.play()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.videoPlayer.stop()
    }

    private func videoURL() -> NSURL {
        let videoExtension = self.pageVideo.pathExtension
        let videoName = self.pageVideo.substringToIndex(self.pageVideo.rangeOfString(".\(videoExtension)")!.startIndex)

        let videoURL = NSBundle.mainBundle().URLForResource(videoName, withExtension: videoExtension)

        return videoURL!
    }

}
