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
private let SPACE_BETWEEN_MUG_TEXTS : CGFloat = 12.0

class MugTextsContainer : UIView, MugTextViewDelegate {
    
    var mugTextViews: [MugTextView]! = [MugTextView]()
    
    private var mugTexts : [MugText]!
    private var tappedMugTextView: MugTextView?
    
    // MARK: - Initialization Methods
    
    convenience init(texts : [MugText]) {
        self.init(frame: CGRect.zeroRect)
        
        self.mugTexts = texts
        
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
        
        for mugText in self.mugTexts {

            var mugTextView : MugTextView = MugTextView(mugText: mugText)
            mugTextViews.append(mugTextView)
            
            mugTextView.delegate = self
            
            self.addSubview(mugTextView)
            
            var textWidth : CGFloat = mugTextView.getTextWidth()
            var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;

            mugTextView.mas_makeConstraints { (make) -> Void in
                make.height.equalTo()(MUG_TEXT_HEIGHT)
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
                self.tappedMugTextView = mugTextView;
                var selectionRect : CGRect = CGRectMake(mugTextView.frame.origin.x, mugTextView.frame.origin.y + 10, mugTextView.frame.size.width, mugTextView.frame.size.height);
                menuController.setTargetRect(selectionRect, inView: self)
                break;
            }
        }
    
        let lookupMenu = UIMenuItem(title: NSLocalizedString("Split", comment: "Split"), action: NSSelectorFromString("splitText"))
        menuController.menuItems = NSArray(array: [lookupMenu])
    
        menuController.update();
    
        menuController.setMenuVisible(true, animated: true)
    }
    
    func splitText() {
        let text = self.tappedMugTextView?.mugText.text

        println(">>>>> splitText: \(text!)")
       
        var texts : [String] = MugStringsUtil.splitMugString(text!);
        
        var lastMugText: MugTextView!
        var mugTextView: MugTextView
        var foundMug: Bool = false
        for mugTextView in self.mugTextViews {
            if (mugTextView.mugText.text == text) {
                foundMug = true
                
                //Update the original MugText with the first string and a smaller size
                mugTextView.mugText.text = texts[0]
                
                var textWidth : CGFloat = mugTextView.getTextWidth()
                var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                mugTextView.mas_updateConstraints { (make) -> Void in
                    make.height.equalTo()(MUG_TEXT_HEIGHT)
                    make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                    make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                }
                
                lastMugText = mugTextView
                
                var newMugTextView : MugTextView
                for var i=1; i < texts.count; i++ {
                    newMugTextView = MugTextView(mugText: MugText(mugId: 1000, text: texts[i], state: MugState.Default))
                    mugTextViews.append(newMugTextView) //TODO: fazer append no índice certo, não no final
                    
                    newMugTextView.delegate = self
                    self.addSubview(newMugTextView)
                    
                    var textWidth : CGFloat = newMugTextView.getTextWidth()
                    var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                    
                    newMugTextView.mas_makeConstraints { (make) -> Void in
                        make.height.equalTo()(MUG_TEXT_HEIGHT)
                        make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                        make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                    }
                    
                    lastMugText = newMugTextView
                }

                //break;
            } else {
                if (foundMug) { //só considera elementos após o match
                    //TODO: reposicionar mugTextView depois do elemento alterado a partir do lastMugText.mas_right
                    var textWidth : CGFloat = mugTextView.getTextWidth()
                    var buttonWidth : CGFloat = textWidth + MUG_TEXT_ADDITIONAL_WIDTH;
                    mugTextView.mas_updateConstraints { (make) -> Void in
                        make.height.equalTo()(MUG_TEXT_HEIGHT)
                        make.left.equalTo()(lastMugText != nil ? lastMugText.mas_right : self).with().offset()(SPACE_BETWEEN_MUG_TEXTS)
                        make.width.equalTo()(buttonWidth > MIN_BUTTON_WIDTH ? buttonWidth : MIN_BUTTON_WIDTH)
                    }
                }
            }
        }
        
        self.updateConstraints();
 
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
            
        else if action == "splitText" {
            return true;
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
}
