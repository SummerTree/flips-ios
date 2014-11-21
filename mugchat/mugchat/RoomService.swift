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

public typealias CreateRoomSuccessResponse = (Room) -> Void
public typealias CreateRoomFailureResponse = (MugError?) -> Void

public class RoomService: MugchatService {

    private let CREATE_ROOM: String = "/user/{{user_id}}/rooms"
    
    private struct RequestParams {
        static let NAME = "name"
        static let USERS = "users"
        static let PHONE_NUMBERS = "phoneNumbers"
    }

    func createRoom(userIds: [String], contactNumbers: [String], successCompletion: CreateRoomSuccessResponse, failCompletion: CreateRoomFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let createURL = CREATE_ROOM.stringByReplacingOccurrencesOfString("{{user_id}}", withString: AuthenticationHelper.sharedInstance.userInSession.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let createRoomUrl = HOST + createURL
        let createRoomParams = [
            RequestParams.NAME : "Name",
            RequestParams.USERS : userIds,
            RequestParams.PHONE_NUMBERS : contactNumbers]

        println("params: \(createRoomParams)")
        println("params descriptions: \(createRoomParams.description)")
        
        request.POST(createRoomUrl,
            parameters: createRoomParams,
            success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                successCompletion(self.parseCreateRoomResponse(responseObject))
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failCompletion(MugError(error: response["error"] as String!, details: nil))
                } else {
                    failCompletion(MugError(error: error.localizedDescription, details:nil))
                }
            }
        )
    }

    private func parseCreateRoomResponse(response: AnyObject) -> Room {
        let json = JSON(response)
        println("created room json: \(json)")
        let roomDataSource = RoomDataSource()
        return roomDataSource.createOrUpdateWithJson(json)
    }
    
}