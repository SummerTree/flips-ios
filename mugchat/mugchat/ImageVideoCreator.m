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

+ (NSString *)videoPathForFlip:(Flip *)flip {
    CacheHandler *cacheHandler = [CacheHandler sharedInstance];
    UIImage *backgroundImage = [UIImage imageWithData:[cacheHandler dataForUrl:flip.backgroundContentLocalPath]];
    
    NSString *videoName = [NSString stringWithFormat:@"%@.mov", flip.flipID];
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@", cacheHandler.applicationCacheDirectory, videoName];

    ImageVideoCreator *instance = [[ImageVideoCreator alloc] init];
    [instance createVideoWithImage:backgroundImage atPath:videoPath];
    
    return videoPath;
}

- (void)createVideoWithImage:(UIImage *)image atPath:(NSString *)path {
    
    if (image == nil) {
        NSLog(@"Image is nil, it shouldn't happen.");
    }

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
    if (frameSize.width == 0.0) {
        NSLog(@"Frame width is 0.0, it shouldn't happen.");
    }
    
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
    
    CVPixelBufferRef buffer = [self pixelBufferFromCGImage:[image CGImage]];

    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    if (result == NO) { //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");
    }
    
    if(buffer) {
        CVBufferRelease(buffer);
    }

    [NSThread sleepForTimeInterval:0.05];

    if (adaptor.assetWriterInput.readyForMoreMediaData) {
        buffer = [self pixelBufferFromCGImage:[image CGImage]];

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

    
    dispatch_group_t group = dispatch_group_create();
    
    //Finish the session:
    [writerVideoInput markAsFinished];
    dispatch_group_enter(group);
    [videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"Finished writing video");
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
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
