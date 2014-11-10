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


//- (void)testCreatingFourWordsVideo
//{
//    NSURL *docsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//
//    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
//
//    NSEntityDescription *messageDescription = [NSEntityDescription entityForName:@"MugMessage" inManagedObjectContext:moc];
//    NSEntityDescription *mugDescription = [NSEntityDescription entityForName:@"Mug" inManagedObjectContext:moc];
//
//    MugMessage *message = [[MugMessage alloc] initWithEntity:messageDescription insertIntoManagedObjectContext:moc];
//
//    Mug *mugOne = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
//    mugOne.mugID = @"id:one";
//    mugOne.word = @"One";
//    mugOne.backgroundContentType = @(2);
//    mugOne.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.1.mov"] absoluteString];
//    [message addMug:mugOne];
//
//    Mug *mugTwo = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
//    mugTwo.mugID = @"id:two";
//    mugTwo.word = @"Two";
//    mugTwo.backgroundContentType = @(2);
//    mugTwo.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.2.mov"] absoluteString];
//    [message addMug:mugTwo];
//
//    Mug *mugThree = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
//    mugThree.mugID = @"id:three";
//    mugThree.word = @"Three";
//    mugThree.backgroundContentType = @(2);
//    mugThree.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.3.mov"] absoluteString];
//    [message addMug:mugThree];
//
//    Mug *mugFour = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
//    mugFour.mugID = @"id:four";
//    mugFour.word = @"Four";
//    mugFour.backgroundContentType = @(2);
//    mugFour.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.4.mov"] absoluteString];
//    [message addMug:mugFour];
//
//    NSLog(@"GENERATED VIDEO URL: %@", [self videoFromMugMessage:message]);
//
//    [moc rollback];
//}



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


- (AVAsset *)videoFromMug:(Mug *)mug {
    AVAsset *track;
    
    NSString *backgroundContentLocalPath = [mug backgroundContentLocalPath];
    if ([mug isBackgroundContentTypeVideo]) {
        NSURL *videoURL = [NSURL URLWithString:backgroundContentLocalPath];
        track = [AVAsset assetWithURL:videoURL];
        [self addText:mug.word overVideoTrack:track];
    } else {
        ImageVideoCreator *imageVideoCreator = [[ImageVideoCreator alloc] init];
        NSURL *videoURL = [NSURL URLWithString:[imageVideoCreator videoPathForMug:mug]];
        track = [AVAsset assetWithURL:videoURL];
    }

    return track;
}



//let videoCreator = ImageVideoCreator()
//let cacheHandler = CacheHandler.sharedInstance
//for mug in mugs {
//    if (mug.backgroundURL != nil) {
//        if (mug.isBackgroundContentTypeImage()) {
//            let videoPath = cacheHandler.getFilePathForUrl("\(mug.mugID).mov", isTemporary: true)
//            let imageData = cacheHandler.dataForUrl(mug.backgroundURL)
//            var mugImage: UIImage!
//            if (imageData != nil) {
//                mugImage = UIImage(data: imageData!)
//            } else {
//                // TODO use the green image
//                //                        mugImage = UIImage.
//            }
//            
//            var mugSoundPath: String?
//            if ((mug.soundURL != nil) && (!mug.soundURL.isEmpty)) {
//                var soundHasCacheResult = cacheHandler.hasCachedFileForUrl(mug.soundURL)
//                if (soundHasCacheResult.hasCache) {
//                    mugSoundPath = soundHasCacheResult.filePath
//                }
//            }
//            
//            println("videoPath: \(videoPath)")
//            videoCreator.createVideoForWord(mug.word, withImage: mugImage, andAudioPath: mugSoundPath, atPath: videoPath)
//            
//        } else if (mug.isBackgroundContentTypeVideo()) {
//            // TODO add the text to the video
//        }
//    }
//}


#pragma mark - Private

