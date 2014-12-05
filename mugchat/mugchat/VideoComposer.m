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

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.renderOverlays = YES;
    }

    return self;
}

- (NSURL *)videoFromFlips:(NSArray *)flips
{
    NSArray *messageParts = [self videoPartsFromFlips:flips];
    
    return [self videoJoiningParts:messageParts];
}

- (NSArray *)videoPartsFromFlips:(NSArray *)flips
{
    [self precacheAssetsFromFlips:flips];

    NSMutableArray *messageParts = [NSMutableArray array];

    for (Flip *flip in flips) {
        AVAsset *videoTrack = [self videoFromFlip:flip];

        if (videoTrack) {
            [messageParts addObject:videoTrack];
        }
    }

    return [NSArray arrayWithArray:messageParts];
}

- (UIImage *)thumbnailForVideo:(NSURL *)videoURL
{
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetTrack *videoTrack = [self videoTrackFromAsset:asset];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];

    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];
    CGSize naturalVideoSize = videoTrack.naturalSize;

    UIGraphicsBeginImageContext([self croppedVideoSize:videoTrack]);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextConcatCTM(context, videoTrack.preferredTransform);

    CGFloat xOffset = (croppedVideoSize.width - naturalVideoSize.width) / 2;
    CGFloat yOffset = (croppedVideoSize.height - naturalVideoSize.height) / 2;

    CGContextDrawImage(context, CGRectMake(xOffset, yOffset, naturalVideoSize.width, naturalVideoSize.height), cgImage);

    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return thumbnail;
}

- (void)precacheAssetsFromFlips:(NSArray *)flips
{
    CachingService *cachingService = [CachingService sharedInstance];
    dispatch_group_t cachingGroup = dispatch_group_create();

    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (Flip *flip in flips) {
        // If we're using cached generated videos, do not preload the asset's for the ones that are already done
        NSURL *outputURL = [self videoPartOutputFileURLForFlip:flip];
        if ([fileManager fileExistsAtPath:[outputURL relativePath] isDirectory:nil]) {
            continue;
        }

        if ([flip hasBackground]) {
            dispatch_group_enter(cachingGroup);

            [cachingService cachedFilePathForURL:[NSURL URLWithString:flip.backgroundURL]
                                      completion:^(NSURL *localFileURL) {
                                          dispatch_group_leave(cachingGroup);
                                      }];
        }

        if ([flip hasAudio]) {
            dispatch_group_enter(cachingGroup);

            [cachingService cachedFilePathForURL:[NSURL URLWithString:flip.soundURL]
                                      completion:^(NSURL *localFileURL) {
                                          dispatch_group_leave(cachingGroup);
                                      }];
        }
        

    }

    // Timeout is number of flips times 30 seconds
    dispatch_group_wait(cachingGroup, dispatch_time(DISPATCH_TIME_NOW, flips.count * 30 * NSEC_PER_SEC));
}

- (NSURL *)videoFromFlipMessage:(FlipMessage *)flipMessage
{
    NSMutableArray *messageParts = [NSMutableArray array];

    for (Flip *flip in flipMessage.flips) {
        AVAsset *videoTrack = [self videoFromFlip:flip];

        if (videoTrack) {
            [messageParts addObject:videoTrack];
        }
    }

    return [self videoJoiningParts:messageParts];
}

- (AVAsset *)videoFromFlip:(Flip *)flip {
    __block AVAsset *track;
    
    NSLog(@"flip word: %@", flip.word);
    NSString *word = flip.word;

    dispatch_group_t group = dispatch_group_create();

    // Empty flips doesn't exist
    Flip *flipInContext = [flip MR_inThreadContext];
    if (flipInContext == nil) {
        flipInContext = [Flip MR_createEntity];
        flipInContext.word = word;
    }

    dispatch_group_enter(group);
    [self prepareVideoAssetFromFlip:flipInContext completion:^(BOOL success, AVAsset *videoAsset) {
        if (success) {
            track = videoAsset;
        }
        dispatch_group_leave(group);
    }];

    // Timeout in 5 seconds
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));

    return track;
}


#pragma mark - Private

