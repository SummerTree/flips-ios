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
#import "Mug.h"
#import <CoreData+MagicalRecord.h>

#import "Flips-Swift.h"

@implementation VideoComposer


- (void)testCreatingFourWordsVideo
{
    NSURL *docsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];

    NSEntityDescription *messageDescription = [NSEntityDescription entityForName:@"MugMessage" inManagedObjectContext:moc];
    NSEntityDescription *mugDescription = [NSEntityDescription entityForName:@"Mug" inManagedObjectContext:moc];

    MugMessage *message = [[MugMessage alloc] initWithEntity:messageDescription insertIntoManagedObjectContext:moc];

    Mug *mugOne = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugOne.mugID = @"id_one";
    mugOne.word = @"One";
    mugOne.backgroundContentType = @(2);
    mugOne.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-1.mov"] absoluteString];
    [message addMug:mugOne];

    Mug *mugTwo = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugTwo.mugID = @"id_two";
    mugTwo.word = @"Two";
    mugTwo.backgroundContentType = @(2);
    mugTwo.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2.mov"] absoluteString];
    [message addMug:mugTwo];

    Mug *mugThree = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugThree.mugID = @"id_three";
    mugThree.word = @"Three";
    mugThree.backgroundContentType = @(1);
//    mugThree.backgroundURL = @"https://mugchat-background.s3.amazonaws.com/c1ea1077-95ff-471c-abb3-c21205f53fff.jpg";
    mugThree.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-3.jpg"] absoluteString];
    mugThree.soundURL = [[docsDir URLByAppendingPathComponent:@"recording-3.m4a"] absoluteString];
    [message addMug:mugThree];

    Mug *mugFour = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugFour.mugID = @"id_four";
    mugFour.word = @"Four";
    mugFour.backgroundContentType = @(2);
    mugFour.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-4.mov"] absoluteString];
    [message addMug:mugFour];

    Mug *mugFive = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugFive.mugID = @"id_five";
    mugFive.word = @"Five";
    mugFive.backgroundContentType = @(1);
//    mugFive.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-5.jpg"] absoluteString];
    [message addMug:mugFive];

    NSLog(@"GENERATED VIDEO URL: %@", [self videoFromMugMessage:message]);

    [moc rollback];
}



- (NSURL *)videoFromMugs:(NSArray *)mugs
{
    NSMutableArray *messageParts = [NSMutableArray array];
    
    for (Mug *mug in mugs) {
        AVAsset *videoTrack = [self videoFromMug:mug];
        
        if (videoTrack) {
            [messageParts addObject:videoTrack];
        }
    }
    
    return [self videoJoiningParts:messageParts];
}

- (NSURL *)videoFromMugMessage:(MugMessage *)mugMessage
{
    NSMutableArray *messageParts = [NSMutableArray array];

    for (Mug *mug in mugMessage.mugs) {
        AVAsset *videoTrack = [self videoFromMug:mug];

        if (videoTrack) {
            [messageParts addObject:videoTrack];
        }
    }

    return [self videoJoiningParts:messageParts];
}

