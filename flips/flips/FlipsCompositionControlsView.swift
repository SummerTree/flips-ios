//
//  FlipsCompositionControlsView.swift
//  flips
//
//  Created by Taylor Bell on 8/27/15.
//
//

import Foundation

class FlipsCompositionControlsView : UIView, CaptureControlsViewDelegate, EditControlsViewDelegate {
    
    weak var delegate : FlipsCompositionControlsDelegate!
    weak var dataSource : FlipSelectionViewDataSource? {
        set {
            editControls.dataSource = newValue
            captureControls.dataSource = newValue
        }
        get {
            return editControls.dataSource
        }
    }
    
    // UI
    private var editControls: ComposeEditControlsView!
    private var captureControls: ComposeCaptureControlsView!
    
    
    
    ////
    // MARK: - Init
    ////
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        initSubviews()
        initConstraints()
    }

    
    
    ////
    // MARK: - Subview Initialization
    ////
    
    func initSubviews() {
        
        editControls = ComposeEditControlsView()
        editControls.delegate = self
        editControls.alpha = 0
        addSubview(editControls)
        
        captureControls = ComposeCaptureControlsView()
        captureControls.delegate = self
        captureControls.alpha = 0
        addSubview(captureControls)
        
    }
    
    func initConstraints() {
        
        editControls.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self)
        }
        
        captureControls.mas_makeConstraints { (make) -> Void in
            make.top.equalTo()(self)
            make.left.equalTo()(self)
            make.right.equalTo()(self)
            make.height.equalTo()(self)
        }
        
    }
    
    
    
    ////
    // MARK: - Camera Controls
    ////
    
    internal func enableCameraControls() {
        captureControls.enableCameraControls()
    }
    
    internal func disableCameraControls() {
        captureControls.disableCameraControls()
    }
    
    
    
    ////
    // MARK: - Control Mode
    ////
    
    internal func areCaptureControlsVisible() -> (Bool) {
        return captureControls.alpha == 1
    }
    
    internal func showCaptureControls() {
        
        captureControls.reloadFlipsView()
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.editControls.alpha = 0
            self.captureControls.alpha = 1.0
        })
        
    }
    
    internal func areEditControlsVisible() -> (Bool) {
        return editControls.alpha == 1
    }
    
    internal func showEditControls() {
        
        editControls.reloadFlipsView()
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.editControls.alpha = 1.0
            self.captureControls.alpha = 0
        })
        
    }
    
    
    
    ////
    // MARK: - Flips Views
    ////
    
    func resetFlipsViews() {
        editControls.dismissStockFlips(false)
        editControls.dismissUserFlips(false)
        captureControls.dismissStockFlips(false)
        captureControls.dismissUserFlips(false)
    }
    
    
    
    ////
    // MARK: - Scroll Methods
    ////
    
    internal func scrollToFlipsView(animated: Bool) {
        editControls.scrollToFlipsView(animated)
    }
    
    internal func scrollToDeleteButton(animated: Bool) {
        editControls.scrollToDeleteButton(animated)
    }
    
    internal func scrollToVideoButton(animated: Bool) {
        captureControls.scrollToVideoButton(animated)
    }
    
    
    
    ////
    // MARK: - ComposeCaptureControlsViewDelegate
    ////
    
    func captureControlsDidShowUserFlips() {
        editControls.dismissStockFlips(false)
        editControls.showUserFlips(false)
    }
    
    func captureControlsDidDismissUserFlips() {
        editControls.dismissStockFlips(false)
        editControls.dismissUserFlips(false)
    }
    
    func captureControlsDidShowStockFlips() {
        editControls.dismissUserFlips(false)
        editControls.showStockFlips(false)
    }
    
    func captureControlsDidDismissStockFlips() {
        editControls.dismissUserFlips(false)
        editControls.dismissStockFlips(false)
    }
    
    func didSelectStockFlipAtIndex(index: Int) {
        delegate?.didSelectStockFlipAtIndex(index)
    }
    
    func didSelectFlipAtIndex(index: Int) {
        delegate?.didSelectFlipAtIndex(index)
    }
    
    func didPressVideoButton() {
        delegate?.didPressVideoButton()
    }
    
    func didReleaseVideoButton() {
        delegate?.didReleaseVideoButton()
    }
    
    func didTapCapturePhotoButton() {
        delegate?.didTapCapturePhotoButton()
    }
    
    func didTapGalleryButton() {
        delegate?.didTapGalleryButton()
    }
    
    
    
    ////
    // MARK: - ComposeCaptureControlsViewDelegate
    ////
    
    func editControlsDidShowUserFlips() {
        captureControls.dismissStockFlips(false)
        captureControls.showUserFlips(false)
    }
    
    func editControlsDidDismissUserFlips() {
        captureControls.dismissStockFlips(false)
        captureControls.dismissUserFlips(false)
    }
    
    func editControlsDidShowStockFlips() {
        captureControls.dismissUserFlips(false)
        captureControls.showStockFlips(false)
    }
    
    func editControlsDidDismissStockFlips() {
        captureControls.dismissUserFlips(false)
        captureControls.dismissStockFlips(false)
    }
    
    func didTapDeleteButton() {
        delegate?.didTapDeleteButton()
    }
    
}

protocol FlipsCompositionControlsDelegate : class {
    
    func didSelectStockFlipAtIndex(index: Int)
    
    func didSelectFlipAtIndex(index: Int)
    
    func didPressVideoButton()
    
    func didReleaseVideoButton()
    
    func didTapCapturePhotoButton()
    
    func didTapGalleryButton()
    
    func didTapDeleteButton()
    
}