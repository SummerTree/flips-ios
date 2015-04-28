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

@class Contact, Device, Flip, FlipMessage, Room;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * isTemporary;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * me;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * pubnubID;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Room *adminRooms;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) Device *device;
@property (nonatomic, retain) NSOrderedSet *flips;
@property (nonatomic, retain) NSOrderedSet *flipsSent;
@property (nonatomic, retain) NSOrderedSet *rooms;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

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
- (void)insertObject:(FlipMessage *)value inFlipsSentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFlipsSentAtIndex:(NSUInteger)idx;
- (void)insertFlipsSent:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFlipsSentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFlipsSentAtIndex:(NSUInteger)idx withObject:(FlipMessage *)value;
- (void)replaceFlipsSentAtIndexes:(NSIndexSet *)indexes withFlipsSent:(NSArray *)values;
- (void)addFlipsSentObject:(FlipMessage *)value;
- (void)removeFlipsSentObject:(FlipMessage *)value;
- (void)addFlipsSent:(NSOrderedSet *)values;
- (void)removeFlipsSent:(NSOrderedSet *)values;
- (void)insertObject:(Room *)value inRoomsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRoomsAtIndex:(NSUInteger)idx;
- (void)insertRooms:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRoomsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRoomsAtIndex:(NSUInteger)idx withObject:(Room *)value;
- (void)replaceRoomsAtIndexes:(NSIndexSet *)indexes withRooms:(NSArray *)values;
- (void)addRoomsObject:(Room *)value;
- (void)removeRoomsObject:(Room *)value;
- (void)addRooms:(NSOrderedSet *)values;
- (void)removeRooms:(NSOrderedSet *)values;
@end
