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

protocol InboxViewDelegate: class {
    
    func inboxViewDidTapComposeButton(inboxView : InboxView)
    func inboxViewDidTapSettingsButton(inboxView : InboxView)
    func inboxViewDidTapBuilderButton(inboxView : InboxView)
    func inboxView(inboxView : InboxView, didTapAtItemAtIndex index: Int)
    
}