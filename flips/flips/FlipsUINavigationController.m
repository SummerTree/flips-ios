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
    
    if ([self isBusyAnimatingTransition]) {
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
    
    if (self.afterViewControllerPresented != nil) {
        self.afterViewControllerPresented();
        self.afterViewControllerPresented = nil;
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.delegate == nil) {
        self.delegate = self;
    }
    
    if ([self isBusyAnimatingTransition]) {
        NSLog(@"Not popping a new view controller because we're busy animating.");
        return nil;
    }

    if (self.delegate == self) {
        self.busyAnimating = YES;
        self.lastAnimationTime = [[NSDate date] timeIntervalSince1970];
    } else {
        NSLog(@"FlipsUINavigationController was expecting to be its own delegate.");
    }

    _poppedViewController = self.topViewController;
    return [super popViewControllerAnimated:animated];
}

- (BOOL)isBusyAnimatingTransition {
    return self.busyAnimating && self.lastAnimationTime > [[NSDate date] timeIntervalSince1970];
}

- (void) dispatchAfterViewControllerPresented:(void (^)())afterViewControllerPresented {
    
    if (self.busyAnimating) {
        self.afterViewControllerPresented = afterViewControllerPresented;
    }
    else {
        afterViewControllerPresented();
    }
    
}

@end
