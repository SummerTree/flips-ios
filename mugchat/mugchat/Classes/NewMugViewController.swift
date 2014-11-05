//
//  NewMugViewController.swift
//  mugchat
//
//  Created by Eric Chamberlain on 11/5/14.
//
//

import UIKit

class NewMugViewController: MugChatViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupWhiteNavBarWithCancelButton(NSLocalizedString("New Mug", comment: "New Mug"))
		
		self.setNeedsStatusBarAppearanceUpdate()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return UIStatusBarStyle.BlackOpaque
	}

}
