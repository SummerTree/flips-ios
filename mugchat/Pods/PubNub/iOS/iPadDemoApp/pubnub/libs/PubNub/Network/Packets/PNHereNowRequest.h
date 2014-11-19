//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import <Foundation/Foundation.h>
#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNHereNowRequest : PNBaseRequest


#pragma mark Class methods

<<<<<<< HEAD
+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                  clientState:(BOOL)shouldFetchClientState;
=======
+ (PNHereNowRequest *)whoNowRequestForChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                   clientState:(BOOL)shouldFetchClientState;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Instance methods

<<<<<<< HEAD
- (id)initWithChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
          clientState:(BOOL)shouldFetchClientState;
=======
- (id)initWithChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
           clientState:(BOOL)shouldFetchClientState;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

#pragma mark -


@end
