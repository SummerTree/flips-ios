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

#import "VideoComposer.h"
#import "Flip.h"
#import "Flips-Swift.h"

#define THUMBNAIL_QUALITY .7

@implementation VideoComposer

- (void)flipVideoFromImage:(UIImage *)image andAudioURL:(NSURL *)audioURL successHandler:(VideoComposerSuccessHandler)successHandler {
    NSString *exportPath = [TempFiles tempVideoFilePath];
    
    if (image) {
        [self createVideoWithImage:image atPath:exportPath completionHandler:^{
            NSURL *videoURL = [NSURL fileURLWithPath:exportPath];
            
            NSString *thumbnailPath = [TempFiles tempThumbnailFilePath];
            NSURL *thumbnailURL = [NSURL fileURLWithPath:thumbnailPath];
            [UIImageJPEGRepresentation(image, THUMBNAIL_QUALITY) writeToFile:thumbnailPath atomically:YES];
            
            if (audioURL) {
                NSString *finalPath = [TempFiles tempVideoFilePath]; // We cannot reuse the same path(exportPath) here. It causes an error on iOS7.
                [self mergeVideo:videoURL withAudio:audioURL atPath:finalPath completionHandler:^{
                    successHandler([NSURL fileURLWithPath:finalPath], thumbnailURL);
                }];
            } else {
                successHandler(videoURL, thumbnailURL);
            }
        }];
    } else {
        NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"empty_video" withExtension:@"mov"];
        
        UIImage *thumbnail = [self thumbnailForVideo:videoURL];
        NSString *thumbnailPath = [TempFiles tempVideoFilePath];
        [UIImageJPEGRepresentation(thumbnail, THUMBNAIL_QUALITY) writeToFile:thumbnailPath atomically:YES];
        
        if (audioURL) {
            [self mergeVideo:videoURL withAudio:audioURL atPath:exportPath completionHandler:^{
                successHandler([NSURL fileURLWithPath:exportPath], [NSURL fileURLWithPath:thumbnailPath]);
            }];
        } else {
            successHandler(videoURL, [NSURL fileURLWithPath:thumbnailPath]);
        }
    }
    
    
}

- (void)flipVideoFromVideo:(NSURL *)originalVideo successHandler:(VideoComposerSuccessHandler)successHandler {
    NSURL *croppedVideo = [self videoFromOriginalVideo:originalVideo];
    
    UIImage *thumbnail = [self thumbnailForVideo:croppedVideo];
    NSString *thumbnailPath = [TempFiles tempThumbnailFilePath];
    [UIImageJPEGRepresentation(thumbnail, THUMBNAIL_QUALITY) writeToFile:thumbnailPath atomically:YES];
    
    successHandler(croppedVideo, [NSURL fileURLWithPath:thumbnailPath]);
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
    __block NSURL *outputURL = [NSURL fileURLWithPath:[TempFiles tempVideoFilePath]];
    
    AVAssetExportSession *exportSession;
    exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
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
    AVAssetTrack * audioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
    AVAssetTrack * videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack * mutableVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime audioDuration = [audioAsset duration];
    CMTime videoDuration = CMTimeConvertScale(audioDuration, videoAsset.duration.timescale, kCMTimeRoundingMethod_Default);
    
    if (CMTimeCompare(videoAsset.duration, videoDuration) > -1)
    {
        // VideoAsset duration is greater than or equal to audio duration
        CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(videoDuration, kCMTimeZero));
        
        NSError * error;
        
        [mutableVideoTrack insertTimeRange:trackTimeRange ofTrack:videoTrack atTime:kCMTimeZero error:&error];
    }
    else
    {
        // VideoAsset duration is less than audio duration
        CMTime videoStart = CMTimeMake(0, videoDuration.timescale);
        
        while(CMTimeCompare(videoStart, videoDuration) < 0)
        {
            double durationDiff = videoDuration.value - videoStart.value;
            
            if (durationDiff > videoAsset.duration.value)
            {
                // This is not the final iteration, add the full duration
                CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
                
                NSError * error;
                
                [mutableVideoTrack insertTimeRange:trackTimeRange ofTrack:videoTrack atTime:videoStart error:&error];
            }
            else
            {
                // This is the final iteration, add up to the end of the video duration
                CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(videoDuration, videoStart));
                
                NSError * error;
                
                [mutableVideoTrack insertTimeRange:trackTimeRange ofTrack:videoTrack atTime:videoStart error:&error];
            }
            
            videoStart = CMTimeAdd(videoStart, videoAsset.duration);
        }

    }
    
    NSError *error;
    
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero error:&error];
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                         presetName:AVAssetExportPresetMediumQuality];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
    }
    
    assetExport.outputFileType = @"com.apple.quicktime-movie";
    assetExport.outputURL = [NSURL fileURLWithPath:destPath];
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void) {
        if (assetExport.status == AVAssetExportSessionStatusFailed) {
            NSLog(@"Could not create video composition. Error: %@", assetExport.error.description);
        }
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
        
        result = [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(1, 2)];
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
