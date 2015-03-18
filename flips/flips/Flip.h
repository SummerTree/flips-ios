//
//  Flip.h
//  flips
//
//  Created by Ecil Teodoro on 3/18/15.
//
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
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *entries;
@property (nonatomic, retain) User *owner;
@end

@interface Flip (CoreDataGeneratedAccessors)

- (void)addEntriesObject:(FlipEntry *)value;
- (void)removeEntriesObject:(FlipEntry *)value;
- (void)addEntries:(NSSet *)values;
- (void)removeEntries:(NSSet *)values;

@end
