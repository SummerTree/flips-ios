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
public typealias GetRoomsSuccessResponse = ([Room]) -> Void
public typealias RoomFailureResponse = (MugError?) -> Void

public class RoomService: MugchatService {

    private let ROOM_URL: String = "/user/{{user_id}}/rooms"
    
    private struct RequestParams {
        static let NAME = "name"
        static let USERS = "users"
        static let PHONE_NUMBERS = "phoneNumbers"
    }

    func createRoom(userIds: [String], contactNumbers: [String], successCompletion: CreateRoomSuccessResponse, failCompletion: RoomFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let createURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: AuthenticationHelper.sharedInstance.userInSession.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
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
    
    func getMyRooms(successCompletion: GetRoomsSuccessResponse, failCompletion: RoomFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let getURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: AuthenticationHelper.sharedInstance.userInSession.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let getRoomsUrl = HOST + getURL

        request.GET(getRoomsUrl, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            successCompletion(self.parseGetRoomsResponse(responseObject))
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            if (operation.responseObject != nil) {
                let response = operation.responseObject as NSDictionary
                failCompletion(MugError(error: response["error"] as String!, details: nil))
            } else {
                failCompletion(MugError(error: error.localizedDescription, details:nil))
            }
        }
    }
    

    private func parseCreateRoomResponse(response: AnyObject) -> Room {
        let json = JSON(response)
        println("created room json: \(json)")
        let roomDataSource = RoomDataSource()
        return roomDataSource.createOrUpdateWithJson(json)
    }
    
    private func parseGetRoomsResponse(response: AnyObject) -> [Room] {
        let json = JSON(response)
        println("created room json: \(json)")
        let roomDataSource = RoomDataSource()
        
        var rooms = Array<Room>()
        
        if let jsonArray = json.array {
            for roomJson in jsonArray {
                var room = roomDataSource.createOrUpdateWithJson(roomJson)
                rooms.append(room)
            }
        }
        
        
        return rooms
    }
}