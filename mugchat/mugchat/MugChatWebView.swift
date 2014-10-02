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

class MugChatWebView: UIView, UIWebViewDelegate {
    
    let webView: UIWebView! = UIWebView()
    let activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    var url: String!
    
    init(URL: String) {
        super.init()
        self.url = URL
        self.addSubviews()
        self.makeConstraints()
    }
    
    func addSubviews() {
        self.webView.delegate = self
        self.addSubview(self.webView)
        
        self.activityIndicator.hidesWhenStopped = true
        self.addSubview(self.activityIndicator)
    }
    
    func viewDidLoad() {
        let URL = NSURL(string: self.url)
        let request = NSURLRequest(URL: URL)
        self.webView.loadRequest(request)
    }
    
    func makeConstraints() {
        self.webView.mas_makeConstraints { (make) -> Void in
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
            make.top.equalTo()(self)
        }
        
        self.activityIndicator.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self.webView)
            make.centerY.equalTo()(self.webView)
        }
    }
    
    
    // MARK: - Web View Delegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.webView.userInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.stopAnimating()
        self.webView.userInteractionEnabled = true
    }
    
    
    // MARK: - Required methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
