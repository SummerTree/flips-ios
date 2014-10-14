import UIKit

class TempMugTextInputTestViewController: MugChatViewController {
    
    var newPasswordView: JoinStringsTextFieldDemo!
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(teste: String) {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        super.loadView()
        
        newPasswordView = JoinStringsTextFieldDemo()
        //newPasswordView.delegate = self
        self.view = newPasswordView
    }
    
}

