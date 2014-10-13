//
//  Room.h
//  mugchat
//
//  Created by Bruno Bruggemann on 10/13/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Room : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * pubnubID;
@property (nonatomic, retain) NSString * roomID;
@property (nonatomic, retain) User *admin;
@property (nonatomic, retain) NSSet *participants;
@end

@interface Room (CoreDataGeneratedAccessors)

- (void)addParticipantsObject:(User *)value;
- (void)removeParticipantsObject:(User *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
