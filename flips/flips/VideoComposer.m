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

#import "VideoComposer.h"
#import "Flip.h"
#import "Flips-Swift.h"

@implementation VideoComposer

- (void)flipVideoFromImage:(UIImage *)image andAudioURL:(NSURL *)audioURL successHandler:(VideoComposerSuccessHandler)successHandler errorHandler:(VideoComposerErrorHandler)errorHandler {
    // TODO define video URL and how it'll be added to the cache
    
    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"export.mov"];
    
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mov"];
    [self createVideoWithImage:image atPath:videoPath completionHandler:^{
        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
        
        NSString *thumbnailPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"thumbnail.png"];
        NSURL *thumbnailURL = [NSURL fileURLWithPath:thumbnailPath];
        [UIImagePNGRepresentation(image) writeToFile:thumbnailPath atomically:YES];
        
        if (audioURL) {
            [self mergeVideo:videoURL withAudio:audioURL atPath:exportPath completionHandler:^{
                successHandler([NSURL fileURLWithPath:exportPath], thumbnailURL);
            }];
        } else {
            successHandler(videoURL, thumbnailURL);
        }
    }];
}

- (void)flipVideoFromVideo:(NSURL *)originalVideo successHandler:(VideoComposerSuccessHandler)successHandler errorHandler:(VideoComposerErrorHandler)errorHandler {
    NSURL *croppedVideo = [self videoFromOriginalVideo:originalVideo];
    
    // TODO define thumbnail URL and how it'll be added to the cache
    UIImage *thumbnail = [self thumbnailForVideo:croppedVideo];
    NSString *thumbnailPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"thumbnail.png"];
    [UIImagePNGRepresentation(thumbnail) writeToFile:thumbnailPath atomically:YES];
    
    successHandler(croppedVideo, [NSURL fileURLWithPath:thumbnailPath]);
}

- (NSArray *)videoAssetsForFlips:(NSArray *)flips {
    CacheHandler *cacheHandler = [CacheHandler sharedInstance];
    NSMutableArray *messageParts = [NSMutableArray array];
    
    for (Flip *flip in flips) {
        NSString *filePath = [cacheHandler getFilePathForUrlFromAnyFolder:flip.backgroundURL];
        NSURL *videoURL = [NSURL fileURLWithPath:filePath];
        AVURLAsset *videoTrack = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        
        if (videoTrack) {
            [messageParts addObject:videoTrack];
        }
    }
    
    return [NSArray arrayWithArray:messageParts];
}

- (UIImage *)thumbnailForVideo:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetTrack *videoTrack = [self videoTrackFromAsset:asset];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
    
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];
    CGSize naturalVideoSize = videoTrack.naturalSize;
    
    NSAssert(!CGSizeEqualToSize(croppedVideoSize, CGSizeZero), @"Crop size is zero!");
    
    UIGraphicsBeginImageContext(croppedVideoSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGAffineTransform center = CGAffineTransformMakeTranslation(0.0, -croppedVideoSize.height);
    CGAffineTransform mirror = CGAffineTransformMakeScale(1.0, -1.0);
    
    CGContextConcatCTM(context, videoTrack.preferredTransform);
    CGContextConcatCTM(context, mirror);
    CGContextConcatCTM(context, center);
    
    CGFloat xOffset = (croppedVideoSize.width - naturalVideoSize.width) / 2;
    CGFloat yOffset = (croppedVideoSize.height - naturalVideoSize.height) / 2;
    
    CGContextDrawImage(context, CGRectMake(xOffset, yOffset, naturalVideoSize.width, naturalVideoSize.height), cgImage);
    
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

- (NSURL *)videoFromOriginalVideo:(NSURL *)videoURL {
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetTrack *videoTrack = [self videoTrackFromAsset:videoAsset];
    
    AVMutableComposition *composition = [self compositionFromVideoAsset:videoAsset];
    
    if (!composition) {
        return nil;
    }
    
    AVMutableVideoComposition *videoComposition = [self videoCompositionFromTrack:videoTrack];
    
    // exporting
    __block NSURL *outputURL = [self videoPartOutputFileURLForFlip:nil];
    
    AVAssetExportSession *exportSession;
    exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.videoComposition = videoComposition;
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        if (exportSession.status == AVAssetExportSessionStatusFailed) {
            NSLog(@"Could not create video composition. Error: %@", exportSession.error.description);
            outputURL = nil;
            dispatch_group_leave(group);
        } else if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            dispatch_group_leave(group);
        }
    }];
    
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC));
    
    return outputURL;
}

#pragma mark - Private

- (void)clearTempCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *tempOutputFolder = [self tempOutputFolder];
    
    if ([fileManager fileExistsAtPath:[tempOutputFolder relativePath] isDirectory:nil]) {
        [fileManager removeItemAtURL:tempOutputFolder error:nil];
    }
}

- (NSURL *)baseOutputFolder {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *outputFolder = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    outputFolder = [outputFolder URLByAppendingPathComponent:@"VideoComposerOutput"];
    
    return outputFolder;
}

- (NSURL *)tempOutputFolder {
    return [[self baseOutputFolder] URLByAppendingPathComponent:@"temp"];
}

- (NSURL *)cachedOutputFolder {
    return [[self baseOutputFolder] URLByAppendingPathComponent:self.cacheKey];
}

