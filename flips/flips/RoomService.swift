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
public typealias RoomFailureResponse = (FlipError?) -> Void

public class RoomService: FlipsService {

    private let ROOM_URL: String = "/user/{{user_id}}/rooms"
    
    private struct RequestParams {
        static let NAME = "name"
        static let USERS = "users"
        static let PHONE_NUMBERS = "phoneNumbers"
    }

    func createRoom(userIds: [String], contactNumbers: [String], successCompletion: CreateRoomSuccessResponse, failCompletion: RoomFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
			failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let createURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: User.loggedUser()!.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
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
				let code = self.parseResponseError(error)
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
					failCompletion(FlipError(error: response["error"] as String!, details : nil, code: code))
                } else {
					failCompletion(FlipError(error: error.localizedDescription, details : nil, code: code))
                }
            }
        )
    }
    
    func getMyRooms(successCompletion: GetRoomsSuccessResponse, failCompletion: RoomFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
			failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION, code: FlipError.NO_CODE))
            return
        }
        
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let getURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: User.loggedUser()!.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
        let getRoomsUrl = HOST + getURL

        request.GET(getRoomsUrl, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            successCompletion(self.parseGetRoomsResponse(responseObject))
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
			let code = self.parseResponseError(error)
            if (operation.responseObject != nil) {
                let response = operation.responseObject as NSDictionary
				failCompletion(FlipError(error: response["error"] as String!, details : nil, code: code))
            } else {
				failCompletion(FlipError(error: error.localizedDescription, details : nil, code: code))
            }
        }
    }
    

    private func parseCreateRoomResponse(response: AnyObject) -> Room {
        let json = JSON(response)
        return PersistentManager.sharedInstance.createOrUpdateRoomWithJson(json)
    }
    
    private func parseGetRoomsResponse(response: AnyObject) -> [Room] {
        let json = JSON(response)
        var rooms = Array<Room>()
        
        if let jsonArray = json.array {
            for roomJson in jsonArray {
                var room = PersistentManager.sharedInstance.createOrUpdateRoomWithJson(roomJson)
                rooms.append(room)
            }
        }
        
        return rooms
    }
}