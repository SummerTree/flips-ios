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
    
    let MUG_CHAT_CACHE_FOLDER = "mugs_resources"
    let MUG_CHAT_THUMBNAILS_FOLDER = "thumbnails"
    let defaultJPEGCompressionQuality: CGFloat = 0.9
    
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
        applicationSupportDirectory = "\(NSHomeDirectory())\(applicationSupportDirPath)/\(MUG_CHAT_CACHE_FOLDER)"
        self.initDirectory(applicationSupportDirectory)
    }
    
    private func initTemporaryDirectory() {
        var cachePaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        var cacheDirPath = cachePaths.first! as String
        applicationCacheDirectory = "\(NSHomeDirectory())\(cacheDirPath)/\(MUG_CHAT_CACHE_FOLDER)"
        self.initDirectory(applicationCacheDirectory)
    }
    
    private func initThumbnailsDirectory() {
        thumbnailsDirectory = "\(applicationSupportDirectory)/\(MUG_CHAT_THUMBNAILS_FOLDER)"
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
    
    private func getFormatedUrl(url: String) -> String {
        return url.lastPathComponent
    }
    
    func hasCachedFileForUrl(url:String) -> Bool {
        var fileExists = false
        
        let fileManager = NSFileManager.defaultManager()
        let formatedUrl = self.getFormatedUrl(url)
        
        let cacheDirectoryFilePath = "\(applicationCacheDirectory)/\(formatedUrl)"
        if (fileManager.fileExistsAtPath(cacheDirectoryFilePath)) {
            fileExists = true
        }
        
        let supportDirectoryFilePath = "\(applicationSupportDirectory)/\(formatedUrl)"
        if (fileManager.fileExistsAtPath(supportDirectoryFilePath)) {
            fileExists = true
        }
        
        return fileExists
    }
    
    
    // MARK: - Save/Load Methods
    
    func saveImage(image: UIImage, withUrl url: String, isTemporary: Bool = true) -> Bool {
        return self.save(UIImageJPEGRepresentation(image, defaultJPEGCompressionQuality), withUrl: url, isTemporary: isTemporary)
    }
    
    func save(data: NSData, withUrl url: String, isTemporary: Bool = true) -> Bool {
        var directoryPath: String!
        
        if (isTemporary) {
            directoryPath = applicationCacheDirectory
        } else {
            directoryPath = applicationSupportDirectory
        }
        
        self.saveData(data, forUrl: url, atDirectoryPath: directoryPath)
        
        return true
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
    
    private func saveData(data: NSData, forUrl url: String, atDirectoryPath directoryPath: String) {
        let fileManager = NSFileManager.defaultManager()
        
        let formatedUrl = self.getFormatedUrl(url)
        let filePath = "\(directoryPath)/\(formatedUrl)"

        // DO NOT OVERWRITE
        if (!fileManager.fileExistsAtPath(filePath)) {
            fileManager.createFileAtPath(filePath, contents: data, attributes: nil)
        }
    }
    
    
    // MARK: - Thumbnail Save/Load Methods
    
    func saveThumbnail(thumbnail: UIImage, forUrl url: String) {
        self.saveData(UIImageJPEGRepresentation(thumbnail, defaultJPEGCompressionQuality), forUrl: url, atDirectoryPath: thumbnailsDirectory)
    }
    
    func thumbnailForUrl(url: String) -> UIImage? {
        let fileManager = NSFileManager.defaultManager()
        
        let formatedUrl = self.getFormatedUrl(url)
        
        let path = "\(thumbnailsDirectory)/\(formatedUrl)"
        
        if (fileManager.fileExistsAtPath(path)) {
            let data = fileManager.contentsAtPath(path)
            if (data != nil) {
                return UIImage(data: data!)
            }
        }
        
        return nil
    }
}
