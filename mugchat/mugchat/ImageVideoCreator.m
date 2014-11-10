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

#import "ImageVideoCreator.h"
#import <AVFoundation/AVFoundation.h>

#import "Flips-Swift.h"

@implementation ImageVideoCreator

- (NSString *)videoPathForMug:(Mug *)mug {
    CacheHandler *cacheHandler = [CacheHandler sharedInstance];
    UIImage *backgroundImage = [UIImage imageWithData:[cacheHandler dataForUrl:mug.backgroundContentLocalPath]];
    
    NSString *videoName = [NSString stringWithFormat:@"%@.mov", mug.mugID];
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@", cacheHandler.applicationCacheDirectory, videoName];

    [self createVideoForWord:mug.word withImage:backgroundImage andAudioPath:mug.soundContentLocalPath atPath:videoPath];
    
    return videoPath;
}

- (void)createVideoForWord:(NSString *)word withImage:(UIImage *)image andAudioPath:(NSString *)audioPath atPath:(NSString *)path {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL: [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    
    CGSize frameSize = image.size;
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerVideoInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerVideoInput
                                                     sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerVideoInput];
    
    writerVideoInput.expectsMediaDataInRealTime = YES;
    
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    UIImage *imageFrame = [self drawText:word inImage:image];
    buffer = [self pixelBufferFromCGImage:[imageFrame CGImage]];
    
    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    if (result == NO) { //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");
    }
    
    if(buffer) {
        CVBufferRelease(buffer);
    }
    
    [NSThread sleepForTimeInterval:0.05];
    
    if (adaptor.assetWriterInput.readyForMoreMediaData) {
        buffer = [self pixelBufferFromCGImage:[imageFrame CGImage]];

        BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(1, 2)]; // 1 second
        
        if (result == NO) {
            NSLog(@"failed to append buffer");
            NSLog(@"The error is %@", [videoWriter error]);
        }
        
        if (buffer) {
            CVBufferRelease(buffer);
        }
        [NSThread sleepForTimeInterval:0.05];
    } else {
        NSLog(@"error");
    }
    [NSThread sleepForTimeInterval:0.02];
    
    //Finish the session:
    [writerVideoInput markAsFinished];
    [videoWriter finishWriting];
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    
    if (audioPath && (![audioPath isEqualToString:@""])) {
        [self addAudio:audioPath toMovieAtPath:path];
    }
}

- (void) addAudio:(NSString*)audioPath toMovieAtPath:(NSString *)moviePath {
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:moviePath];
    
//    NSString *filePath = [documents stringByAppendingPathComponent:@"audio.m4a"];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL *audio_inputFileUrl = [NSURL fileURLWithPath:audioPath];
    
//    NSString *tmpPath = [documents stringByAppendingPathComponent:@"tmp_mov.mov"];
    NSURL *video_inputFileUrl = [NSURL fileURLWithPath:moviePath];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    CMTime audioStartTime = CMTimeMakeWithSeconds(0, 1); // One second audio
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:audioStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        AVAssetExportSessionStatus status = [_assetExport status];
        switch (status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export Failed");
                NSLog(@"Export Error: %@", [_assetExport.error localizedDescription]);
                NSLog(@"Export Error Reason: %@", [_assetExport.error localizedFailureReason]);
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export Completed");
                break;
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"Export Unknown");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"Export Exporting");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"Export Waiting");
                break;
        }
    }];
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image), CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 CGImageGetWidth(image),
                                                 CGImageGetHeight(image),
                                                 8,
                                                 4 * CGImageGetWidth(image),
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image {
    
    // TODO: ajdust it correct has it is in the others screens
    float expectedFontSize = 40;
    float expectedScreenWidth = 320;
    float multiplier = image.size.width / expectedScreenWidth;
    
    UIFont *font = [UIFont boldSystemFontOfSize:expectedFontSize * multiplier];
    
    CGSize textSize = [text sizeWithAttributes:@{ NSFontAttributeName : font }];
    
    float x = (image.size.width / 2) - (textSize.width / 2);
    float y = image.size.height - textSize.height - (20 * multiplier);
    
    CGPoint point = CGPointMake(x, y);
    
    UIGraphicsBeginImageContext(image.size);
    
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShadow(context, CGSizeMake(2.0f, 2.0f), 2.0f);
    [text drawInRect:CGRectIntegral(rect) withAttributes:@{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
