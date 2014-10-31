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

#import "mugchat-Swift.h"

@implementation VideoComposer


- (void)testCreatingFourWordsVideo
{
    NSURL *docsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];

    NSEntityDescription *messageDescription = [NSEntityDescription entityForName:@"MugMessage" inManagedObjectContext:moc];
    NSEntityDescription *mugDescription = [NSEntityDescription entityForName:@"Mug" inManagedObjectContext:moc];

    MugMessage *message = [[MugMessage alloc] initWithEntity:messageDescription insertIntoManagedObjectContext:moc];

    Mug *mugOne = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugOne.mugID = @"id:one";
    mugOne.word = @"One";
    mugOne.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.1.mov"] absoluteString];
    [message addMug:mugOne];

    Mug *mugTwo = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugTwo.mugID = @"id:two";
    mugTwo.word = @"Two";
    mugTwo.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.2.mov"] absoluteString];
    [message addMug:mugTwo];

    Mug *mugThree = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugThree.mugID = @"id:three";
    mugThree.word = @"Three";
    mugThree.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.3.mov"] absoluteString];
    [message addMug:mugThree];

    Mug *mugFour = [[Mug alloc] initWithEntity:mugDescription insertIntoManagedObjectContext:moc];
    mugFour.mugID = @"id:four";
    mugFour.word = @"Four";
    mugFour.backgroundURL = [[docsDir URLByAppendingPathComponent:@"recording-2014-10-29.4.mov"] absoluteString];
    [message addMug:mugFour];

    NSLog(@"GENERATED VIDEO URL: %@", [self videoFromMugMessage:message]);

    [moc rollback];
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

- (AVAsset *)videoFromMug:(Mug *)mug
{
    NSURL *videoURL = [NSURL URLWithString:[mug backgroundURL]];
    AVAsset *track = [AVAsset assetWithURL:videoURL];

    return track;
}


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

    NSURL *docsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *videoUrl = [docsDir URLByAppendingPathComponent:@"generated-mug-message.mov"]; // Should get unique ID of mug message to use as filename

    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = videoUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"SUCCESS");
        }

        if (exportSession.status == AVAssetExportSessionStatusFailed) {
            NSLog(@"FAIL");
        }
    }];

    return videoUrl;
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
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

@end
