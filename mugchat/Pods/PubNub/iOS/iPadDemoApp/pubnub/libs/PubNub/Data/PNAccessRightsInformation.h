//
//  PNAccessRightsInformation.h
//  pubnub
//
//  Created by Sergey Mamontov on 11/3/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNStructures.h"
<<<<<<< HEAD
=======
#import "PNChannelProtocol.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark Public interface declaration

@interface PNAccessRightsInformation : NSObject


#pragma mark - Properties

/**
 Stores access rights level for which this object has been created.
 */
@property (nonatomic, readonly, assign) PNAccessRightsLevel level;

/**
 Stores access rights bit mask which describe whether there is \a 'read' / \a 'write' rights on object specified by
 access level
 */
@property (nonatomic, readonly, assign) PNAccessRights rights;

/**
 Stores reference on key which is used to identify application (\a 'subscription' key).
 */
@property (nonatomic, readonly, copy) NSString *subscriptionKey;

/**
 Stores reference on channel for which access rights has been granted or retrieved.

 @note This property will be set only if \a level is set to: \a PNChannelAccessRightsLevel or \a PNUserAccessRightsLevel.
 */
<<<<<<< HEAD
@property (nonatomic, readonly, strong) PNChannel *channel;
=======
@property (nonatomic, readonly, strong) PNChannel *channel DEPRECATED_MSG_ATTRIBUTE(" Use 'object' property instead");

/**
 Stores reference on data feed object for which access rights has been granted or retrieved.
 
 @note This property will be set only if \a level is set to: \a PNChannelAccessRightsLevel, 
 \a PNChannelGroupAccessRightsLevel or \a PNUserAccessRightsLevel.
 */
@property (nonatomic, readonly, strong) id <PNChannelProtocol> object;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Stores reference on authorization key for which access rights has been granted or retrieved.

 @note This property will be set only if \a level is set to \a PNUserAccessRightsLevel.
 */
@property (nonatomic, readonly, copy) NSString *authorizationKey;

/**
 Stores reference on value, which described on how long specified access rights has been granted.
 */
@property (nonatomic, readonly, assign) NSUInteger accessPeriodDuration;


#pragma mark - Instance methods

/**
 Check access rights bit mask and return whether \a 'read' access permission is granted or not.

 @return \c YES if \b PNReadAccessRight bit is set in \a 'rights' property.
 */
- (BOOL)hasReadRight;

/**
 Check access rights bit mask and return whether \a 'write' access permission is granted or not.
<<<<<<< HEAD

=======
 
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
 @return \c YES if \b PNWriteAccessRight bit is set in \a 'rights' property.
 */
- (BOOL)hasWriteRight;

/**
 Check access rights bit mask and return whether \a 'write' access permission is granted or not.
<<<<<<< HEAD
=======
 
 @discussion This check doesn't include \a 'management' access rights
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

 @return \c YES if both \b PNReadAccessRight and \b PNWriteAccessRight bits are set in \a 'rights' property.
 */
- (BOOL)hasAllRights;

/**
<<<<<<< HEAD
=======
 Check access rights bit mask and return whether \a 'write' access permission is granted or not.
 
 @return \c YES if \b PNManagementAccessRight bit is set in \a 'rights' property.
 */
/**
 @brief Rights bit field check for management ability.
 
 @return \c YES in case if there is rights management rights.
 
 @since 3.7.0
 */
- (BOOL)hasManagementRight;

/**
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
 Check whether all rights has been revoked or not.

 @return \c YES if both \b PNReadAccessRight and \b PNWriteAccessRight bits not set in \a 'rights' property.
 */
- (BOOL)isAllRightsRevoked;

#pragma mark -


@end
