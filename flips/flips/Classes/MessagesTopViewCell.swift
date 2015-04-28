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

class MessagesTopViewCell : UITableViewCell {
   
    private var messageLabel: UILabel!
    
    
    // MARK: - Init Methods
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        
        messageLabel = UILabel()
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.numberOfLines = 2
        contentView.addSubview(messageLabel)
        
        messageLabel.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.bottom.equalTo()(self)
            make.leading.equalTo()(self)
            make.trailing.equalTo()(self)
        }
    }
    
    
    // MARK: - Message Setter
    
    func setAttributedMessage(message: NSAttributedString) {
        messageLabel.attributedText = message
    }
    
}