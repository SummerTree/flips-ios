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
#import <CoreData/CoreData.h>


@interface BuilderWord : NSManagedObject

@property (nonatomic, retain) NSDate * addedAt;
@property (nonatomic, retain) NSNumber * fromServer;
@property (nonatomic, retain) NSString * word;

@end
