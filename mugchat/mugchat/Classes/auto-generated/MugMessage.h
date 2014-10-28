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

@class Mug, Room, User;

@interface MugMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * removed;
@property (nonatomic, retain) NSNumber * notRead;
@property (nonatomic, retain) NSDate * receivedAt;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) NSOrderedSet *mugs;
@property (nonatomic, retain) Room *room;
@end

@interface MugMessage (CoreDataGeneratedAccessors)

- (void)insertObject:(Mug *)value inMugsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMugsAtIndex:(NSUInteger)idx;
- (void)insertMugs:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMugsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMugsAtIndex:(NSUInteger)idx withObject:(Mug *)value;
- (void)replaceMugsAtIndexes:(NSIndexSet *)indexes withMugs:(NSArray *)values;
- (void)addMugsObject:(Mug *)value;
- (void)removeMugsObject:(Mug *)value;
- (void)addMugs:(NSOrderedSet *)values;
- (void)removeMugs:(NSOrderedSet *)values;
@end
