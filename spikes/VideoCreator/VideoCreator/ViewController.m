//
//  ViewController.m
//  VideoCreator
//
//  Created by Bruno Bruggemann on 10/31/14.
//  Copyright (c) 2014 Bruno Bruggemann. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSLog(@"documents: %@", documents);
    documents = [documents stringByAppendingPathComponent:@"video.mov"];
    NSLog(@"documents: %@", documents);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:documents error:nil];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self writeImagesAsMovie:@[@"i.gif", @"ididit2.gif", @"rainbow_letter_i_photosculpture-p153807374388565225bfr64_400.jpg"] toPath:documents];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) writeImagesAsMovie:(NSArray *)array toPath:(NSString*)path {
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSLog(@"documents: %@", documents);
    documents = [documents stringByAppendingPathComponent:@""];
    
    //NSLog(path);
    NSString *filename = [documents stringByAppendingPathComponent:[array objectAtIndex:0]];
    UIImage *first = [UIImage imageWithContentsOfFile:filename];
    
    CGSize frameSize = first.size;
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL: [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:frameSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:frameSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:frameSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerInput];
    
    // fixes all errors
    writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    buffer = [self pixelBufferFromCGImage:[first CGImage]];
    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    
    if (result == NO) //failes on 3GS, but works on iphone 4
        NSLog(@"failed to append buffer");
    
    if(buffer)
        CVBufferRelease(buffer);
    
    [NSThread sleepForTimeInterval:0.05];
    
    int reverseSort = NO;
    //    NSArray *newArray = [array sortedArrayUsingFunction:sort context:&reverseSort];
    
    //    delta = 1.0/[newArray count];
    float delta = 1.0/[array count];
    
    //    int fps = (int)fpsSlider.value;
    int fps = 1;
    
    int i = 0;
    for (NSString *filename in array)
    {
        // Ignore first image that already was added
        if (i > 0) {
            if (adaptor.assetWriterInput.readyForMoreMediaData) {
                
                NSLog(@"inside for loop %d %@ ",i, filename);
                CMTime frameTime = CMTimeMakeWithSeconds(1, fps);
                CMTime lastTime = CMTimeMakeWithSeconds(i-1, fps);
                CMTime presentTime = CMTimeAdd(lastTime, frameTime);
                
                NSString *filePath = [documents stringByAppendingPathComponent:filename];
                
                UIImage *imgFrame = [UIImage imageWithContentsOfFile:filePath] ;
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
            }
            else
            {
                NSLog(@"error");
                i--;
            }
        } else {
            i++;
        }
        [NSThread sleepForTimeInterval:0.02];
    }
    
    //Finish the session:
    [writerInput markAsFinished];
    [videoWriter finishWriting];
    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
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
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, CGImageGetHeight(image));
    CGContextConcatCTM(context, flipVertical);
    
    CGAffineTransform flipHorizontal = CGAffineTransformMake(-1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0);
    CGContextConcatCTM(context, flipHorizontal);
    
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
