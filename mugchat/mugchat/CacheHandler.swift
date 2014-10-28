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
    let defaultJPEGCompressionQuality: CGFloat = 0.9
    
    var applicationSupportDirectory: String!
    var applicationCacheDirectory: String! // Uses a tmp folder that can be cleaned up by the operation system.
    
    var temporaryCache: NSCache! // is the same that is being used by AFNetworking

    
    // MARK: - Singleton Implementation
    
    public class var sharedInstance : CacheHandler {
    struct Static {
        static let instance : CacheHandler = CacheHandler()
        }
        Static.instance.initCache()
        return Static.instance
    }
    
    
    // MARK: - Initialization Methods
    
    private func initCache() {
        var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        var applicationSupportDirPath = paths.first! as String
        applicationSupportDirectory = "\(NSHomeDirectory())\(applicationSupportDirPath)/\(MUG_CHAT_CACHE_FOLDER))"
        
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = true
        
        println("   ")
        
        if (fileManager.fileExistsAtPath(applicationSupportDirectory, isDirectory: &isDirectory)) {
            println("Application Support Directory exists")
        } else {
            var error: NSError?
            fileManager.createDirectoryAtPath(applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil, error: &error)
            if (error != nil) {
                println("Error creating application support dir: \(error)")
            } else {
                println("Directory '\(applicationSupportDirectory)' created!")
            }
        }
        
        var cachePaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.LocalDomainMask, true)
        var cacheDirPath = cachePaths.first! as String
        applicationCacheDirectory = "\(NSHomeDirectory())\(cacheDirPath)/\(MUG_CHAT_CACHE_FOLDER))"
        
        if (fileManager.fileExistsAtPath(applicationCacheDirectory, isDirectory: &isDirectory)) {
            println("Application Cache Directory exists")
        } else {
            var error: NSError?
            fileManager.createDirectoryAtPath(applicationCacheDirectory, withIntermediateDirectories: true, attributes: nil, error: &error)
            if (error != nil) {
                println("Error creating cache dir: \(error)")
            } else {
                println("Directory '\(applicationCacheDirectory)' created!")
            }
        }
        
        temporaryCache = NSCache()
        
        println("   ")
    }
    
    
    // MARK: - Getters
    
    func getFilePathForUrl(url: String, isTemporary: Bool) -> String {
        // For now we will only full cache
        let filePath = "\(applicationSupportDirectory)/\(url)"
        return filePath
    }
    
    func hasCachedFileForUrl(url:String) -> Bool {
        var fileExists = false
        
        if (self.temporaryCache.objectForKey(url) != nil) {
            fileExists = true
        } else {
            let fileManager = NSFileManager.defaultManager()
            let filePath = "\(applicationSupportDirectory)/\(url)"
            if (fileManager.fileExistsAtPath(filePath)) {
                fileExists = true
            }
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
    
    func getDataForUrl(url: String) -> NSData? {
        if (self.temporaryCache.objectForKey(url) != nil) {
            return self.temporaryCache.objectForKey(url) as NSData?
        } else {
            // Get from private cache
            return self.loadDataForUrl(url)
        }
    }
    
    private func saveData(data: NSData, forUrl url: String, atDirectoryPath directoryPath: String) {
        let fileManager = NSFileManager.defaultManager()
        
        let filePath = "\(directoryPath)/\(url)"
        println("saveData - filePath: \(filePath)")

        // DO NOT OVERWRITE
        if (!fileManager.fileExistsAtPath(filePath)) {
            fileManager.createFileAtPath(filePath, contents: data, attributes: nil)
        }
    }
    
    private func loadDataForUrl(url: String) -> NSData? {
        let fileManager = NSFileManager.defaultManager()
        
        let cacheDirectoryFilePath = "\(applicationCacheDirectory)/\(url)"
        println("loadData - supportDirectoryFilePath: \(cacheDirectoryFilePath)")
        
        if (fileManager.fileExistsAtPath(cacheDirectoryFilePath)) {
            return fileManager.contentsAtPath(cacheDirectoryFilePath)
        }

        let supportDirectoryFilePath = "\(applicationSupportDirectory)/\(url)"
        println("loadData - supportDirectoryFilePath: \(supportDirectoryFilePath)")
        
        if (fileManager.fileExistsAtPath(supportDirectoryFilePath)) {
            return fileManager.contentsAtPath(supportDirectoryFilePath)
        }
        
        return nil
    }
}