- (NSURL *)outputFolderPath {
    NSURL *outputFolder;
    
    if (self.cacheKey) {
        outputFolder = [self cachedOutputFolder];
    } else {
        outputFolder = [self tempOutputFolder];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[outputFolder relativePath] isDirectory:nil]) {
        [fileManager createDirectoryAtPath:[outputFolder relativePath]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    return outputFolder;
}

- (NSURL *)videoPartOutputFileURLForFlip:(Flip *)flip {
    NSURL *outputFolder = [self outputFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *outputPath;
    
    if (self.cacheKey && flip != nil) {
        NSString *filename = [NSString stringWithFormat:@"flip-video-%@.mov", flip.flipID];
        outputPath = [outputFolder URLByAppendingPathComponent:filename];
    } else {
        NSUInteger index = 0;
        
        do {
            index++;
            NSString *filename = [NSString stringWithFormat:@"flip-video-%lu.mov", (unsigned long)index];
            outputPath = [outputFolder URLByAppendingPathComponent:filename];
        } while ([fileManager fileExistsAtPath:[outputPath relativePath] isDirectory:nil]);
    }
    
    return outputPath;
}

- (AVAssetTrack *)videoTrackFromAsset:(AVAsset *)asset {
    return [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
}

- (AVAssetTrack *)audioTrackFromAsset:(AVAsset *)asset {
    return [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
}

- (CGSize)croppedVideoSize:(AVAssetTrack *)videoTrack {
    CGFloat squareSide = MIN(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    CGSize videoSize = CGSizeMake(squareSide, squareSide);
    return videoSize;
}

#pragma mark - Video manipulation

- (CGAffineTransform)transformForVideoSource:(AVAssetTrack *)videoTrack {
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];
    
    CGSize naturalVideoSize = videoTrack.naturalSize;
    
    CGFloat xOffset = (croppedVideoSize.width - naturalVideoSize.width) / 2;
    CGFloat yOffset = (croppedVideoSize.height - naturalVideoSize.height) / 2;
    
    // Apply preferred transform to account for different front and back camera fixed capture orientations
    CGAffineTransform preferred = videoTrack.preferredTransform;
    
    // Crop to the center of the video
    CGAffineTransform centerCrop = CGAffineTransformMakeTranslation(yOffset, xOffset);
    
    return CGAffineTransformConcat(preferred, centerCrop);
}

- (AVMutableVideoComposition *)videoCompositionFromTrack:(AVAssetTrack *)videoTrack {
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = croppedVideoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.asset.duration);
    
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    CGAffineTransform transform = [self transformForVideoSource:videoTrack];
    
    [layerInstruction setTransform:transform atTime:kCMTimeZero];
    
    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];
    
    return videoComposition;
}

- (AVMutableComposition *)compositionFromVideoAsset:(AVAsset *)videoAsset {
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTime compositionDuration = videoAsset.duration; // Use video length
    NSError *error;
    
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, compositionDuration)
                                   ofTrack:[self videoTrackFromAsset:videoAsset]
                                    atTime:kCMTimeZero
                                     error:&error];
    
    if (error) {
        NSLog(@"Could not insert video track: %@", error.localizedDescription);
        return nil;
    }
    
    AVAssetTrack *audioTrack = [self audioTrackFromAsset:videoAsset];
    if (audioTrack) {
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                    preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, compositionDuration)
                                       ofTrack:audioTrack
                                        atTime:kCMTimeZero
                                         error:&error];
        
        if (error) {
            NSLog(@"Could not insert audio track: %@", error.localizedDescription);
            return nil;
        }
    }
    
    return composition;
}

- (void)mergeVideo:(NSURL *)videoURL withAudio:(NSURL *)audioURL atPath:(NSString *)destPath completionHandler:(void (^)())completionHandler {
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:audioURL];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration)
                                   ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    
    if ([videoTracks count] > 0) {
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:[videoTracks objectAtIndex:0]
                                        atTime:kCMTimeZero error:nil];
    }
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetHighestQuality];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
    }
    
    assetExport.outputFileType = @"com.apple.quicktime-movie";
    assetExport.outputURL = [NSURL fileURLWithPath:destPath];
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void) {
        completionHandler();
    }];
}

- (void)createVideoWithImage:(UIImage *)image atPath:(NSString *)path completionHandler:(void (^)())completionHandler {
    if (image == nil) {
        NSLog(@"Image is nil, it shouldn't happen.");
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if (error) {
        NSLog(@"error creating AssetWriter: %@", [error description]);
    }
    
    CGSize frameSize;
    if (image) {
        frameSize = image.size;
    } else {
        frameSize = CGSizeMake(1, 1);
    }
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput *writerVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString *)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString *)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerVideoInput
                                                     sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerVideoInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    if (image) {
        CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[image CGImage]];
        
        BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
        if (result == NO) {
            NSLog(@"failed to append buffer");
        }
        
        if (buffer) {
            CVBufferRelease(buffer);
        }
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    //Finish the session:
    [writerVideoInput markAsFinished];
    dispatch_group_enter(group);
    [videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"Finished writing video");
        dispatch_group_leave(group);
        completionHandler();
    }];
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image), CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options, &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 CGImageGetWidth(image),
                                                 CGImageGetHeight(image),
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
