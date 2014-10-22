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

@property (nonatomic, retain) NSNumber * notRead;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * receivedAt;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) NSSet *mugs;
@property (nonatomic, retain) Room *room;
@end

@interface MugMessage (CoreDataGeneratedAccessors)

- (void)addMugsObject:(Mug *)value;
- (void)removeMugsObject:(Mug *)value;
- (void)addMugs:(NSSet *)values;
- (void)removeMugs:(NSSet *)values;

@end
