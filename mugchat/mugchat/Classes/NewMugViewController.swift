//
//  NewMugViewController.swift
//  mugchat
//
//  Created by Eric Chamberlain on 11/5/14.
//
//

import UIKit

class NewMugViewController: MugChatViewController, UITextViewDelegate {

	@IBOutlet weak var toTextView: UITextView!
	@IBOutlet weak var toTextViewHeightConstraint: NSLayoutConstraint!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupWhiteNavBarWithCancelButton(NSLocalizedString("New Mug", comment: "New Mug"))
		
		self.setNeedsStatusBarAppearanceUpdate()
		
		self.automaticallyAdjustsScrollViewInsets = false
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		
		self.updateToTextView()
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.BlackOpaque
	}
	
	private func updateToTextView() {
		let textViewSize = self.toTextView.sizeThatFits(CGSizeMake(CGRectGetWidth(self.toTextView.frame), CGRectGetHeight(self.toTextView.frame)/2))

		self.toTextViewHeightConstraint.constant = textViewSize.height
		self.toTextView.setNeedsLayout()
	}
	
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
		if textView == self.toTextView {
			self.updateToTextView()
		}
	}
}