- (NSURL *)videoJoiningParts:(NSArray *)videoParts
{
    AVMutableComposition *composition = [AVMutableComposition composition];

    CMTime insertionPoint = kCMTimeZero;

    for (AVAsset *videoAsset in videoParts) {
        CMTime trackDuration = videoAsset.duration;

        // should never happen as the videos are recorded with a fixed length of 1 second
        // NOTE: value / timeScale = seconds
        if ((trackDuration.value / trackDuration.timescale) > 1) {
            trackDuration = CMTimeMake(1, 1);
        }

        NSError *error;
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, trackDuration)
                             ofAsset:videoAsset
                              atTime:insertionPoint
                               error:&error];

        if (error) {
            NSLog(@"ERROR ADDING TRACK: %@", error);
        } else {
            insertionPoint = CMTimeAdd(insertionPoint, trackDuration);
        }
    }

    NSURL *outputFolder = [self outputFolderPath];
    __block NSURL *videoUrl = [outputFolder URLByAppendingPathComponent:@"generated-flip-message.mov"]; // TODO: Should get unique ID of flip message to use as filename

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:videoUrl error:nil];
    

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = videoUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusFailed) {
            videoUrl = nil;
            NSLog(@"Could not create video composition.");
        }
        dispatch_group_leave(group);
    }];

    // 20 seconds timeout
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC));
    
    return videoUrl;
}

- (void)prepareVideoAssetFromFlip:(Flip *)flip completion:(void (^)(BOOL success, AVAsset *videoAsset))completion
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *outputURL = [self videoPartOutputFileURLForFlip:flip];
    if ([fileManager fileExistsAtPath:[outputURL relativePath] isDirectory:nil]) {
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:outputURL options:nil];

        if (videoAsset) {
            NSLog(@"Loading generated video from cache for flipID: %@", flip.flipID);
            completion(YES, videoAsset);
            return;
        }
    }

    NSURL *videoURL;
    CacheHandler *cacheHandler = [CacheHandler sharedInstance];

    if ([flip isBackgroundContentTypeVideo]) {
        NSString *filePath = [cacheHandler getFilePathForUrlFromAnyFolder:flip.backgroundURL];
        videoURL = [NSURL fileURLWithPath:filePath];
    } else {
        videoURL = [NSURL fileURLWithPath:[ImageVideoCreator videoPathForFlip:flip]];
    }

    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetTrack *videoTrack = [self videoTrackFromAsset:videoAsset];

    AVMutableComposition *composition;

    if ([flip hasAudio]) {
        NSString *audioPath = [cacheHandler getFilePathForUrlFromAnyFolder:flip.soundURL];
        AVAsset *audioAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
        composition = [self compositionFromVideoAsset:videoAsset audioAsset:audioAsset];
    } else {
        composition = [self compositionFromVideoAsset:videoAsset];
    }
    
    if (!composition) {
        completion(NO, nil);
        return;
    }

    AVMutableVideoComposition *videoComposition = [self videoCompositionFromTrack:videoTrack flip:flip];

    // exporting
    AVAssetExportSession *exportSession;
    exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.videoComposition = videoComposition;
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        if (exportSession.status == AVAssetExportSessionStatusFailed) {
            NSLog(@"Could not create video composition. Error: %@", exportSession.error.description);
            if (completion) {
                completion(NO, nil);
            }

        } else  if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            if (completion) {
                AVAsset *outputAsset = [AVAsset assetWithURL:outputURL];
                completion(YES, outputAsset);
            }
        }
    }];
    
}

- (void)clearTempCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *tempOutputFolder = [self tempOutputFolder];

    if ([fileManager fileExistsAtPath:[tempOutputFolder relativePath] isDirectory:nil]) {
        [fileManager removeItemAtURL:tempOutputFolder error:nil];
    }
}

- (NSURL *)baseOutputFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *outputFolder = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    outputFolder = [outputFolder URLByAppendingPathComponent:@"VideoComposerOutput"];

    return outputFolder;
}

- (NSURL *)tempOutputFolder
{
    return [[self baseOutputFolder] URLByAppendingPathComponent:@"temp"];
}

- (NSURL *)cachedOutputFolder
{
    return [[self baseOutputFolder] URLByAppendingPathComponent:self.cacheKey];
}

