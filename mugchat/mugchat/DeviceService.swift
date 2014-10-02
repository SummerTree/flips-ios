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

public typealias DeviceServiceSuccessResponse = (Device?) -> Void
public typealias DeviceServiceFailureResponse = (MugError?) -> Void

public class DeviceService: MugchatService {
    
    let CREATE_URL: String = "/user/{{user_id}}/devices"
    let FIND_ONE_URL: String = "/user/{{user_id}}/devices/{{device_id}}"
    let VERIFY_URL: String = "/user/{{user_id}}/devices/{{device_id}}/verify"
    
    public class var sharedInstance : DeviceService {
    struct Static {
        static let instance : DeviceService = DeviceService()
        }
        return Static.instance
    }
    
    
    // MARK: - Create Device
    
    func createDevice(userId: String, phoneNumber: String, platform: String, uuid: String, success: DeviceServiceSuccessResponse, failure: DeviceServiceFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer()
        let createURL = CREATE_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: AuthenticationHelper.sharedInstance.retrieveAuthenticatedUsernameIfExists()!, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let url = HOST + createURL
        let params = [
            RequestParams.PHONE_NUMBER : phoneNumber,
            RequestParams.PLATFORM : platform,
            RequestParams.UUID : uuid]
        
        request.POST(url,
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let device = self.parseCreateResponse(responseObject)
                success(device)
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failure(MugError(error: response["error"] as String!, details:nil))
                } else {
                    failure(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }
    
    func parseCreateResponse(response: AnyObject) -> Device? {
        var device = Device(object: response)
        return device
    }
    
    
    // MARK: - Find a Device
    
    // MARK: - Verify a Device
    
    struct RequestParams {
        static let PHONE_NUMBER = "phoneNumber"
        static let PLATFORM = "platform"
        static let UUID = "uuid"
    }
    
}