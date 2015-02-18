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

public class CacheHandler : NSObject {
    
    let FLIPS_CACHE_FOLDER = "flips_resources"
    let FLIPS_THUMBNAILS_FOLDER = "thumbnails"
    let DEFAULT_JPEG_COMPRESSION_QUALITY: CGFloat = 0.9
    
    var applicationSupportDirectory: String!
    var applicationCacheDirectory: String! // Uses a tmp folder that can be cleaned up by the operation system.
    var thumbnailsDirectory: String!
    
    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : CacheHandler {
        struct Static {
            static let instance : CacheHandler = CacheHandler()
        }
        return Static.instance
    }
    
    
    // MARK: - Initialization Methods
    
    override init() {
        super.init()

        self.initSupportDirectory()
        self.initTemporaryDirectory()
        self.initThumbnailsDirectory()
    }
    
    private func initSupportDirectory() {
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        var applicationSupportDirPath = paths.first! as String
        applicationSupportDirectory = "\(NSHomeDirectory())\(applicationSupportDirPath)/\(FLIPS_CACHE_FOLDER)"
        self.initDirectory(applicationSupportDirectory)
    }
    
    private func initTemporaryDirectory() {
        var cachePaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        var cacheDirPath = cachePaths.first! as String
        applicationCacheDirectory = "\(NSHomeDirectory())\(cacheDirPath)/\(FLIPS_CACHE_FOLDER)"
        println("applicationCacheDirectory: \(applicationCacheDirectory)")
        self.initDirectory(applicationCacheDirectory)
    }
    
    private func initThumbnailsDirectory() {
        thumbnailsDirectory = "\(applicationSupportDirectory)/\(FLIPS_THUMBNAILS_FOLDER)"
        self.initDirectory(thumbnailsDirectory)
    }
    
