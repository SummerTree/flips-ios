//
//  VideoLibrary.swift
//  InMatch
//
//  Created by Noah Labhart on 3/9/16.
//  Copyright © 2016 Applico. All rights reserved.
//

import Photos

class CameraLibrary: NSObject {

    static let sharedInstance = CameraLibrary()
    
    var videoAssets: PHFetchResult!
    var assetThumbnailSize:CGSize!
    
    let albumTitle = ""
    
    func saveVideo(videoURL: NSURL) {
        
        if #available(iOS 9.0, *) {
//            let assetCollection = self.fetchAssetCollectionForAlbum(albumTitle)
//            if assetCollection == nil {
//                self.createAlbum(albumTitle, completion: { (collection) -> Void in
//                    self.saveVideo(videoURL)
//                })
//                return
//            }
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
//                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)!
//                let assetPlaceholder = assetRequest.placeholderForCreatedAsset
//                self.videoAssets = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: nil)
//                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetCollection, assets: self.videoAssets)
//                albumChangeRequest!.addAssets([assetPlaceholder!])
                PHAssetCreationRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
                }) { (success, error) -> Void in
                    if success {
                        print("Video saved to camera roll.")
                    }
                    else {
                        print("Error saving video to camera roll: \(error?.description)")
                    }
            }
        }
        else {
            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath!, nil, nil, nil)
        }
    }
    
    func fetchAssetCollectionForAlbum(title: String) -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", title)
        let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    func createAlbum(title: String, completion: PHAssetCollection? -> Void) {
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(title)
            }) { success, error in
                if success {
                    let collection = self.fetchAssetCollectionForAlbum(title)
                    completion(collection)
                } else {
                    print("error \(error)")
                    completion(nil)
                }
        }
    }
    
    func isAuthorized() -> Bool {
        switch PHPhotoLibrary.authorizationStatus() {
            case .Authorized:
                return true
            case .NotDetermined:
                return true
            case .Restricted:
                return false
            case .Denied:
                return false
        }
    }
    
    func requestAuthorization(completion: PHAuthorizationStatus -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            completion(status)
        }
    }
    
}