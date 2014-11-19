//
//  PNMessagePostRequest+Protected.h
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


#import "PNMessagePostRequest.h"


#pragma mark Protected interface implementation

@interface PNMessagePostRequest (Protected)


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, readonly, strong) PNMessage *message;

<<<<<<< HEAD
=======
/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *publishKey;

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
#pragma mark -


@end
