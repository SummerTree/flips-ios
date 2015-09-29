//
//  MovieExport.swift
//  flips
//
//  Created by Noah Labhart on 6/23/15.
//
//

public typealias MovieExportCompletion = (NSURL?, FlipError?) -> Void

import Foundation
import AVFoundation
import AssetsLibrary

public class MovieExport : NSObject {

    // MARK: - Properties
    
    private var videoURLs : [(url: NSURL, order: Int)] = []
    private var compositeVideoURL : NSURL?
    
    var exportedVideoURL : NSURL? {
        get {
            return self.compositeVideoURL
        }
    }
    
    // MARK: - Singleton
    
    public class var sharedInstance : MovieExport {
        struct Static {
            static let instance : MovieExport = MovieExport()
        }
        return Static.instance
    }

    //MARK: Export Methods
    
    func exportFlipForMMS(playerItems: Array<FlipPlayerItem>, words:[String], completion: MovieExportCompletion) {
        
        if let flipsArray : Array<FlipPlayerItem> = playerItems as Array<FlipPlayerItem>? {
        
            if playerItems.count > 0 {
                self.videoURLs.removeAll(keepCapacity: false)
                
                for (index, playerItem) in playerItems.enumerate() {
                    
                    let isLastItem = (index == playerItems.count)
                    let word = words[index]
                    self.exportIndividualFlipVideo(playerItem, word: word, orderIndex: index, totalWords: words.count, completion: completion)
                }
            }
            else {
                completion(nil, nil)
            }
        }
        else {
            completion(nil, nil)
        }
    }
    
    private func exportIndividualFlipVideo(playerItem: FlipPlayerItem, word: String, orderIndex: Int, totalWords: Int, completion: MovieExportCompletion) {
        
        var mixComposition = AVMutableComposition()
        var videoCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        var audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var insertTime = kCMTimeZero
        
        var videoAsset = playerItem.asset
        var videoAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]
        
        let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        
        do {
            try videoCompositionTrack.insertTimeRange(videoTimeRange,
                ofTrack: videoAssetTrack,
                atTime: insertTime)
        } catch _ {
        }
        
        let audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        
        if videoAsset.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
            
            let audioAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
            
