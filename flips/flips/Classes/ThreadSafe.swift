//
//  ThreadSafe.swift
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

import Foundation

// Provides a generic thread safe way to access things
class ThreadSafe<T> {
    private var unsafeValue: T
    
    var value: T {
        get {
            objc_sync_enter(self)
            let value = unsafeValue
            objc_sync_exit(self)
            
            return value
        }
        set {
            objc_sync_enter(self)
            unsafeValue = newValue
            objc_sync_exit(self)
        }
    }
    
    init(_ value: T) {
        unsafeValue = value
    }
}