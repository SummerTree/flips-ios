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


// TODO: scrollView (use UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout)
// http://stackoverflow.com/questions/26233999/uiscrollview-and-its-children-why-are-they-placed-on-top-of-each-other-autol

private let MIN_BUTTON_WIDTH : CGFloat = 70.0
private let MUG_TEXT_ADDITIONAL_WIDTH : CGFloat = 20.0
private let MUG_TEXT_HEIGHT : CGFloat = 40.0
private let MUG_TEXT_TOP_MARGIN : CGFloat = 5.0
private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0

class MugTextsContainer : UIView, MugTextViewDelegate {
    
    var mugTextViews: [MugTextView]! = [MugTextView]()
    
    private var texts : [MugText]!
    
    
    // MARK: - Initialization Methods
    
    convenience init(texts : [MugText]) {
        self.init(frame: CGRect.zeroRect)
        
        self.texts = texts
        
        self.backgroundColor = UIColor.whiteColor()

        self.initSubviews()
        
        self.becomeFirstResponder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubviews() {
        var lastMugText: MugTextView!
        
        for mugText in self.texts {

            var mugTextView : MugTextView = MugTextView(mugText: mugText)
            mugTextViews.append(mugTextView)
            
            mugTextView.delegate = self
            
            self.addSubview(mugTextView)
            
            var textWidth : CGFloat = mugTextView.getTextWidth()
            var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;

            mugTextView.mas_makeConstraints { (make) -> Void in
                make.height.equalTo()(MUG_TEXT_HEIGHT)
                make.top.equalTo()(0)
                make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
            }

            lastMugText = mugTextView;
        }
    }
    
    func didTapMugText(mugText : MugText!) {
        let menuController = UIMenuController.sharedMenuController()
        
        var mugTextView : MugTextView
        for mugTextView in mugTextViews {
            if (mugTextView.mugText.mugId == mugText.mugId) {
                var selectionRect : CGRect = CGRectMake(mugTextView.frame.origin.x, mugTextView.frame.origin.y + 10, mugTextView.frame.size.width, mugTextView.frame.size.height);
                menuController.setTargetRect(selectionRect, inView: self)
                break;
            }
        }
    
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Split", comment: "Split"), action: "splitText")
        menuController.menuItems = NSArray(array: [lookupMenu])
    
        menuController.update();
    
        menuController.setMenuVisible(true, animated: true)
    }
    
    func splitText() { //(mugText : MugText!) {
        println(">>>>> splitText")
        //var texts : [String] = MugStringsUtil.splitMugString(stringTest);
        //createMugs(texts)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true;
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "cut:" {
            return false;
        }
            
        else if action == "copy:" {
            return false;
        }
            
        else if action == "paste:" {
            return false;
        }
            
        else if action == "_define:" {
            return false;
        }
            
        else if action == "Split" {
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
}
