//
//  ViewController.swift
//  TextFieldTest
//
//  Created by Bruno Bruggemann on 10/24/14.
//  Copyright (c) 2014 Bruno Bruggemann. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var textView = UITextView(frame: CGRectMake(20, 20, 300, 44))
        textView.editable = true

        
        
        textView.backgroundColor = UIColor.redColor()
        self.view.addSubview(textView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

