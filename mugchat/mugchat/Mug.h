//
//  Mug.h
//  mugchat
//
//  Created by Diego Santiviago on 10/14/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Mug : NSManagedObject

@property (nonatomic, retain) NSString * backgroundURL;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSString * mugID;
@property (nonatomic, retain) NSString * soundURL;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) User *owner;

@end
