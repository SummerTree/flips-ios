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

class BuilderAddWordTableViewController: UITableViewController, UITextFieldDelegate {
    
    private let NUMBER_OF_SECTIONS_IN_TABLEVIEW: Int = 1
    private let CELL_IDENTIFIER = "BuilderWordCell"
    private let CELL_HEIGHT: CGFloat = 56.0
    
    private var words: [String]!
    
    private var newWordTextField: UITextField!
    
    private var didUpdateWordList = false
    
    var delegate: BuilderAddWordTableViewControllerDelegate?
    
    override init() {
        super.init()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    convenience init(words: [String]) {
        self.init()
        self.words = words
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
        
        self.newWordTextField = UITextField()
        let paddingView = UIView(frame: CGRectMake(0, 0, 16, newWordTextField.frame.size.height))
        self.newWordTextField.backgroundColor = UIColor.sand()
        self.newWordTextField.leftView = paddingView
        self.newWordTextField.leftViewMode = UITextFieldViewMode.Always
        self.newWordTextField.autocorrectionType = UITextAutocorrectionType.No
        self.newWordTextField.returnKeyType = UIReturnKeyType.Next
        self.newWordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.newWordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.newWordTextField.resignFirstResponder()
        
        delegate?.builderAddWordTableViewControllerDelegate(self, finishingWithChanges: didUpdateWordList)
    }
    
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.newWordTextField
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CELL_HEIGHT
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CELL_HEIGHT
    }

    
    // MARK: UITableViewDelegate
    
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
        
        cell!.textLabel!.text = words[indexPath.row]
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let builderWordDataSource = BuilderWordDataSource()
                builderWordDataSource.removeBuilderWordWithWord(self.words[indexPath.row])
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.didUpdateWordList = true
                    self.words.removeAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                })
            })
        }
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (countElements(textField.text!) > 0) {
            let word = textField.text!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let builderWordDataSource = BuilderWordDataSource()
                builderWordDataSource.addWord(word, fromServer: false)
            })
            self.didUpdateWordList = true
            words.insert(word, atIndex: 0)
            tableView.reloadData()
            
            textField.text = ""
            textField.becomeFirstResponder()
            return true
        }
        
        return false
    }
}

protocol BuilderAddWordTableViewControllerDelegate {
    
    func builderAddWordTableViewControllerDelegate(tableViewController: BuilderAddWordTableViewController, finishingWithChanges hasChanges: Bool)
    
}