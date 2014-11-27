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

// TODO: change form String to entity Word
public typealias GetSuggestedWordsSuccessResponse = ([String]) -> Void
public typealias SuggestedWordsFailureResponse = (MugError?) -> Void

public class BuilderService: MugchatService {
    
    private let SUGGESTED_WORDS_URL: String = "/builderword"
    
    func getSuggestedWords(successCompletion: GetSuggestedWordsSuccessResponse, failCompletion: SuggestedWordsFailureResponse) {
        let request = AFHTTPRequestOperationManager()
        request.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
        let getSuggestedWordsUrl = HOST + SUGGESTED_WORDS_URL
        
        request.GET(getSuggestedWordsUrl, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            successCompletion(self.parseGetSuggestedWordsResponse(responseObject))
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if (operation.responseObject != nil) {
                    let response = operation.responseObject as NSDictionary
                    failCompletion(MugError(error: response["error"] as String!, details: nil))
                } else {
                    failCompletion(MugError(error: error.localizedDescription, details:nil))
                }
        }
    }
    
    // TODO: change from String to entity Word
    private func parseGetSuggestedWordsResponse(response: AnyObject) -> [String] {
        let json = JSON(response)
        println("suggested words json: \(json)")
        
        // TODO: change from String to entity Word
        var suggestedWords = Array<String>()
        
        if let jsonArray = json.array {
            for suggestedWordJson in jsonArray {
                // TODO: parse json info
                var suggestedWord = suggestedWordJson["word"].stringValue
                suggestedWords.append(suggestedWord)
            }
        }
        
        return suggestedWords
    }
}
