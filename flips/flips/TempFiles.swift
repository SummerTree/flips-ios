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

class TempFiles : NSObject {
    
    class func tempThumbnailFilePath() -> String {
        return (tempFilesPath() as NSString).stringByAppendingPathComponent(randomFileName("jpg"))
    }
    
    class func tempVideoFilePath() -> String {
        return (tempFilesPath() as NSString).stringByAppendingPathComponent(randomFileName("mov"))
    }
    
    class func tempFilesPath() -> String {
        let tempFilesPath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("flips_files")
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(tempFilesPath, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
        }
        return tempFilesPath
    }
    
    class func randomFileName(fileExtension: String) -> String {
        let randomNumber = String(format:"%i", rand() % 100000)
        let timestamp = String(format:"%f", NSDate().timeIntervalSince1970 * 1000)
        return timestamp + randomNumber + "." + fileExtension
    }
    
    class func clearTempFiles() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(tempFilesPath())
        } catch _ {
        }
    }

}
