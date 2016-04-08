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

class BuilderViewController : ComposeViewController, BuilderIntroductionViewControllerDelegate, BuilderAddWordTableViewControllerDelegate {
    
    private var builderIntroductionViewController: BuilderIntroductionViewController!

    
    // MARK: - Initialization Methods
    
    init() {
        super.init(composeTitle: NSLocalizedString("Builder", comment: "Builder"))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Overriden Methods
    
    override func viewDidLoad() {
        self.loadBuilderWords()
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.composeBottomViewContainer?.updateGridButton()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (!DeviceHelper.sharedInstance.didUserAlreadySeenBuildIntroduction()) {
            DeviceHelper.sharedInstance.setBuilderIntroductionShown()
            self.showIntroduction()
        }
    }
    
    override func shouldShowPreviewButton() -> Bool {
        return false
    }
    
    override func canShowMyFlips() -> Bool {
        return false
    }
    
    override func shouldShowPlusButtonInWords() -> Bool {
        return true
    }

    override func onFlipAssociated() {
        let flipWord = self.flipWords[self.highlightedWordIndex]

        _ = BuilderWordDataSource()
        PersistentManager.sharedInstance.removeBuilderWordWithWord(flipWord.text)

        self.loadBuilderWords()

        if (self.words.count == 0) {
            self.showEmptyState()
        } else {
            super.onFlipAssociated()
        }
    }

    override func updateFlipWordsState() {
        for flipWord in self.flipWords {
            let myFlipsForWord = self.myFlipsDictionary[flipWord.text]

            if (myFlipsForWord!.count > 0) {
                flipWord.state = .NotAssociatedButResourcesAvailable
            }
        }
    }


    // MARK: - Private

    private func showEmptyState() {
        self.composeTopViewContainer.showEmptyState()
        self.flipMessageWordListView.reloadWords()
        self.composeBottomViewContainer.showAllFlipCreateMessage()
    }


    // MARK: - Load BuilderWords Methods
    
    private func loadBuilderWords() {
        ActivityIndicatorHelper.showActivityIndicatorAtView(self.view)
        let builderWordDataSource = BuilderWordDataSource()
        let builderWords = builderWordDataSource.getWords()
        
        words = Array<String>()
        for builderWord in builderWords {
            words.append(builderWord.word)
        }
        
        ActivityIndicatorHelper.hideActivityIndicatorAtView(self.view)
        self.initFlipWords(words)
    }


    // MARK: - ComposeBottomViewContainerDataSource

    override func composeBottomViewContainerStockFlipIdsForHighlightedWord(composeBottomViewContainer: ComposeBottomViewContainer) -> [String] {
        // We only allow My Flips in this neighborhood
        return Array<String>()
    }


    // MARK: - Builder Introduction Methods
    
    func showIntroduction() {
        builderIntroductionViewController = BuilderIntroductionViewController(viewBackground: self.view.snapshot())
        builderIntroductionViewController.view.alpha = 0.0
        builderIntroductionViewController.delegate = self
        self.view.addSubview(builderIntroductionViewController.view)
        self.addChildViewController(builderIntroductionViewController)
        
        self.builderIntroductionViewController.view.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self.view)
            make.bottom.equalTo()(self.view)
            make.left.equalTo()(self.view)
            make.right.equalTo()(self.view)
        }
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.navigationController?.navigationBar.alpha = 0.001
            self.builderIntroductionViewController.view.alpha = 1.0
        })
    }
    
    func builderIntroductionViewControllerDidTapOkSweetButton(builderIntroductionViewController: BuilderIntroductionViewController!) {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.navigationController?.navigationBar.alpha = 1.0
            self.builderIntroductionViewController.view.alpha = 0.0
        }) { (completed) -> Void in
            self.view.sendSubviewToBack(self.builderIntroductionViewController.view)
        }
    }
    
    
    // MARK: - FlipMessageWordListView Delegate
    
    override func flipMessageWordListViewDidTapAddWordButton(flipMessageWordListView: FlipMessageWordListView) {
        let addWordWords: Array<String> = self.flipWords.map {
            return $0.text
        }

        let builderAddWordTableViewController = BuilderAddWordTableViewController(words: addWordWords)
        builderAddWordTableViewController.delegate = self
        self.navigationController?.pushViewController(builderAddWordTableViewController, animated: true)
    }

    
    // MARK: - BuilderAddWordTableViewControllerDelegate
    
    func builderAddWordTableViewControllerDelegate(tableViewController: BuilderAddWordTableViewController, finishingWithChanges hasChanges: Bool) {
        if (hasChanges) {
            self.loadBuilderWords()
            if (self.words.count > 0) {
                self.highlightedWordIndex = 0
                self.reloadMyFlips()
                self.updateFlipWordsState()
                self.showContentForHighlightedWord()
            } else {
                self.showEmptyState()
            }
        }
    }
}