- (AVAsset *)videoFromMug:(Mug *)flip {
    __block AVAsset *track;
    
    NSLog(@"flip word: %@", flip.word);
    NSString *word = flip.word;

    dispatch_group_t group = dispatch_group_create();

    // Empty mugs doesn't exist
    Mug *flipInContext = [flip MR_inThreadContext];
    if (flipInContext == nil) {
        flipInContext = [Mug MR_createEntity];
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
    __block NSURL *videoUrl = [outputFolder URLByAppendingPathComponent:@"generated-mug-message.mov"]; // TODO: Should get unique ID of mug message to use as filename

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

- (void)prepareVideoAssetFromFlip:(Mug *)flip completion:(void (^)(BOOL success, AVAsset *videoAsset))completion
{
    NSURL *videoURL;

    if ([flip isBackgroundContentTypeVideo]) {
        //    NSString *backgroundContentLocalPath = [mug backgroundContentLocalPath];
        videoURL = [NSURL URLWithString:flip.backgroundURL];
    } else {
        videoURL = [NSURL fileURLWithPath:[ImageVideoCreator videoPathForMug:flip]];
    }

    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    AVAssetTrack *videoTrack = [self videoTrackFromAsset:videoAsset];

    AVMutableComposition *composition;

    if (flip.soundURL) {
        AVAsset *audioAsset = [AVAsset assetWithURL:[NSURL URLWithString:flip.soundURL]];
        composition = [self compositionFromVideoAsset:videoAsset audioAsset:audioAsset];
    } else {
        composition = [self compositionFromVideoAsset:videoAsset];
    }

    AVMutableVideoComposition *videoComposition = [self videoCompositionFromTrack:videoTrack withText:flip.word];

    NSURL *outputURL = [self tempOutputFileURL];

    /// exporting
    AVAssetExportSession *exportSession;
    exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.videoComposition = videoComposition;
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        if (exportSession.status == AVAssetExportSessionStatusFailed) {
            NSLog(@"Could not create video composition.");
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

- (NSURL *)outputFolderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *outputFolder = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    outputFolder = [outputFolder URLByAppendingPathComponent:@"VideoComposerOutput"];

    if (![fileManager fileExistsAtPath:[outputFolder relativePath] isDirectory:nil]) {
        [fileManager createDirectoryAtPath:[outputFolder relativePath]
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }

    return outputFolder;
}

- (NSURL *)tempOutputFileURL
{
    NSURL *outputFolder = [self outputFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSUInteger index = 0;
    NSURL *outputPath;

    do {
        index++;
        NSString *filename = [NSString stringWithFormat:@"temp-flip-%lu.mov", (unsigned long)index];
        outputPath = [outputFolder URLByAppendingPathComponent:filename];
    } while ([fileManager fileExistsAtPath:[outputPath relativePath] isDirectory:nil]);

    return outputPath;
}

- (UIInterfaceOrientation)orientationForTrack:(AVAssetTrack *)videoTrack
{
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform transform = [videoTrack preferredTransform];

    if (size.width == transform.tx && size.height == transform.ty) {
        return UIInterfaceOrientationLandscapeRight;

    } else if (transform.tx == 0 && transform.ty == 0) {
        return UIInterfaceOrientationLandscapeLeft;

    } else if (transform.tx == 0 && transform.ty == size.width) {
        return UIInterfaceOrientationPortraitUpsideDown;

    } else {
        return UIInterfaceOrientationPortrait;
    }
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
    CGSize videoSize = [self croppedVideoSize:videoTrack];
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);

    return videoLayer;
}

- (CALayer *)orientationFixedVideoLayer:(CALayer *)videoLayer fromTrack:(AVAssetTrack *)videoTrack
{
    // No need to worry about other orientations while we only support portrait
    if ([self orientationForTrack:videoTrack] == UIInterfaceOrientationLandscapeLeft) {
        CGAffineTransform rotation = CGAffineTransformMakeRotation(-M_PI_2);
        CGAffineTransform translateToCenter = CGAffineTransformMakeTranslation(CGRectGetWidth(videoLayer.frame), CGRectGetHeight(videoLayer.frame));

        videoLayer.affineTransform = CGAffineTransformConcat(rotation, translateToCenter);
    }

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

- (AVMutableVideoComposition *)videoCompositionFromTrack:(AVAssetTrack *)videoTrack withText:(NSString *)text
{
    CGSize croppedVideoSize = [self croppedVideoSize:videoTrack];

    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = croppedVideoSize;
    videoComposition.frameDuration = CMTimeMake(1, 30);

    CALayer *parentLayer = [self squareCroppedVideoLayer:[CALayer layer] fromTrack:videoTrack];

    CALayer *videoLayer = [CALayer layer];
    videoLayer = [self orientationFixedVideoLayer:videoLayer fromTrack:videoTrack];

    CATextLayer *wordLayer = [self layerForText:text];
    wordLayer.frame = CGRectMake(0, 50, croppedVideoSize.width, 50);

    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:wordLayer];
    [wordLayer display];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    videoLayer.frame = CGRectMake(0, 0, croppedVideoSize.width, croppedVideoSize.height);

    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoTrack.asset.duration);

    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
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
        error = nil;
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
            error = nil;
        }
    }

    return composition;
}

@end