- (NSURL *)videoJoiningParts:(NSArray *)videoParts
{
    AVMutableComposition *composition = [AVMutableComposition composition];

    CMTime insertionPoint = kCMTimeZero;

    for (AVAsset *track in videoParts) {
        CMTime trackDuration = track.duration;

        // should never happen as the videos are recorded with a fixed length of 1 second
        // NOTE: value / timeScale = seconds
        if ((trackDuration.value / trackDuration.timescale) > 1) {
            trackDuration = CMTimeMake(1, 1);
        }

        NSError *error;
        [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, trackDuration)
                             ofAsset:track
                              atTime:insertionPoint
                               error:&error];

        if (error) {
            NSLog(@"ERROR ADDING TRACK: %@", error);
        } else {
            insertionPoint = CMTimeAdd(insertionPoint, trackDuration);
        }
    }

    AVAssetTrack *firstVideoTrack = [[[videoParts firstObject] tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVMutableCompositionTrack *compositionVideoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] firstObject];
    compositionVideoTrack.preferredTransform = firstVideoTrack.preferredTransform;

//    AVMutableVideoCompositionLayerInstruction *cropInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionv];
//    CGRect square = CGRectMake(0, 0, firstVideoTrack.naturalSize.height, firstVideoTrack.naturalSize.height);
//    [cropInstruction setCropRectangle:square atTime:kCMTimeZero];


    NSURL *docsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    __block NSURL *videoUrl = [docsDir URLByAppendingPathComponent:@"generated-mug-message.mov"]; // Should get unique ID of mug message to use as filename

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

- (void)addText:(NSString *)text overVideoTrack:(AVAsset *)track
{
    AVAssetTrack *videoTrack = [[track tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVAssetTrack *audioTrack = [[track tracksWithMediaType:AVMediaTypeAudio] firstObject];

    NSError *error = nil;

    AVMutableComposition *composition = [AVMutableComposition composition];

    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [track duration])
                                   ofTrack:videoTrack
                                    atTime:kCMTimeZero
                                     error:&error];

    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [track duration])
                                   ofTrack:audioTrack
                                    atTime:kCMTimeZero
                                     error:&error];




    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    videoComposition.renderSize = videoTrack.naturalSize;




    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);

    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    passThroughInstruction.layerInstructions = @[passThroughLayer];
    videoComposition.instructions = @[passThroughInstruction];


    CALayer *textLayer = [self layerForText:text andSize:videoComposition.renderSize];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoComposition.renderSize.width, videoComposition.renderSize.height);
    [parentLayer addSublayer:videoLayer];
    textLayer.position = CGPointMake(videoComposition.renderSize.width/2, videoComposition.renderSize.height/4);
    [parentLayer addSublayer:textLayer];
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];



//    UILabel *textLabel = [[UILabel alloc] init];
//    textLabel.text = text;
//    textLabel.layer.borderWidth = 1.0;
//    textLabel.layer.borderColor = [UIColor avacado].CGColor;
//    textLabel.layer.cornerRadius = 14.0;
//    textLabel.textAlignment = NSTextAlignmentCenter;
//    textLabel.font = [UIFont avenirNextRegular:18.0];
//    textLabel.textColor = [UIColor blackColor];
//    [textLabel sizeToFit];
//
//    CALayer *layer = [CALayer layer];
//    layer.frame = CGRectMake(0, 0, videoTrack.naturalSize.height, videoTrack.naturalSize.height);
//    layer.backgroundColor = [UIColor cyanColor].CGColor;
//    layer.masksToBounds = YES;

}

- (CALayer *)layerForText:(NSString *)text andSize:(CGSize)size
{
    // Create a layer for the title
    CALayer *_watermarkLayer = [CALayer layer];

    // Create a layer for the text of the title.
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = text;
    titleLayer.foregroundColor = [[UIColor whiteColor] CGColor];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.bounds = CGRectMake(0, 0, size.width, size.height);

    // Add it to the overall layer.
    [_watermarkLayer addSublayer:titleLayer];

    return _watermarkLayer;
}

@end
