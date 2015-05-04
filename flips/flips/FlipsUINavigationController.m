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

#import "FlipsUINavigationController.h"

@implementation FlipsUINavigationController {
    UIViewController *_poppedViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.delegate == nil) {
        self.delegate = self;
    }
    
    NSTimeInterval oneSecondAgo = [[[NSDate date] dateByAddingTimeInterval:-1] timeIntervalSince1970];
    if (self.busyAnimating && self.lastAnimationTime > oneSecondAgo) {
        NSLog(@"Not pushing a new view controller because we're already busy pushing another.");
        return;
    }
    
    if (self.delegate == self) {
        self.busyAnimating = YES;
        self.lastAnimationTime = [[NSDate date] timeIntervalSince1970];
    } else {
        NSLog(@"FlipsUINavigationController was expecting to be its own delegate.");
    }
    
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.busyAnimating = NO;
    self.lastAnimationTime = [[NSDate date] timeIntervalSince1970];
    
    if (viewController != _poppedViewController) {
        _poppedViewController = nil;
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.delegate == nil) {
        self.delegate = self;
    }
    
    if (_poppedViewController) {
        NSLog(@"Not poping because we're already busy popping it.");
        return nil;
    }
    
    _poppedViewController = self.topViewController;
    return [super popViewControllerAnimated:animated];
}

@end
