//
//  FlipsSendButton.swift
//  flips
//
//  Created by Noah Labhart on 6/16/15.
//
//

import Foundation

enum FlipsSendButtonOption : String, CustomStringConvertible {
    case Flips = "Flips"
    case SMS = "SMS"
    case WhatsApp = "WhatsApp"
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Instagram = "Instagram"
    case NotSet = "Not Set"
    
     var description : String {
        get {
            return self.rawValue
        }
    }
}

class FlipsSendButton: UIImageView {
    let activeColor : UIColor
    let sendButtonType : FlipsSendButtonOption
    let imageName : String
    let inactiveColor : UIColor = UIColor.lightGrayColor()
    
    var allowedToBeInactive : Bool
    
    var isButtonActive : Bool {
        get {
            if self.allowedToBeInactive {
                return (backgroundColor == activeColor)
            }
            else {
                return true
            }
        }
    }
    
    init(buttonCount aCount: Int,
         buttonOrder order: Int,
         buttonHeight height: CGFloat,
         activeColor aColor: UIColor,
         buttonType aType: FlipsSendButtonOption,
         imageName anImage: String,
         allowedToBeInactive canBeInactive: Bool) {
            
        self.activeColor = aColor
        self.sendButtonType = aType
        self.imageName = anImage
        self.allowedToBeInactive = canBeInactive
        
        super.init(image: UIImage(named: self.imageName) as UIImage?)
        
        let width = calculateWidth(buttonCount: aCount)
        let xPosition = Float(order) * width
        let newFrame = CGRect(x: CGFloat(xPosition),
                              y: CGFloat(0.0),
                              width: CGFloat(width),
                              height: height)
        
        let tapRecog = UITapGestureRecognizer(target: self, action: #selector(FlipsSendButton.buttonTouched(_:)))
        tapRecog.numberOfTapsRequired = 1
        addGestureRecognizer(tapRecog)
            
        self.frame = newFrame
        self.backgroundColor = activeColor
        
        self.userInteractionEnabled = true
        self.contentMode = .Center //.ScaleAspectFit
        self.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTouched(sender: UITapGestureRecognizer) {

        if self.allowedToBeInactive {
            if self.backgroundColor == inactiveColor {
                self.backgroundColor = activeColor
            } else {
                self.backgroundColor = inactiveColor
            }
        }
    }
    
    func makeActive() {
        self.backgroundColor = activeColor
    }
    
    func makeInactive() {
        self.backgroundColor = inactiveColor
    }
    
    private func calculateWidth(buttonCount aCount: Int) -> Float {
        let width = Float(UIScreen.mainScreen().bounds.width)
        let numberOfButtons = Float(aCount)
        let equalSize = (width/numberOfButtons);
        
        return equalSize
    }
}
