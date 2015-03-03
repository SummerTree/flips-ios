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

public typealias SessionServiceSuccessResponse = (AnyObject?) -> Void
public typealias SessionServiceFailureResponse = (FlipError?) -> Void

public class SessionService: FlipsService {
    
    private let SESSION_URL: String = "/user/{{user_id}}/session"
    
    public class var sharedInstance : SessionService {
        struct Static {
            static let instance : SessionService = SessionService()
        }
        return Static.instance
    }
        
    // MARK: - Check user session
    
    func checkSession(userId: String, success: SessionServiceSuccessResponse, failure: SessionServiceFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failure(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let checkSessionURL = SESSION_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: userId, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let url = HOST + checkSessionURL
        
        self.get(url,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(FlipError(error: response["error"] as String!, details: nil))
                } else {
                    failure(FlipError(error: error.localizedDescription, details: nil))
                }
            }
        )
    }
    
}