    private func initDirectory(directoryPath: String) {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = true
        
        if (fileManager.fileExistsAtPath(directoryPath, isDirectory: &isDirectory)) {
            println("Directory exists: \(directoryPath)")
        } else {
            var error: NSError?
            fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: &error)
            if (error != nil) {
                println("Error creating application support dir: \(error)")
            } else {
                println("Directory '\(directoryPath)' created!")
            }
        }
    }
    
    
    // MARK: - Getters
    
    func getFilePathForUrl(url: String, isTemporary: Bool) -> String {
        let formatedUrl = self.getFormatedUrl(url)
        
        var directory: String!
        if (isTemporary) {
            directory = applicationCacheDirectory
        } else {
            directory = applicationSupportDirectory
        }

        let filePath = "\(directory)/\(formatedUrl)"
        return filePath
    }
    
    func getFilePathForUrlFromAnyFolder(url: String) -> String? {
        let fileManager = NSFileManager.defaultManager()
        
        var filePath = self.getFilePathForUrl(url, isTemporary: false)
        if (fileManager.fileExistsAtPath(filePath)) {
            return filePath
        }
        
        filePath = self.getFilePathForUrl(url, isTemporary: true)
        if (fileManager.fileExistsAtPath(filePath)) {
            return filePath
        }
        
        return nil
    }
    
    private func getFormatedUrl(url: String) -> String {
        return url.lastPathComponent
    }
    
    func hasCachedFileForUrl(url:String) -> (hasCache: Bool, filePath: String?, isTemporary: Bool?) {
        var fileExists = false
        var filePath : String?
        var isTemporary: Bool?
        
        let fileManager = NSFileManager.defaultManager()
        let formatedUrl = self.getFormatedUrl(url)
        
        let cacheDirectoryFilePath = "\(applicationCacheDirectory)/\(formatedUrl)"
        if (fileManager.fileExistsAtPath(cacheDirectoryFilePath)) {
            fileExists = true
            filePath = cacheDirectoryFilePath
            isTemporary = true
        }
        
        let supportDirectoryFilePath = "\(applicationSupportDirectory)/\(formatedUrl)"
        if (fileManager.fileExistsAtPath(supportDirectoryFilePath)) {
            fileExists = true
            filePath = supportDirectoryFilePath
            isTemporary = false
        }
        
        return (fileExists, filePath, isTemporary)
    }
    
    
    // MARK: - Save/Load Methods
    
    func saveImage(image: UIImage, withUrl url: String, isTemporary: Bool = true) -> String {
        self.saveThumbnail(image, forUrl: url)
        return self.save(UIImageJPEGRepresentation(image, DEFAULT_JPEG_COMPRESSION_QUALITY), withUrl: url, isTemporary: isTemporary)
    }
    
    func saveDataAtPath(dataPath: String, withUrl url: String, isTemporary: Bool = true) -> String {
        let data = NSData(contentsOfURL: NSURL(fileURLWithPath: dataPath)!)
        return self.save(data!, withUrl: url, isTemporary: isTemporary)
    }
    
    func deleteFileAtPath(path: String) {
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(path)) {
            fileManager.fileExistsAtPath(path)
        }
    }
    
    func deleteFileWithUrl(url: String) {
        var filePath = self.getFilePathForUrl(url, isTemporary: true)
        self.deleteFileAtPath(filePath)

    
        filePath = self.getFilePathForUrl(url, isTemporary: false)
        self.deleteFileAtPath(filePath)
    }
    
    func save(data: NSData, withUrl url: String, isTemporary: Bool = true) -> String {
        var directoryPath: String!
        
        if (isTemporary) {
            directoryPath = applicationCacheDirectory
        } else {
            directoryPath = applicationSupportDirectory
        }
        
        return self.saveData(data, forUrl: url, atDirectoryPath: directoryPath)
    }
    
    func dataForUrl(url: String) -> NSData? {
        let fileManager = NSFileManager.defaultManager()
        
        let formatedUrl = self.getFormatedUrl(url)
        
        let cacheDirectoryFilePath = "\(applicationCacheDirectory)/\(formatedUrl)"
        
        if (fileManager.fileExistsAtPath(cacheDirectoryFilePath)) {
            return fileManager.contentsAtPath(cacheDirectoryFilePath)
        }
        
        let supportDirectoryFilePath = "\(applicationSupportDirectory)/\(formatedUrl)"
        
        if (fileManager.fileExistsAtPath(supportDirectoryFilePath)) {
            return fileManager.contentsAtPath(supportDirectoryFilePath)
        }
        
        return nil
    }
    
    private func saveData(data: NSData, forUrl url: String, atDirectoryPath directoryPath: String) -> String {
        let fileManager = NSFileManager.defaultManager()
        
        let formatedUrl = self.getFormatedUrl(url)
        let filePath = "\(directoryPath)/\(formatedUrl)"

        // DO NOT OVERWRITE
        if (!fileManager.fileExistsAtPath(filePath)) {
            fileManager.createFileAtPath(filePath, contents: data, attributes: nil)
        }
        
        return filePath
    }
    
    
    // MARK: - Thumbnail Save/Load Methods
    
    func saveThumbnail(thumbnail: UIImage, forUrl url: String) {
        let thumbnailPath = url.stringByAppendingPathExtension("jpg")
        self.saveData(UIImageJPEGRepresentation(thumbnail, DEFAULT_JPEG_COMPRESSION_QUALITY), forUrl: thumbnailPath!, atDirectoryPath: thumbnailsDirectory)
    }
    
    func thumbnailForUrl(url: String) -> UIImage? {
        let fileManager = NSFileManager.defaultManager()
        
        let formatedUrl = self.getFormatedUrl(url)
        
        var path = "\(thumbnailsDirectory)/\(formatedUrl)"
        path = path.stringByAppendingPathExtension("jpg")!
        
        if (fileManager.fileExistsAtPath(path)) {
            let data = fileManager.contentsAtPath(path)
            if (data != nil) {
                return UIImage(data: data!)
            }
        }
        
        return nil
    }
}
