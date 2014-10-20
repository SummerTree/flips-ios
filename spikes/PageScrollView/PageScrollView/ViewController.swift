//
//  ViewController.swift
//  PageScrollView
//
//  Created by Bruno Bruggemann on 10/20/14.
//  Copyright (c) 2014 Bruno Bruggemann. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    private let ITEMS_SPACING: CGFloat = 20
    
    var scrollView: UIScrollView!
    var texts: [String]!
    var labels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView = UIScrollView(frame: self.view.frame)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        
        labels = Array()
        
        texts = Array()
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        texts.append("Bruno")
        texts.append("Fernando Ghisi")
        texts.append("Bruno B")
        texts.append("Ecil")
        texts.append("Dieguito")
        texts.append("MugChat")
        texts.append("Mug")
        
        var contentOffset: CGFloat = 0.0
        var index = 0
        
        for text in texts {
            var label = UILabel()
            label.text = text
            label.backgroundColor = UIColor.greenColor()
            label.sizeToFit()
            
            var leftMargin: CGFloat = 0
            var rightMargin: CGFloat = 0
            if (index == 0) {
                // Add left margin
                leftMargin = (CGRectGetWidth(self.view.frame) / 2) - (CGRectGetWidth(label.frame) / 2)
            } else if (index == (texts.count - 1)) {
                // Add right margin
                rightMargin = (CGRectGetWidth(self.view.frame) / 2) - (CGRectGetWidth(label.frame) / 2)
            }
            
            contentOffset += leftMargin
            
            label.frame = CGRectMake(contentOffset, 80, label.frame.size.width, label.frame.size.height)
            
            scrollView.addSubview(label)
            
            if (rightMargin == 0) {
                // The last item already has his rightMargin
                rightMargin = ITEMS_SPACING
            }
            contentOffset += label.frame.size.width + rightMargin
            scrollView.contentSize = CGSizeMake(contentOffset, label.frame.size.height)
            
            index++
            labels.append(label)
        }
        self.view.addSubview(scrollView)
        
        var centerMarkView = UIView(frame: CGRectMake(CGRectGetMidX(self.view.frame)-1, 70, 2, 10))
        centerMarkView.backgroundColor = UIColor.redColor()
        self.view.addSubview(centerMarkView)
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
       self.centerScrollView(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.centerScrollView(scrollView)
        }
    }
    
    private func centerScrollView(scrollView: UIScrollView) {
        var labelToBeCentered = labels[0]
        
        var scrollX = scrollView.contentOffset.x + CGRectGetMidX(scrollView.frame)
        
        for label in labels {
            var currentCenteredLabelMidX = CGRectGetMidX(labelToBeCentered.frame)
            var nextLabelMidX = CGRectGetMidX(label.frame)
            
            var currentCenteredLabelDistanceFromCenter = scrollX - currentCenteredLabelMidX
            var nextLabelDistanceFromCenter = scrollX - nextLabelMidX
            
            if (abs(currentCenteredLabelDistanceFromCenter) > abs(nextLabelDistanceFromCenter)) {
                labelToBeCentered = label
            }
        }

        var labelToBeCenteredMidX: CGFloat = CGRectGetMidX(labelToBeCentered.frame)
        var scrollViewCenterX: CGFloat = CGRectGetMidX(scrollView.frame)
        var contentOffsetX = labelToBeCenteredMidX - scrollViewCenterX
        scrollView.setContentOffset(CGPointMake(contentOffsetX, 0.0), animated: true)
    }
}

