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

public class FlipsService : NSObject {
    
    let HOST: String = "http://flips-dev95.arctouch.com"
	
	func isForbiddenRequest(error: NSError!) -> Bool {
		return (error.localizedDescription.rangeOfString(String(FlipsServiceCode.FORBIDDEN_REQUEST_CODE)) != nil)
	}
	
	func parseResponseError(error: NSError?) -> Int {
		if let errorToParse = error {
			if (isForbiddenRequest(errorToParse)) {
				return FlipsServiceCode.FORBIDDEN_REQUEST_CODE
			}
		}
		return FlipsServiceCode.NO_RESPONSE_CODE
	}

}

public struct FlipsServiceCode {
	static let FORBIDDEN_REQUEST_CODE: Int = 403
	static let NO_RESPONSE_CODE: Int = 0
}