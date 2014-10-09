class JoinStringsTextFieldDemo : UIView, JoinStringsTextFieldDelegate {
    
    private var mugTextInput : JoinStringsTextField!
    
    
    // MARK: - Initialization Methods
    
    convenience override init() {
        self.init(frame: CGRect.zeroRect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubviews()
        self.initConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func initSubviews() {
        mugTextInput = JoinStringsTextField()
        
        mugTextInput.joinStringsTextFieldDelegate = self;
        
        self.backgroundColor = UIColor.orangeColor()

        mugTextInput.font = UIFont.avenirNextRegular(UIFont.HeadingSize.h4)
        mugTextInput.backgroundColor = UIColor.whiteColor()
        mugTextInput.textColor = UIColor.blackColor()
        mugTextInput.autocorrectionType = UITextAutocorrectionType.No
        
        self.addSubview(mugTextInput)
    }
    
    private func initConstraints() {
        
        mugTextInput.mas_makeConstraints { (make) -> Void in
            make.centerX.equalTo()(self)
            make.centerY.equalTo()(self)
            make.width.equalTo()(200)
        }
    }
    
    func didJoinedWords(joinStringsTextField: JoinStringsTextField!, finalString: String!) {
        println("didJoinedWords: '\(finalString)'");
    }
    
}
