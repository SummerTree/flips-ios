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

@implementation FlipsUINavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.delegate == nil) {
        self.delegate = self;
    }
    
    if (self.busyAnimating) {
        return;
    }
    
    self.busyAnimating = YES;
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.busyAnimating = NO;
}

@end
