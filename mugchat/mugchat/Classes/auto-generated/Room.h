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

@class MugMessage, User;

@interface Room : NSManagedObject

@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSDate * lastMessageReceivedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pubnubID;
@property (nonatomic, retain) NSString * roomID;
@property (nonatomic, retain) User *admin;
@property (nonatomic, retain) NSOrderedSet *mugMessages;
@property (nonatomic, retain) NSSet *participants;
@end

@interface Room (CoreDataGeneratedAccessors)

- (void)insertObject:(MugMessage *)value inMugMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMugMessagesAtIndex:(NSUInteger)idx;
- (void)insertMugMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMugMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMugMessagesAtIndex:(NSUInteger)idx withObject:(MugMessage *)value;
- (void)replaceMugMessagesAtIndexes:(NSIndexSet *)indexes withMugMessages:(NSArray *)values;
- (void)addMugMessagesObject:(MugMessage *)value;
- (void)removeMugMessagesObject:(MugMessage *)value;
- (void)addMugMessages:(NSOrderedSet *)values;
- (void)removeMugMessages:(NSOrderedSet *)values;
- (void)addParticipantsObject:(User *)value;
- (void)removeParticipantsObject:(User *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
