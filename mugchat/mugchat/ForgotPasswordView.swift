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

class ForgotPasswordView : UIView {
    
    var delegate: ForgotPasswordViewDelegate?
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.mugOrange()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func viewDidLoad() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func addSubviews() {
        
        //logoView = UIView()
        //self.addSubview(logoView)
        
        //bubbleChatImageView = UIImageView(image: UIImage(named: "ChatBubble"))
        //bubbleChatImageView.contentMode = UIViewContentMode.Center
        //logoView.addSubview(bubbleChatImageView)
    }
    
    func makeConstraints() {
        
    }
    
    
    // MARK: - Buttons delegate
    func finishTypingMobileNumber(sender: AnyObject?) {
        self.delegate?.forgotPasswordViewDidFinishTypingMobileNumber(self)
    }
    
    
    // MARK: - Required methods
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
}
