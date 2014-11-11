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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MugMessage.h"


@interface VideoComposer : NSObject

- (NSURL *)videoFromMugs:(NSArray *)mugs;
- (NSURL *)videoFromMugMessage:(MugMessage *)mugMessage;
- (AVAsset *)videoFromMug:(Mug *)mug;

- (void)testCreatingFourWordsVideo;

@end