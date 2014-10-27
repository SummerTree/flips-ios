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



public class MugService: MugchatService {

    let CREATE_MUG: String = "/user/{{user_id}}/mugs"
    let UPLOAD_BACKGROUND: String = "/background"
    
    struct RequestParams {
        static let WORD = "word"
        static let BACKGROUND_URL = "background_url"
        static let SOUND_URL = "sound_url"
        static let CATEGORY = "category"
        static let IS_PRIVATE = "is_private"
    }
    
    func createMug(word: String, backgroundPath: NSURL, soundPath: NSURL, category: String = "", isPrivate: Bool = true) {
        // TODO:
    }
    
    private func uploadBackground(backgroundPath: NSURL) -> String {
        // TODO:
        return ""
    }
}