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

class ChatView: UIView {
    
    private let CELL_IDENTIFIER = "mugCell"
    private let REPLY_BUTTON_TOP_MARGIN : CGFloat = 18.0
    private let REPLY_BUTTON_OFFSET : CGFloat = 16.0
    private let HORIZONTAL_RULER_HEIGHT : CGFloat = 1.0
    
    var delegate: ChatViewController!
    var tableView: UITableView!
    var separatorView: UIView!
    var darkHorizontalRulerView: UIView!
    var replyButton: UIButton!
    var replyButtonView: UIView!
    

    // MARK: - Required initializers
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.makeConstraints()
        self.backgroundColor = UIColor.whiteColor()

    }
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Layout
    
    func addSubviews() {
        tableView = UITableView(frame: self.frame, style: .Plain)
        tableView.backgroundColor = UIColor.greenColor()
        tableView.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.contentOffset = CGPointMake(0, 0)
        
//        tableView.contentInset = UIEdgeInsetsMake(self.delegate?.navigationController?.navigationBar.getNavigationBarHeight(), 0, 0, 0)
//        tableView.contentOffset = CGPointMake(0, -self.delegate?.navigationController?.navigationBar.getNavigationBarHeight())
        
        self.addSubview(tableView)
        
        
        separatorView = UIView()
        separatorView.backgroundColor = UIColor.blueColor()
        self.addSubview(separatorView)
        
        darkHorizontalRulerView = UIView()
        darkHorizontalRulerView.backgroundColor = UIColor.deepSea()
        self.addSubview(darkHorizontalRulerView)
        
        replyButtonView = UIView()
        self.addSubview(replyButtonView)
        
        replyButton = UIButton()
        replyButton.contentMode = .Center
        replyButton.addTarget(self, action: "replyButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        replyButton.setImage(UIImage(named: "Reply"), forState: UIControlState.Normal)
        replyButtonView.addSubview(replyButton)
    }
    
    func makeConstraints() {
        
        tableView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
        })
        
        separatorView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self.tableView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.REPLY_BUTTON_TOP_MARGIN)
        })
        
        darkHorizontalRulerView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self.separatorView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.HORIZONTAL_RULER_HEIGHT)
        })
        
        replyButtonView.mas_makeConstraints( { (make) in
            make.top.equalTo()(self.darkHorizontalRulerView.mas_bottom)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self.replyButton.imageForState(UIControlState.Normal)!.size.height + (self.REPLY_BUTTON_OFFSET * 2.0))
        })
        
        replyButton.mas_makeConstraints({ (make) in
            make.centerX.equalTo()(self.replyButtonView)
            make.centerY.equalTo()(self.replyButtonView)
            make.width.equalTo()(self.replyButton.imageForState(UIControlState.Normal)!.size.width)
        })
        
    }
    
    // MARK: - CustomNavigationBarDelegate
    
    func customNavigationBarDidTapLeftButton(navBar : CustomNavigationBar) {
        delegate?.chatViewDidTapBackButton(self)
    }
    
    
}

protocol ChatViewDelegate {
    
    func chatViewDidTapBackButton(view: ChatView)
    
}