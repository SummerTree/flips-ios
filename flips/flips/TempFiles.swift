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

@objc class TempFiles {
    
    class func tempThumbnailFilePath() -> String {
        return tempFilesPath().stringByAppendingPathComponent(randomFileName("png"))
    }
    
    class func tempVideoFilePath() -> String {
        return tempFilesPath().stringByAppendingPathComponent(randomFileName("mov"))
    }
    
    class func tempFilesPath() -> String {
        let tempFilesPath = NSTemporaryDirectory().stringByAppendingPathComponent("flips_files")
        NSFileManager.defaultManager().createDirectoryAtPath(tempFilesPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        return tempFilesPath
    }
    
    class func randomFileName(fileExtension: String) -> String {
        let randomNumber = String(format:"%i", rand() % 100000)
        let timestamp = String(format:"%f", NSDate().timeIntervalSince1970 * 1000)
        return timestamp + randomNumber + "." + fileExtension
    }
    
    class func clearTempFiles() {
        NSFileManager.defaultManager().removeItemAtPath(tempFilesPath(), error: nil)
    }

}
