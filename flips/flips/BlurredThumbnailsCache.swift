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

public class BlurredThumbnailsCache: ThumbnailsDataSource {
    
    let cache: StorageCache
    
    private let IMAGE_COMPRESSION: CGFloat = 0.5
    
    public class var sharedInstance : BlurredThumbnailsCache {
        struct Static {
            static let instance : BlurredThumbnailsCache = BlurredThumbnailsCache()
        }
        return Static.instance
    }
    
    init() {
        self.cache = StorageCache(cacheID: "blurredThumbnailsCache", cacheDirectoryName: "blurred_thumbnails_cache", freeSizeInBytes: CacheCleanupPolicy.sharedInstance.freeSizeInBytes)
    }
    
    func get(remoteURL: NSURL, success: StorageCache.CacheSuccessCallback?, failure: StorageCache.CacheFailureCallback?) -> StorageCache.CacheGetResponse {
        if (remoteURL.path == nil || remoteURL.path! == "") {
            return StorageCache.CacheGetResponse.INVALID_URL
        }
        
        if (!self.has(remoteURL)) {
            ThumbnailsCache.sharedInstance.get(remoteURL, success: { (url: String!, path: String!) -> Void in
                if let blurredImagePath: String = self.put(remoteURL, localPath: path) {
                    success?(remoteURL.absoluteString, blurredImagePath)
                } else {
                    // If returned nil is because now it exists in the cache.
                    self.cache.get(remoteURL, success: success, failure: failure)
                }
            }, failure: { (url: String!, flipError: FlipError) -> Void in
                println("Error generating blurred thumbnail: \(flipError)")
            })
            return StorageCache.CacheGetResponse.DOWNLOAD_WILL_START
        }
        
        return self.cache.get(remoteURL, success: success, failure: failure)
    }
    
    func put(remoteURL: NSURL, localPath: String) -> String? {
        if (!self.has(remoteURL)) {
            if let image = UIImage(contentsOfFile: localPath) {
                return self.put(remoteURL, data: self.blurredImageDataFrom(image))
            }
        }
        return nil
    }
    
    func put(remoteURL: NSURL, data: NSData) -> String {
        return self.cache.put(remoteURL, data: data)
    }
    
    func has(remoteURL: NSURL) -> Bool {
        return self.cache.has(remoteURL)
    }

    private func blurredImageDataFrom(image: UIImage) -> NSData {
        let resizedImage: UIImage = image.cropSquareImage(image.size.width / 2)
        let blurredImage: UIImage = resizedImage.applyLightEffect()
        return UIImageJPEGRepresentation(blurredImage, self.IMAGE_COMPRESSION)
    }
}