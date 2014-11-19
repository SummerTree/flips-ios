/**

 @author Sergey Mamontov
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNCache.h"
<<<<<<< HEAD
=======
#import "NSObject+PNAdditions.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
#import "PNChannel.h"


#pragma mark Private interface declaration

@interface PNCache ()

#pragma mark - Properties

/**
 Unified storage for cached data across all channels which is in use by client and developer.
 */
@property (nonatomic, strong) NSMutableDictionary *stateCache;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNCache


#pragma mark - Instance methods

- (id)init {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.stateCache = [NSMutableDictionary dictionary];
<<<<<<< HEAD
=======
        
        dispatch_queue_t targetQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self pn_setPrivateDispatchQueue:[self pn_serialQueueWithOwnerIdentifier:@"state-cache" andTargetQueue:targetQueue]];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }

    return self;
}

#pragma mark - State management method

- (NSDictionary *)state {
<<<<<<< HEAD

    return ([self.stateCache count] ? [self.stateCache copy] : nil);
=======
    
    __block NSDictionary *state = nil;
    [self pn_dispatchSynchronouslyBlock:^{
        
        state = ([self.stateCache count] ? [self.stateCache copy] : nil);
    }];

    
    return state;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSDictionary *)stateMergedWithState:(NSDictionary *)state {
    
<<<<<<< HEAD
    NSMutableDictionary *cleanedState = (self.stateCache ? [self.stateCache mutableCopy] : [NSMutableDictionary dictionary]);
    
    [state enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                               BOOL *channelStateEnumeratorStop) {
        
        if ([cleanedState valueForKey:channelName] != nil) {
            
            // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
            // user want to remove state from specific channel).
            if ([channelState count]) {
                
                NSMutableDictionary *oldChannelState = [[cleanedState valueForKey:channelName] mutableCopy];
                [channelState enumerateKeysAndObjectsUsingBlock:^(NSString *stateName, id stateData,
                                                                  BOOL *stateDataEnumeratorStop) {
                    
                    // In case if provided data is 'nil' it should be removed from previous state dictionary.
                    if ([stateData isKindOfClass:[NSNull class]]) {
                        
                        [oldChannelState removeObjectForKey:stateName];
                    }
                    else {
                        
                        [oldChannelState setValue:stateData forKey:stateName];
                    }
                }];
                
                if ([oldChannelState count]) {
                    
                    [cleanedState setValue:oldChannelState forKey:channelName];
                }
            }
        }
        // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
        // user want to remove state from specific channel).
        else if ([channelState count]){
            
            [cleanedState setValue:channelState forKey:channelName];
        }
=======
    __block NSMutableDictionary *cleanedState = nil;
    [self pn_dispatchSynchronouslyBlock:^{
        
        cleanedState = (self.stateCache ? [self.stateCache mutableCopy] : [NSMutableDictionary dictionary]);
    
        [state enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                                   BOOL *channelStateEnumeratorStop) {
            
            if ([cleanedState valueForKey:channelName] != nil) {
                
                // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
                // user want to remove state from specific channel).
                if ([channelState count]) {
                    
                    NSMutableDictionary *oldChannelState = [[cleanedState valueForKey:channelName] mutableCopy];
                    [channelState enumerateKeysAndObjectsUsingBlock:^(NSString *stateName, id stateData,
                                                                      BOOL *stateDataEnumeratorStop) {
                        
                        // In case if provided data is 'nil' it should be removed from previous state dictionary.
                        if ([stateData isKindOfClass:[NSNull class]]) {
                            
                            [oldChannelState removeObjectForKey:stateName];
                        }
                        else {
                            
                            [oldChannelState setValue:stateData forKey:stateName];
                        }
                    }];
                    
                    if ([oldChannelState count]) {
                        
                        [cleanedState setValue:oldChannelState forKey:channelName];
                    }
                }
            }
            // Ensure that there is not empty dictionary (if dictionary for channel is empty, it mean that
            // user want to remove state from specific channel).
            else if ([channelState count]){
                
                [cleanedState setValue:channelState forKey:channelName];
            }
        }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }];
    
    
    return cleanedState;
}

- (void)storeClientState:(NSDictionary *)clientState forChannel:(PNChannel *)channel {

<<<<<<< HEAD
    if (clientState) {

        if (channel) {
            
            [self.stateCache setValue:clientState forKey:channel.name];
        }
        else {
            
            [clientState enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                                             BOOL *channelsStateEnumeratorStop) {
                
                [self.stateCache setValue:channelState forKey:channelName];
            }];
        }
    }
    else {

        [self purgeStateForChannel:channel];
    }
=======
    [self pn_dispatchAsynchronouslyBlock:^{
        
        if (clientState) {
            
            if (channel) {
                
                [self.stateCache setValue:clientState forKey:channel.name];
            }
            else {
                
                [clientState enumerateKeysAndObjectsUsingBlock:^(NSString *channelName, NSDictionary *channelState,
                                                                 BOOL *channelsStateEnumeratorStop) {
                    
                    [self.stateCache setValue:channelState forKey:channelName];
                }];
            }
        }
        else {
            
            [self purgeStateForChannel:channel];
        }
    }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)storeClientState:(NSDictionary *)clientState forChannels:(NSArray *)channels {
    
<<<<<<< HEAD
    if (clientState) {
        
        NSArray *channelNames = [channels valueForKey:@"name"];
        NSArray *channelsWithState = [clientState allKeys];
        
        [channelsWithState enumerateObjectsUsingBlock:^(NSString *channelName, NSUInteger idx, BOOL *stop) {
            
            if ([channelNames containsObject:channelName] || [self.stateCache valueForKey:channelName] != nil) {
                
                [self.stateCache setValue:[clientState valueForKey:channelName] forKey:channelName];
            }
        }];
    }
    else {
        
        [self purgeStateForChannels:channels];
    }
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {

    return (channel ? [self.stateCache valueForKey:channel.name] : nil);
}

- (NSDictionary *)stateForChannels:(NSArray *)channels {

    NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
    [channelsSet intersectSet:[NSSet setWithArray:[self.stateCache allKeys]]];


    return ([channelsSet count] ? [self.stateCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
=======
    [self pn_dispatchAsynchronouslyBlock:^{
    
        if (clientState) {
            
            NSArray *channelNames = [channels valueForKey:@"name"];
            NSArray *channelsWithState = [clientState allKeys];
            
            [channelsWithState enumerateObjectsUsingBlock:^(NSString *channelName, NSUInteger idx, BOOL *stop) {
                
                if ([channelNames containsObject:channelName] || [self.stateCache valueForKey:channelName] != nil) {
                    
                    [self.stateCache setValue:[clientState valueForKey:channelName] forKey:channelName];
                }
            }];
        }
        else {
            
            [self purgeStateForChannels:channels];
        }
    }];
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {
    
    __block NSDictionary *stateForChannel = nil;
    [self pn_dispatchSynchronouslyBlock:^{
        
        stateForChannel = (channel ? [self.stateCache valueForKey:channel.name] : nil);
    }];

    
    return stateForChannel;
}

- (NSDictionary *)stateForChannels:(NSArray *)channels {
    
    __block NSDictionary *stateForChannels = nil;
    [self pn_dispatchSynchronouslyBlock:^{
        
        NSMutableSet *channelsSet = [NSMutableSet setWithArray:[channels valueForKey:@"name"]];
        [channelsSet intersectSet:[NSSet setWithArray:[self.stateCache allKeys]]];
        
        stateForChannels = ([channelsSet count] ? [self.stateCache dictionaryWithValuesForKeys:[channelsSet allObjects]] : nil);
    }];


    return stateForChannels;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)purgeStateForChannel:(PNChannel *)channel {

    if (channel) {
<<<<<<< HEAD

        [self.stateCache removeObjectForKey:channel.name];
=======
        
        [self pn_dispatchAsynchronouslyBlock:^{

            [self.stateCache removeObjectForKey:channel.name];
        }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }
}

- (void)purgeStateForChannels:(NSArray *)channels {

    if (channels) {
<<<<<<< HEAD

        [self.stateCache removeObjectsForKeys:[channels valueForKey:@"name"]];
=======
        
        [self pn_dispatchAsynchronouslyBlock:^{

            [self.stateCache removeObjectsForKeys:[channels valueForKey:@"name"]];
        }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }
}

- (void)purgeAllState {
<<<<<<< HEAD

    [self.stateCache removeAllObjects];
=======
    
    [self pn_dispatchAsynchronouslyBlock:^{

        [self.stateCache removeAllObjects];
    }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

#pragma mark -


@end
