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

@class Flip, Room, User;

@interface FlipMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * flipMessageID;
@property (nonatomic, retain) NSNumber * notRead;
@property (nonatomic, retain) NSDate * receivedAt;
@property (nonatomic, retain) NSNumber * removed;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) NSOrderedSet *flips;
@property (nonatomic, retain) Room *room;
@end

@interface FlipMessage (CoreDataGeneratedAccessors)

- (void)insertObject:(Flip *)value inFlipsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlipsAtIndex:(NSUInteger)idx;
- (void)insertFlips:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlipsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlipsAtIndex:(NSUInteger)idx withObject:(Flip *)value;
- (void)replaceFlipsAtIndexes:(NSIndexSet *)indexes withFlips:(NSArray *)values;
- (void)addFlipsObject:(Flip *)value;
- (void)removeFlipsObject:(Flip *)value;
- (void)addFlips:(NSOrderedSet *)values;
- (void)removeFlips:(NSOrderedSet *)values;
@end
