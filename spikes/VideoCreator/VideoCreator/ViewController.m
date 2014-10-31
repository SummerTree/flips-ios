//
//  ViewController.m
//  VideoCreator
//
//  Created by Bruno Bruggemann on 10/31/14.
//  Copyright (c) 2014 Bruno Bruggemann. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoCreator.h"

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
        VideoCreator *videoCreator = [[VideoCreator alloc] init];
        [videoCreator writeImagesAsMovie:@[@"i.gif", @"ididit2.gif", @"rainbow_letter_i_photosculpture-p153807374388565225bfr64_400.jpg"] toPath:documents];
    });
}


@end
