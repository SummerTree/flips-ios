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

class ChatViewController: MugChatViewController, ChatViewDelegate {
    
    var chatView: ChatView!
    var chatTitle: String!
    
    init(chatTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatTitle = chatTitle
    }
    
    override func loadView() {
        self.chatView = ChatView()
        self.chatView.delegate = self
        self.view = chatView
        
        self.setupWhiteNavBarWithBackButton(chatTitle)
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.chatView.viewWillAppear()
        
        // FOR TESTS ONLY - START
        
//        var mugDataSource = MugDataSource()
//        var mugs : [Mug] = Array<Mug>()
//        mugs.append(mugDataSource.retrieveMugWithId("90"))
//        mugs.append(mugDataSource.retrieveMugWithId("100"))
//        mugs.append(mugDataSource.retrieveMugWithId("101"))
//        
//        let videoCreator = ImageVideoCreator()
//        let cacheHandler = CacheHandler.sharedInstance
//        for mug in mugs {
//            if (mug.backgroundURL != nil) {
//                if (mug.isBackgroundContentTypeImage()) {
//                    let videoPath = cacheHandler.getFilePathForUrl("\(mug.mugID).mov", isTemporary: true)
//                    let imageData = cacheHandler.dataForUrl(mug.backgroundURL)
//                    var mugImage: UIImage!
//                    if (imageData != nil) {
//                        mugImage = UIImage(data: imageData!)
//                    } else {
//                        // TODO use the green image
//                        //                        mugImage = UIImage.
//                    }
//                    
//                    var mugSoundPath: String?
//                    if ((mug.soundURL != nil) && (!mug.soundURL.isEmpty)) {
//                        var soundHasCacheResult = cacheHandler.hasCachedFileForUrl(mug.soundURL)
//                        if (soundHasCacheResult.hasCache) {
//                            mugSoundPath = soundHasCacheResult.filePath
//                        }
//                    }
//                    
//                    println("videoPath: \(videoPath)")
//                    videoCreator.createVideoForWord(mug.word, withImage: mugImage, andAudioPath: mugSoundPath, atPath: videoPath)
//                    
//                } else if (mug.isBackgroundContentTypeVideo()) {
//                    // TODO add the text to the video
//                }
//            }
//        }
        
        
        
        // TEST FINISH
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.chatView.viewWillDisappear()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.BlackOpaque
    }

    
    // MARK: - Delegate methods
    
    func chatViewDidTapBackButton(view: ChatView) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func chatView(view: ChatView, didTapNextButtonWithWords words : [String]) {
        var composeViewController = ComposeViewController(words: words)
        self.navigationController?.pushViewController(composeViewController, animated: true)
    }
   
    
    // MARK: - Required initializers
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}