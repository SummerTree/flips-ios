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

class BuilderAddWordTableViewController: UITableViewController {
    
    private let NUMBER_OF_SECTIONS_IN_TABLEVIEW: Int = 1
    private let CELL_IDENTIFIER = "BuilderWordCell"
    private let CELL_HEIGHT: CGFloat = 56.0
    
    private var words: [String]!
    
    private var newWordTextField: UITextField!
    
    override init() {
        super.init()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    convenience init(words: [String]) {
        self.init()
        self.words = words
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.newWordTextField == nil) {
            self.newWordTextField = UITextField()
            let paddingView = UIView(frame: CGRectMake(0, 0, 16, newWordTextField.frame.size.height))
            self.newWordTextField.leftView = paddingView
            
            self.newWordTextField.leftViewMode = UITextFieldViewMode.Always
            self.newWordTextField.backgroundColor = UIColor.sand()
        }
        
        return self.newWordTextField
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CELL_HEIGHT
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWhiteNavBarWithoutBackButtonWithRightDoneButton("Builder")
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.translucent = false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return NUMBER_OF_SECTIONS_IN_TABLEVIEW
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: CELL_IDENTIFIER)
        }
        
        cell?.textLabel.text = words[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            self.words.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        tableView.reloadData()
    }
}