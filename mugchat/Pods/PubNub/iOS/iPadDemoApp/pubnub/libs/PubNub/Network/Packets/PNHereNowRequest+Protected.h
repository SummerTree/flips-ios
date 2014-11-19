//
//  PNHereNowRequest+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#import "PNHereNowRequest.h"


#pragma mark Protected interface implementation

@interface PNHereNowRequest (Protected)


#pragma mark - Properties

<<<<<<< HEAD
// Stores reference on channel for which participants
// list will be requested
@property (nonatomic, readonly, strong) PNChannel *channel;
=======
/**
 Stores reference on array of PNChannel and PNChannelGroup for which list of participants has been requested.
 */
@property (nonatomic, readonly, strong) NSArray *channels;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Stores whether request should fetch client identifiers or just get number of participants.
 */
@property (nonatomic, readonly, assign, getter = isClientIdentifiersRequired) BOOL clientIdentifiersRequired;

/**
 Stores whether request should fetch client's state or not.
 */
@property (nonatomic, readonly, assign, getter = shouldFetchClientState) BOOL fetchClientState;

<<<<<<< HEAD
=======
/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
#pragma mark -


@end
