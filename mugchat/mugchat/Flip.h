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

@class FlipEntry, User;

@interface Flip : NSManagedObject

@property (nonatomic, retain) NSNumber * backgroundContentType;
@property (nonatomic, retain) NSString * backgroundURL;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * flipID;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSNumber * removed;
@property (nonatomic, retain) NSString * soundURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) User *owner;
@property (nonatomic, retain) NSSet *entries;
@end

@interface Flip (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(FlipEntry *)value;
- (void)removeEntriesObject:(FlipEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
