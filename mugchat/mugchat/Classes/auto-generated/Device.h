//
//  Device.h
//  mugchat
//
//  Created by Bruno Bruggemann on 10/13/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * isVerified;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * platform;
@property (nonatomic, retain) NSNumber * retryCount;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * verificationCode;
@property (nonatomic, retain) User *user;

@end
