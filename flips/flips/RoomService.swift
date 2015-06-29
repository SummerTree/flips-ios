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
			failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        if let loggedUser = User.loggedUser() {
            let createURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let createRoomUrl = HOST + createURL
            let createRoomParams = [
                RequestParams.NAME : "Name",
                RequestParams.USERS : userIds,
                RequestParams.PHONE_NUMBERS : contactNumbers]
            
            println("params: \(createRoomParams)")
            println("params descriptions: \(createRoomParams.description)")
            
            self.post(createRoomUrl,
                parameters: createRoomParams,
                success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    successCompletion(self.parseCreateRoomResponse(responseObject))
                },
                failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        failCompletion(FlipError(error: response["error"] as? String, details: nil))
                    } else {
                        failCompletion(FlipError(error: error.localizedDescription, details: nil))
                    }
                }
            )
        }
    }
    
    func getMyRooms(successCompletion: GetRoomsSuccessResponse, failCompletion: RoomFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
			failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        if let loggedUser = User.loggedUser() {
            
            let getURL = ROOM_URL.stringByReplacingOccurrencesOfString("{{user_id}}", withString: loggedUser.userID, options: NSStringCompareOptions.LiteralSearch, range: nil)
            let getRoomsUrl = HOST + getURL
            
            self.get(getRoomsUrl, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                successCompletion(self.parseGetRoomsResponse(responseObject))
                }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    if (operation.responseObject != nil) {
                        let response = operation.responseObject as! NSDictionary
                        failCompletion(FlipError(error: response["error"] as? String, details: nil))
                    } else {
                        failCompletion(FlipError(error: error.localizedDescription, details: nil))
                    }
            }
        }
    }
    

    private func parseCreateRoomResponse(response: AnyObject) -> Room {
        let json = JSON(response)
        return PersistentManager.sharedInstance.createRoomWithJson(json)
    }
    
    private func parseGetRoomsResponse(response: AnyObject) -> [Room] {
        let json = JSON(response)
        var rooms = Array<Room>()
        
        if let jsonArray = json.array {
            for roomJson in jsonArray {
                var room = PersistentManager.sharedInstance.createRoomWithJson(roomJson)
                rooms.append(room)
            }
        }
        
        return rooms
    }
}