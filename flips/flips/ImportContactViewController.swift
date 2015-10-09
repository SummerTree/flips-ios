//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import Foundation

class ImportContactViewController: UIViewController {
    
    private var alreadyExecuted: Bool = false
    private var importContactView: ImportContactView!

    init() {
        super.init(nibName: nil, bundle: nil)
        self.importContactView = ImportContactView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        self.view = self.importContactView
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setupWhiteNavBarWithoutButtons("Contacts")
        self.navigationController?.navigationBar.alpha = 1.0
        self.navigationController?.navigationBar.translucent = false
        let textAttributes = [NSForegroundColorAttributeName: UIColor.deepSea()]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        super.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidAppear(animated: Bool) {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        
        let localGroup = dispatch_group_create()
        
        if (User.loggedUser()?.facebookID != nil) {
            UserService.sharedInstance.importFacebookFriends({ (success) -> Void in
                print("Success importing facebook friends")
            }, failure: { (error) -> Void in
                print("Error importing facebook friends: \(error?.error) details: \(error?.details)")
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            UserService.sharedInstance.uploadContacts({ (success) -> Void in
                print("Success importing local contacts")
                let importContactsTableViewController = ImportContactsTableViewController()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if let user = User.loggedUser() {
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setValue(true, forKey: "\(user.userID)DidImportContacts")
                        userDefaults.synchronize()
                    }
                    
                    ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                    self.navigationController?.pushViewController(importContactsTableViewController, animated: true)
                })
                
            }, failure: { (error) -> Void in
                print("Error importing local contacts")
                ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    let alertView = UIAlertView(title: error!.error,
                        message: error!.details,
                        delegate: nil,
                        cancelButtonTitle: LocalizedString.OK)
                    alertView.show()
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        })
    }
}
