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
		return (error.localizedDescription.rangeOfString(String(FlipError.BACKEND_FORBIDDEN_REQUEST)) != nil)
	}
	
	func parseResponseError(error: NSError?) -> Int {
		if let errorToParse = error {
			if (isForbiddenRequest(errorToParse)) {
				return FlipError.BACKEND_FORBIDDEN_REQUEST
			}
		}
		return FlipError.NO_CODE
	}

}