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

public typealias OperationSuccessCallback = (AFHTTPRequestOperation!, AnyObject!) -> Void
public typealias OperationFailureCallback = (AFHTTPRequestOperation, NSError) -> Void

public struct FlipsServiceResponseCode {
    static let BACKEND_FORBIDDEN_REQUEST: Int = 403
    static let BACKEND_TIMED_OUT: Int = 408
    static let BACKEND_APP_VERSION_OUTDATED: Int = 420
    static let RESPONSE_CODE_KEY: String = "response_code"
}

public class FlipsService : NSObject {

    var HOST = AppSettings.currentSettings().serverURL()
    
    var APP_VERSION: String {
        let infoPlist: NSDictionary = NSBundle.mainBundle().infoDictionary!
        return infoPlist["CFBundleShortVersionString"] as String
    }

    private let BACKEND_TIMED_OUT_MESSAGE: String = "The request timed out."
    private let APP_VERSION_HEADER: String = "app_version"
    
    public enum ReturnValue {
        case NO_INTERNET_CONNECTION
        case WAITING_FOR_RESPONSE
    }
    
    
    // MARK: - Service Methods
    
	func post(urlString: String, parameters: AnyObject?, success: OperationSuccessCallback, failure: OperationFailureCallback) -> AFHTTPRequestOperation {

        let request: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        request.requestSerializer.setValue(APP_VERSION, forHTTPHeaderField: self.APP_VERSION_HEADER)
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer

        return request.POST(urlString,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(operation, responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (self.isForbiddenRequest(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_FORBIDDEN_REQUEST)
                } else if (self.isTimedOutError(error)) {
                    failure(AFHTTPRequestOperation(), self.errorForTimedOutError())
                } else if (self.isAppVersionOutdated(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_APP_VERSION_OUTDATED)
                } else {
                    failure(operation, error)
                }
            }
        )
    }

    func post(urlString: String, parameters: AnyObject?, constructingBodyWithBlock: (AFMultipartFormData!) -> Void, success: OperationSuccessCallback, failure: OperationFailureCallback) -> AFHTTPRequestOperation {
        let request: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        request.requestSerializer.setValue(APP_VERSION, forHTTPHeaderField: self.APP_VERSION_HEADER)
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer

        return request.POST(urlString,
            parameters: parameters,
            constructingBodyWithBlock: constructingBodyWithBlock,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(operation, responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (self.isForbiddenRequest(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_FORBIDDEN_REQUEST)
                } else if (self.isTimedOutError(error)) {
                    failure(AFHTTPRequestOperation(), self.errorForTimedOutError())
                } else if (self.isAppVersionOutdated(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_APP_VERSION_OUTDATED)
                } else {
                    failure(operation, error)
                }
            }
        )
    }
    
    func get(urlString: String, parameters: AnyObject?, success: OperationSuccessCallback, failure: OperationFailureCallback) -> AFHTTPRequestOperation {
        let request: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
        request.requestSerializer.setValue(APP_VERSION, forHTTPHeaderField: self.APP_VERSION_HEADER)
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer

        return request.GET(urlString,
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                success(operation, responseObject)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (self.isForbiddenRequest(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_FORBIDDEN_REQUEST)
                } else if (self.isTimedOutError(error)) {
                    failure(AFHTTPRequestOperation(), self.errorForTimedOutError())
                } else if (self.isAppVersionOutdated(error)) {
                    self.sendUserNotification(FlipsServiceResponseCode.BACKEND_APP_VERSION_OUTDATED)
                } else {
                    failure(operation, error)
                }
            }
        )
    }
    
    
    // MARK: - Auxiliary Methods
    
    private func isForbiddenRequest(error: NSError!) -> Bool {
        return (error.localizedDescription.rangeOfString(String(FlipsServiceResponseCode.BACKEND_FORBIDDEN_REQUEST)) != nil)
    }
    
    private func isTimedOutError(error: NSError) -> Bool {
        return (error.description.rangeOfString(BACKEND_TIMED_OUT_MESSAGE) != nil)
    }
    
    private func isAppVersionOutdated(error: NSError!) -> Bool {
        return (error.localizedDescription.rangeOfString(String(FlipsServiceResponseCode.BACKEND_APP_VERSION_OUTDATED)) != nil)
    }

    
    private func errorForTimedOutError() -> NSError {
        let message = NSLocalizedString("The request timed out. Please check your internet connection.")
        return NSError(domain: message, code: FlipsServiceResponseCode.BACKEND_TIMED_OUT, userInfo: ["NSLocalizedDescriptionKey" : message])
    }
    
    private func sendUserNotification(responseCode: Int) {
        var userInfo = [String : Int]()
        userInfo[FlipsServiceResponseCode.RESPONSE_CODE_KEY] = responseCode
        NSNotificationCenter.defaultCenter().postNotificationName(POP_TO_ROOT_NOTIFICATION_NAME, object: nil, userInfo: userInfo)
    }
}