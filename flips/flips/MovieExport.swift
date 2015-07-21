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
                
                for (index, playerItem) in enumerate(playerItems) {
                    
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
        
        var videoAsset = playerItem.asset as AVAsset?
        var videoAssetTrack = videoAsset!.tracksWithMediaType(AVMediaTypeVideo)[0] as? AVAssetTrack
        
        let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset!.duration)
        
        videoCompositionTrack.insertTimeRange(videoTimeRange,
            ofTrack: videoAssetTrack,
            atTime: insertTime,
            error: nil)
        
        let audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset!.duration)
        
        if videoAsset!.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
            
            let audioAssetTrack = videoAsset!.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack
            
            audioCompositionTrack.insertTimeRange(audioTimeRange,
                ofTrack: audioAssetTrack,
                atTime: insertTime,
                error: nil)
        }
        
        insertTime = CMTimeAdd(insertTime, videoAsset!.duration)
        
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
        let documentsDirectory = paths[0] as! NSString;
        let myPathDocs = documentsDirectory.stringByAppendingPathComponent("flip-\(word)-\(arc4random() % 1000).mov")
        
        let outputFileUrl = NSURL.fileURLWithPath(myPathDocs)
        
        var assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        assetExport.videoComposition = videoComp;
        assetExport.outputFileType = AVFileTypeQuickTimeMovie
        assetExport.outputURL = outputFileUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler()  {
            var status = assetExport.status
            switch (status) {
            case .Failed:
                println("Individual Export Failed: \(word)")
                println("Error: \(assetExport.error.description)")
                println("Error Reason: \(assetExport.error.localizedFailureReason)")
                break
            case .Completed:
                println("Individual Export Completed: \(word)")
                
                self.videoURLs.append(url: outputFileUrl!, order: orderIndex)
                if self.videoURLs.count == totalWords {
                    self.exportAllFlipsInOneVideo(completion)
                }
                break;
            case .Unknown:
                println("Invidual Export Unknown")
                break
            case .Exporting:
                println("Individual Export Exporting")
                break
            case .Waiting:
                println("Individual Export Waiting")
                break
            default:
                println("Individual Export Defaulted")
                break
            }
        }
    }

    private func exportAllFlipsInOneVideo(completion: MovieExportCompletion) {
        
        self.videoURLs.sort{ $0.1 < $1.1 }
        
        var mixComposition = AVMutableComposition()
        var videoCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        var audioCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        
        var insertTime = kCMTimeZero
        
        for videoURL in self.videoURLs {
            
            var videoAsset = AVURLAsset(URL: videoURL.url, options: nil)
            var videoAssetTrack = videoAsset!.tracksWithMediaType(AVMediaTypeVideo)[0] as? AVAssetTrack
            
            let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset!.duration)
            
            videoCompositionTrack.insertTimeRange(videoTimeRange,
                ofTrack: videoAssetTrack,
                atTime: insertTime,
                error: nil)
            
            let audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset!.duration)
            
            if videoAsset!.tracksWithMediaType(AVMediaTypeAudio).count > 0 {
                let audioAssetTrack = videoAsset!.tracksWithMediaType(AVMediaTypeAudio)[0] as! AVAssetTrack
                
                audioCompositionTrack.insertTimeRange(audioTimeRange,
                    ofTrack: audioAssetTrack,
                    atTime: insertTime,
                    error: nil)
            }
            
            insertTime = CMTimeAdd(insertTime, videoAsset!.duration)
        }
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true);
        let documentsDirectory = paths[0] as! NSString;
        let myPathDocs = documentsDirectory.stringByAppendingPathComponent("flip-\(arc4random() % 1000).mov")
        
        let outputFileUrl = NSURL.fileURLWithPath(myPathDocs)
        
        var assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        assetExport.outputFileType = AVFileTypeQuickTimeMovie
        assetExport.outputURL = outputFileUrl
        
        assetExport.exportAsynchronouslyWithCompletionHandler()  {
            var status = assetExport.status
            switch (status) {
            case .Failed:
                println("Export Failed")
                println("Error: \(assetExport.error.localizedDescription)")
                println("Error Reason: \(assetExport.error.localizedFailureReason)")
                break
            case .Completed:
                println("Export Completed")
                self.compositeVideoURL = outputFileUrl!
                
                #if DEV
                self.exportDidFinish(assetExport)
                #endif
                
                self.clearAllIndividualVideosFromLocalStorage()
                
                completion(outputFileUrl, nil)
                
                break;
            case .Unknown:
                println("Export Unknown")
                break
            case .Exporting:
                println("Export Exporting")
                break
            case .Waiting:
                println("Export Waiting")
                break
            default:
                println("Export Defaulted")
                break
            }
        }
    }
    
    //MARK: - Video Mod Functions
    
    private func applyWordToVideo(composition: AVMutableVideoComposition, videoSize: CGSize, word: String) {

        var titleLayer = CATextLayer()
        titleLayer.string = word
        titleLayer.font = UIFont.avenirNextBold(UIFont.HeadingSize.h1)
        titleLayer.foregroundColor = UIColor.whiteColor().CGColor
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.frame = CGRectMake(0, 10, videoSize.width, 100)
        titleLayer.displayIfNeeded()
        
        var watermarkImage = UIImage(named: "Watermark")
        var watermarkLayer = CALayer();
        watermarkLayer.contents = watermarkImage!.CGImage;
        watermarkLayer.frame = CGRectMake(videoSize.width-82, videoSize.height-43, 60, 36)
        watermarkLayer.opacity = 1.0
        
        var gradientImage = UIImage(named: "Filter_Photo")
        var gradientLayer = CALayer();
        gradientLayer.contents = gradientImage!.CGImage;
        gradientLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height)
        gradientLayer.opacity = 1.0
        
        var parentLayer = CALayer()
        var videoLayer = CALayer()
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
            var outputURL = session.outputURL;
            
            var library = ALAssetsLibrary()
            
            if (library.videoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL)) {
                
                library.writeVideoAtPathToSavedPhotosAlbum(outputURL,
                    completionBlock: { (path:NSURL!, error:NSError!) -> Void in
                        
                        if error != nil {
                            
                            if error.code == -3301 {
                                println("Writer was busy, trying to export again...")
                                self.exportDidFinish(session)
                            }
                            else {
                                println("Exporting to library failed: \(error)")
                                println("Error Code: \(error.code)")
                                println("Error Desc: \(error.description)")
                            }
                        }
                        else {
                            println("FINAL EXPORT COMPLETE")
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
            
            if let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true) {
                if paths.count > 0 {
                    if let dirPath = paths[0] as? String {
                        var error : NSErrorPointer = NSErrorPointer()
                        fileManager.removeItemAtPath(fileURL!.path!, error: error)
                        if error != nil {
                            println(error.debugDescription)
                        }
                        else {
                            println("\(fileURL!.path!) deleted successfully")
                        }
                    }
                }
            }
        }

    }

}