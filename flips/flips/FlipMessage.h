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
#import <CoreData/CoreData.h>

@class FlipEntry, Room, User;

@interface FlipMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * flipMessageID;
@property (nonatomic, retain) NSNumber * notRead;
@property (nonatomic, retain) NSDate * receivedAt;
@property (nonatomic, retain) NSNumber * removed;
@property (nonatomic, retain) User *from;
@property (nonatomic, retain) Room *room;
@property (nonatomic, retain) NSSet *entries;
@end

@interface FlipMessage (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(FlipEntry *)value;
- (void)removeEntriesObject:(FlipEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
