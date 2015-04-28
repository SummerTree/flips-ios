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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FlipMessage.h"
#import "Flip.h"

typedef void (^VideoComposerSuccessHandler)(NSURL *videoURL, NSURL *thumbnailURL);
typedef void (^VideoComposerErrorHandler)(NSError *error);

@interface VideoComposer : NSObject

- (void)flipVideoFromImage:(UIImage *)image andAudioURL:(NSURL *)audio successHandler:(VideoComposerSuccessHandler)successHandler;
- (void)flipVideoFromVideo:(NSURL *)originalVideo successHandler:(VideoComposerSuccessHandler)successHandler;

- (UIImage *)thumbnailForVideo:(NSURL *)videoURL;

@end
