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

@class Contact, Device, Mug, MugMessage, Room;

@interface User : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * me;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * pubnubID;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * isTemporary;
@property (nonatomic, retain) Room *adminRooms;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) Device *device;
@property (nonatomic, retain) NSOrderedSet *mugs;
@property (nonatomic, retain) NSOrderedSet *mugsSent;
@property (nonatomic, retain) NSOrderedSet *rooms;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

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
- (void)insertObject:(MugMessage *)value inMugsSentAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMugsSentAtIndex:(NSUInteger)idx;
- (void)insertMugsSent:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMugsSentAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMugsSentAtIndex:(NSUInteger)idx withObject:(MugMessage *)value;
- (void)replaceMugsSentAtIndexes:(NSIndexSet *)indexes withMugsSent:(NSArray *)values;
- (void)addMugsSentObject:(MugMessage *)value;
- (void)removeMugsSentObject:(MugMessage *)value;
- (void)addMugsSent:(NSOrderedSet *)values;
- (void)removeMugsSent:(NSOrderedSet *)values;
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
