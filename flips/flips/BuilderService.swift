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

public typealias GetSuggestedWordsSuccessResponse = ([String]) -> Void
public typealias SuggestedWordsFailureResponse = (FlipError?) -> Void

public class BuilderService: FlipsService {
    
    private let SUGGESTED_WORDS_URL: String = "/builderword"
    
    func getSuggestedWords(successCompletion: GetSuggestedWordsSuccessResponse, failCompletion: SuggestedWordsFailureResponse) {
        if (!NetworkReachabilityHelper.sharedInstance.hasInternetConnection()) {
            failCompletion(FlipError(error: LocalizedString.ERROR, details: LocalizedString.NO_INTERNET_CONNECTION))
            return
        }
        
        let getSuggestedWordsUrl = HOST + SUGGESTED_WORDS_URL
        
        self.get(getSuggestedWordsUrl, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            successCompletion(self.parseGetSuggestedWordsResponse(responseObject))
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            if (operation.responseObject != nil) {
                let response = operation.responseObject as NSDictionary
                failCompletion(FlipError(error: response["error"] as String!, details: nil))
            } else {
                failCompletion(FlipError(error: error.localizedDescription, details:nil))
            }
        }
    }
    
    private func parseGetSuggestedWordsResponse(response: AnyObject) -> [String] {
        let json = JSON(response)
        
        var suggestedWords = Array<String>()
        
        if let jsonArray = json.array {
            for suggestedWordJson in jsonArray {
                var suggestedWord = suggestedWordJson["word"].stringValue
                suggestedWords.append(suggestedWord)
            }
        }
        
        return suggestedWords
    }
}
