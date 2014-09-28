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

import UIKit

class TermsOfUseView: UIView {
    
    let TERMS_OF_USE_URL = "http://www.arctouch.com"
    
    var webView: UIWebView!
    
    override init() {
        super.init()
        self.addSubviews()
        self.makeConstraints()
    }
    
    func addSubviews() {
        
        self.webView = UIWebView()

        let URL = NSURL(string: TERMS_OF_USE_URL)
        let request = NSURLRequest(URL: URL)
        
        self.webView.loadRequest(request)
        self.addSubview(self.webView)
    }
    
    func makeConstraints() {
        self.webView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.top.equalTo()(self)
        }
    }
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
