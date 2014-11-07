//
//  NewFlipViewController.swift
//  mugchat
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

// TODO: remove when class variables are supported by Swift (after upgrade to Xcode 6.1)
private let CELL_IDENTIFIER = "SomeCell"
private let STORYBOARD = "NewFlip"
private let TITLE = NSLocalizedString("New Flip", comment: "New Flip")


class NewFlipViewController: MugChatViewController, JoinStringsTextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
	
	// MARK: - Constants
	
	// TODO: uncomment when class variables are supported by Swift
//	class private let CELL_IDENTIFIER = "SomeCell"
//	class private let STORYBOARD = "NewFlip"
//	class private let TITLE = NSLocalizedString("New Flip", comment: "New Flip")
	
	// MARK: - Class methods

	class func instantiateNavigationController() -> UINavigationController {
		let storyboard = UIStoryboard(name: STORYBOARD, bundle: nil)
		let navigationController = storyboard.instantiateInitialViewController() as UINavigationController
		navigationController.topViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
		
		return navigationController
	}
	
	// MARK: - Instance variables

	@IBOutlet weak var flipTextField: JoinStringsTextField!
	@IBOutlet weak var flipTextFieldHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var nextButtonAction: UIButton!
	@IBOutlet weak var searchTableView: UITableView!
	@IBOutlet weak var toTextView: UITextView!
	@IBOutlet weak var toTextViewHeightConstraint: NSLayoutConstraint!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupWhiteNavBarWithCancelButton(TITLE)
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
		
		if (neededHeight > maxHeight) {
			neededHeight = maxHeight
			view.contentOffset = CGPointZero
		}
		
		if (neededHeight != heightConstraint.constant) {
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
		return tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath) as UITableViewCell;
	}
	
	// MARK: - UITableViewDelegate
	
	// MARK: - UITextViewDelegate
	
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		if (text == "\n") {
			textView.resignFirstResponder()
			return false
		} else if (text.rangeOfString("\n") != nil) {
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
