//
//  VideoCreator.m
//  VideoCreator
//
//  Created by Bruno Bruggemann on 10/31/14.
//  Copyright (c) 2014 Bruno Bruggemann. All rights reserved.
//

#import "VideoCreator.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoCreator

- (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path {
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSLog(@"documents: %@", documents);
    documents = [documents stringByAppendingPathComponent:@""];
    
    //NSLog(path);
    NSString *filename = [documents stringByAppendingPathComponent:[array objectAtIndex:0]];
    UIImage *first = [UIImage imageWithContentsOfFile:filename];
    CGSize frameSize = first.size;
    
    NSError *error = nil;
    NSString *tmpPath = [documents stringByAppendingPathComponent:@"tmp_mov.mov"];
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL: [NSURL fileURLWithPath:tmpPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
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
    
    // fixes all errors
    writerVideoInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    int fps = 1;
    int i = 0;
    
    for (NSString *filename in array) {
        if (adaptor.assetWriterInput.readyForMoreMediaData) {
            NSLog(@"inside for loop %d %@ ",i, filename);
            
            CMTime frameTime = CMTimeMakeWithSeconds(1, fps);
            CMTime lastTime = CMTimeMakeWithSeconds(i-1, fps);
            CMTime presentTime = CMTimeAdd(lastTime, frameTime);
            
            NSString *filePath = [documents stringByAppendingPathComponent:filename];
            
            UIImage *imgFrame = [UIImage imageWithContentsOfFile:filePath] ;
            if (i == 0) {
                imgFrame = [self drawText:@"I" inImage:imgFrame];
            } else if (i == 1) {
                imgFrame = [self drawText:@"LOVE" inImage:imgFrame];
            } else if (i == 2) {
                imgFrame = [self drawText:@"COFFEE" inImage:imgFrame];
            }
            
            buffer = [self pixelBufferFromCGImage:[imgFrame CGImage]];
            
            BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            
            if (result == NO) {
                NSLog(@"failed to append buffer");
                NSLog(@"The error is %@", [videoWriter error]);
            }
            
            if (buffer) {
                CVBufferRelease(buffer);
            }
            [NSThread sleepForTimeInterval:0.05];
            fps = 1;
            i++;
        } else {
            NSLog(@"error");
            i--;
        }
        [NSThread sleepForTimeInterval:0.02];
    }
    
    //Finish the session:
    [writerVideoInput markAsFinished];
    [videoWriter finishWriting];
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
    
    [self addAudio:path];
}



- (void) addAudio:(NSString*)path {
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSLog(@"documents: %@", documents);
    documents = [documents stringByAppendingPathComponent:@""];
    
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:path];
    //    NSString *filePath = [documents stringByAppendingPathComponent:@"newFile.m4a"];
    
    NSString *filePath = [documents stringByAppendingPathComponent:@"audio.m4a"];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:filePath];
    
    NSString *tmpPath = [documents stringByAppendingPathComponent:@"tmp_mov.mov"];
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:tmpPath];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

    CMTime audioStartTime = CMTimeMakeWithSeconds(1, 1);
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:audioStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
         if (_assetExport.status == AVAssetExportSessionStatusCompleted) {
             //Write Code Here to Continue
         } else {
             //Write Fail Code here
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
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                        &pxbuffer);
    
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