            do {
                try audioCompositionTrack.insertTimeRange(audioTimeRange,
                    ofTrack: audioAssetTrack,
                    atTime: insertTime)
            } catch _ {
            }
        }
        
        insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        
        var videoSize = videoCompositionTrack.naturalSize;
        
        var videoComp = AVMutableVideoComposition(propertiesOfAsset: videoAsset)
        videoComp.renderSize = videoSize;
        videoComp.frameDuration = CMTimeMake(1, 30);
        
        self.applyWordToVideo(videoComp, videoSize: videoSize, word: word)
        
        var layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoCompositionTrack)
        
        var instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
        instruction.layerInstructions = [layerInstruction]
        videoComp.instructions = [instruction];
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true);
        let documentsDirectory = paths[0] as NSString;
        let myPathDocs = documentsDirectory.stringByAppendingPathComponent("flip-\(word)-\(arc4random() % 1000).mov")
        
        let outputFileUrl = NSURL.fileURLWithPath(myPathDocs)
        
        if let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) {
            
            assetExport.videoComposition = videoComp;
            assetExport.outputFileType = AVFileTypeQuickTimeMovie
            assetExport.outputURL = outputFileUrl
            
            assetExport.exportAsynchronouslyWithCompletionHandler()  {
                var status = assetExport.status
                switch (status) {
                case .Failed:
                    print("Individual Export Failed: \(word)")
                    print("Error: \(assetExport.error?.description)")
                    print("Error Reason: \(assetExport.error?.localizedFailureReason)")
                    break
                case .Completed:
                    print("Individual Export Completed: \(word)")
                    
                    self.videoURLs.append(url: outputFileUrl, order: orderIndex)
                    if self.videoURLs.count == totalWords {
                        self.exportAllFlipsInOneVideo(completion)
                    }
                    break;
                case .Unknown:
                    print("Invidual Export Unknown")
                    break
                case .Exporting:
                    print("Individual Export Exporting")
                    break
                case .Waiting:
                    print("Individual Export Waiting")
                    break
                default:
                    print("Individual Export Defaulted")
                    break
                }
            }
            
        }
    }

    private func exportAllFlipsInOneVideo(completion: MovieExportCompletion) {
        
        self.videoURLs.sortInPlace{ $0.1 < $1.1 }
        
        var mixComposition = AVMutableComposition()
        var videoCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        var audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var insertTime = kCMTimeZero
        
        for videoURL in self.videoURLs {
            
            var videoAsset = AVURLAsset(URL: videoURL.url, options: nil)
            var videoAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0]
            
            let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
            
            do {
                try videoCompositionTrack.insertTimeRange(videoTimeRange,
                    ofTrack: videoAssetTrack,
                    atTime: insertTime)
            } catch _ {
            }
            
            let audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
            
            if videoAsset.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
                let audioAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeAudio)[0]
                
                do {
                    try audioCompositionTrack.insertTimeRange(audioTimeRange,
                        ofTrack: audioAssetTrack,
                        atTime: insertTime)
                } catch _ {
                }
            }
            
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true);
        let documentsDirectory = paths[0] as NSString;
        let myPathDocs = documentsDirectory.stringByAppendingPathComponent("flip-\(arc4random() % 1000).mov")
        
        let outputFileUrl = NSURL.fileURLWithPath(myPathDocs)
        
        if let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality) {
            
            assetExport.outputFileType = AVFileTypeQuickTimeMovie
            assetExport.outputURL = outputFileUrl
            
            assetExport.exportAsynchronouslyWithCompletionHandler()  {
                var status = assetExport.status
                switch (status) {
                case .Failed:
                    print("Export Failed")
                    print("Error: \(assetExport.error?.localizedDescription)")
                    print("Error Reason: \(assetExport.error?.localizedFailureReason)")
                    break
                case .Completed:
                    print("Export Completed")
                    self.compositeVideoURL = outputFileUrl
                    
                    #if DEV
                    self.exportDidFinish(assetExport)
                    #endif
                    
                    self.clearAllIndividualVideosFromLocalStorage()
                    
                    completion(outputFileUrl, nil)
                    
                    break;
                case .Unknown:
                    print("Export Unknown")
                    break
                case .Exporting:
                    print("Export Exporting")
                    break
                case .Waiting:
                    print("Export Waiting")
                    break
                default:
                    print("Export Defaulted")
                    break
                }
            }
            
        }
    }
    
    //MARK: - Video Mod Functions
    
    private func applyWordToVideo(composition: AVMutableVideoComposition, videoSize: CGSize, word: String) {

        let titleLayer = CATextLayer()
        titleLayer.string = word
        titleLayer.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        titleLayer.foregroundColor = UIColor.whiteColor().CGColor
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRectMake(0, 10, videoSize.width, 100)
        titleLayer.displayIfNeeded()
        
        let watermarkImage = UIImage(named: "Watermark")
        let watermarkLayer = CALayer();
        watermarkLayer.contents = watermarkImage!.CGImage;
        watermarkLayer.frame = CGRectMake(videoSize.width-82, videoSize.height-43, 60, 36)
        watermarkLayer.opacity = 1.0
        
        let gradientImage = UIImage(named: "Filter_Photo")
        let gradientLayer = CALayer();
        gradientLayer.contents = gradientImage!.CGImage;
        gradientLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        gradientLayer.opacity = 1.0
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(gradientLayer)
        parentLayer.addSublayer(titleLayer)
        parentLayer.addSublayer(watermarkLayer)
        
        composition.animationTool =
            AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
    }
    
    //MARK: - Save to Local Photos
    
    private func exportDidFinish(session: AVAssetExportSession) {
        
        if (session.status == .Completed) {
            let outputURL = session.outputURL;
            
            let library = ALAssetsLibrary()
            
            if (library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL)) {
                
                library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                    completionBlock: { (path:NSURL!, error:NSError!) -> Void in
                        
                        if error != nil {
                            
                            if error.code == -3301 {
                                print("Writer was busy, trying to export again...")
                                self.exportDidFinish(session)
                            }
                            else {
                                print("Exporting to library failed: \(error)")
                                print("Error Code: \(error.code)")
                                print("Error Desc: \(error.description)")
                            }
                        }
                        else {
                            print("FINAL EXPORT COMPLETE")
                            self.clearAllIndividualVideosFromLocalStorage()
                        }
                })
            }
        }
    }
    
    //MARK: - Cleanup Local Files
    
    private func clearAllIndividualVideosFromLocalStorage() {
        for videoURL in self.videoURLs {
            self.clearVideoFromLocalStorage(videoURL.url)
        }
    }
    
    func clearExportedFlipVideoFromLocalStorage() {
        self.clearVideoFromLocalStorage(self.compositeVideoURL)
    }
    
    func clearVideoFromLocalStorage(fileURL: NSURL?) {
        
        if (fileURL != nil) {
            var fileManager : NSFileManager = NSFileManager.defaultManager()
            let nsDocumentDirectory = NSSearchPathDirectory.DocumentDirectory
            let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
            
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            if paths.count > 0 {
                if let dirPath = paths[0] as? String {
                    var error : NSErrorPointer = NSErrorPointer()
                    do {
                        try fileManager.removeItemAtPath(fileURL!.path!)
                    } catch var error1 as NSError {
                        error.memory = error1
                    }
                    if error != nil {
                        print(error.debugDescription)
                    }
                    else {
                        print("\(fileURL!.path!) deleted successfully")
                    }
                }
            }
        }

    }

}