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

@class FlipMessage, User;

@interface Room : NSManagedObject

@property (nonatomic, retain) NSDate * lastMessageReceivedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pubnubID;
@property (nonatomic, retain) NSNumber * removed;
@property (nonatomic, retain) NSString * roomID;
@property (nonatomic, retain) User *admin;
@property (nonatomic, retain) NSOrderedSet *flipMessages;
@property (nonatomic, retain) NSSet *participants;
@end

@interface Room (CoreDataGeneratedAccessors)

- (void)insertObject:(FlipMessage *)value inFlipMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlipMessagesAtIndex:(NSUInteger)idx;
- (void)insertFlipMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlipMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlipMessagesAtIndex:(NSUInteger)idx withObject:(FlipMessage *)value;
- (void)replaceFlipMessagesAtIndexes:(NSIndexSet *)indexes withFlipMessages:(NSArray *)values;
- (void)addFlipMessagesObject:(FlipMessage *)value;
- (void)removeFlipMessagesObject:(FlipMessage *)value;
- (void)addFlipMessages:(NSOrderedSet *)values;
- (void)removeFlipMessages:(NSOrderedSet *)values;
- (void)addParticipantsObject:(User *)value;
- (void)removeParticipantsObject:(User *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
