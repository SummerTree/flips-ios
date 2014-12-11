//
//  NSErrorExtensions.swift
//  mugchat
//
//  Created by Eric Chamberlain on 12/11/14.
//
//

import Foundation

extension NSError {
    var localizedFailureReasonOrDescription: String {
        if (self.localizedFailureReason != nil) {
            return self.localizedFailureReason!
        } else {
            return self.localizedDescription
        }
    }
}