- (NSURL *)outputFolderPath
{
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

- (NSURL *)videoPartOutputFileURLForFlip:(Flip *)flip
{
    NSURL *outputFolder = [self outputFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *outputPath;

    if (self.cacheKey) {
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

- (CATextLayer *)layerForText:(NSString *)text
{
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = text;
    titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.font = CGFontCreateWithFontName((CFStringRef)@"AvenirNext-Bold");
    titleLayer.fontSize = 32.0;
    return titleLayer;
}

- (AVAssetTrack *)videoTrackFromAsset:(AVAsset *)asset
{
    return [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
}

- (AVAssetTrack *)audioTrackFromAsset:(AVAsset *)asset
{
    return [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
}

- (CGSize)croppedVideoSize:(AVAssetTrack *)videoTrack
{
    CGFloat squareSide = MIN(videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    CGSize videoSize = CGSizeMake(squareSide, squareSide);

    return videoSize;
}


#pragma mark - Video manipulation

- (CALayer *)squareCroppedVideoLayer:(CALayer *)videoLayer fromTrack:(AVAssetTrack *)videoTrack
{
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];

    videoLayer.frame = CGRectMake(0, 0, croppedVideoSize.width, croppedVideoSize.height);

    return videoLayer;
}

- (CGAffineTransform)transformForVideoSource:(AVAssetTrack *)videoTrack
{
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

- (CGAffineTransform)transformForImageSource
{
    return CGAffineTransformIdentity;
}

- (CALayer *)orientationFixedVideoSourceLayer:(CALayer *)videoLayer fromTrack:(AVAssetTrack *)videoTrack
{
    // NOTE: We only support portrait video capture. Other orientations will look rotated in the final result.

    // Apply preferred transform to account for different front and back camera fixed capture orientations
    CGAffineTransform preferred = videoTrack.preferredTransform;

    // After preferred transform video is upside-down. Flip it vertically.
    CGAffineTransform flip = CGAffineTransformMakeScale(-1, -1);

    videoLayer.affineTransform = CGAffineTransformConcat(preferred, flip);

    return videoLayer;
}

- (CALayer *)orientationFixedImageSourceLayer:(CALayer *)videoLayer fromTrack:(AVAssetTrack *)videoTrack
{
    // NOTE: We only support portrait image capture. Other orientations will look rotated in the final result.

    // Rotate 90 degrees clockwise
    videoLayer.affineTransform = CGAffineTransformMakeRotation(-M_PI_2);

    return videoLayer;
}

- (AVMutableVideoComposition *)videoCompositionFromImage:(UIImage *)image withText:(NSString *)text
{
    CGSize compositionSize = image.size;

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = compositionSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);


    CALayer *imageLayer = [CALayer layer];
    imageLayer.contents = CFBridgingRelease(image.CGImage);
    imageLayer.frame = CGRectMake(0, 0, compositionSize.width, compositionSize.height);

    CATextLayer *wordLayer = [self layerForText:text];
    wordLayer.frame = CGRectMake(0, 50, compositionSize.width, 50);

    [imageLayer addSublayer:wordLayer];
    [wordLayer display];

    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithAdditionalLayer:imageLayer asTrackID:kCMPersistentTrackID_Invalid];

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(30, 30));

    videoComposition.instructions = @[instruction];

    return videoComposition;
}

- (AVMutableVideoComposition *)videoCompositionFromTrack:(AVAssetTrack *)videoTrack flip:(Flip *)flip
{
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = croppedVideoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.asset.duration);

    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    CGAffineTransform transform;
    if ([flip isBackgroundContentTypeVideo]) {
        transform = [self transformForVideoSource:videoTrack];
    } else {
        transform = [self transformForImageSource];
    }

    [layerInstruction setTransform:transform atTime:kCMTimeZero];

    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];

    return videoComposition;
}

- (AVMutableComposition *)compositionFromVideoAsset:(AVAsset *)videoAsset
{
    return [self compositionFromVideoAsset:videoAsset audioAsset:videoAsset];
}

- (AVMutableComposition *)compositionFromVideoAsset:(AVAsset *)videoAsset audioAsset:(AVAsset *)audioAsset
{
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

    AVAssetTrack *audioTrack = [self audioTrackFromAsset:audioAsset];
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

@end
