//
//  NewFlipViewController.swift
//  mugchat
//
//  Created by Eric Chamberlain on 11/5/14.
//
//

import UIKit

let CellIdentifier = "SomeCell"
let NewFlipViewControllerStoryboard = "NewFlip"
let Title = NSLocalizedString("New Flip", comment: "New Flip")


class NewFlipViewController: MugChatViewController, JoinStringsTextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {

	@IBOutlet weak var flipTextField: JoinStringsTextField!
	@IBOutlet weak var flipTextFieldHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var nextButtonAction: UIButton!
	@IBOutlet weak var searchTableView: UITableView!
	@IBOutlet weak var toTextView: UITextView!
	@IBOutlet weak var toTextViewHeightConstraint: NSLayoutConstraint!
	
	class func instantiateNavigationController() -> UINavigationController {
		let storyboard = UIStoryboard(name: NewFlipViewControllerStoryboard, bundle: nil)
		let navigationController = storyboard.instantiateInitialViewController() as UINavigationController
		navigationController.topViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen

		return navigationController
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupWhiteNavBarWithCancelButton(Title)
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		self.automaticallyAdjustsScrollViewInsets = false
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.BlackOpaque
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		
		self.updateHeightConstraintIfNeeded(self.flipTextFieldHeightConstraint, view: self.flipTextField)
		self.updateHeightConstraintIfNeeded(self.toTextViewHeightConstraint, view: self.toTextView)
	}
	
	private func updateHeightConstraintIfNeeded(heightConstraint: NSLayoutConstraint, view: UIScrollView) {
		let maxHeight = CGRectGetHeight(self.view.frame)/2
		var neededHeight = view.contentSize.height
		
		if neededHeight > maxHeight {
			neededHeight = maxHeight
			view.contentOffset = CGPointZero
		}
		
		if neededHeight != heightConstraint.constant {
			heightConstraint.constant = neededHeight
		}
	}
	
	// MARK: - Actions
	
	@IBAction func nextButtonAction(sender: UIButton) {
		
	}
	
	// MARK: - JointStringsTextFieldDelegate
	
	func joinStringsTextFieldNeedsToHaveItsHeightUpdated(joinStringsTextField: JoinStringsTextField!) {
		self.view.setNeedsUpdateConstraints()
	}
	
	// MARK: - UITableViewDataSource
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		return tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as UITableViewCell;
	}
	
	// MARK: - UITableViewDelegate
	
	// MARK: - UITextViewDelegate
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		} else if text.rangeOfString("\n") != nil {
			let replacementText: String = text.stringByReplacingOccurrencesOfString("\n", withString: "")
			textView.text = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: replacementText)
			return false
		}
		
		return true
	}
	
	func textViewDidChange(textView: UITextView) {
		self.view.setNeedsUpdateConstraints()
	}
}
