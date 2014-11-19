/**

 @author Sergey Mamontov
 @version 3.6.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNClient+Protected.h"
<<<<<<< HEAD
#import "PNConstants.h"
#import "PNChannel.h"
=======
#import "PNChannel+Protected.h"
#import "PNChannelGroup.h"
#import "PNConstants.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark Public interface implementation

@implementation PNClient


#pragma mark - Class methods

+ (PNClient *)anonymousClient {

    return [self clientForIdentifier:nil channel:nil andData:nil ];
}

+ (PNClient *)anonymousClientForChannel:(PNChannel *)channel {

    return [self clientForIdentifier:nil channel:channel andData:nil ];
}

+ (PNClient *)clientForIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data {
<<<<<<< HEAD

   return [[self alloc] initWithIdentifier:identifier channel:channel andData:data];
}


=======
    
    return [[self alloc] initWithIdentifier:identifier channel:channel andData:data];
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)identifier channel:(PNChannel *)channel andData:(NSDictionary *)data {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {
<<<<<<< HEAD

        self.identifier = identifier ? identifier : kPNAnonymousParticipantIdentifier;
        self.channel = channel;
        self.data = data;
=======
            
        self.identifier = identifier ? identifier : kPNAnonymousParticipantIdentifier;
        self.clientData = [NSMutableDictionary dictionary];
        self.channelsWithState = [NSMutableArray array];
        self.channel = channel;
        [self addClientData:data forChannel:channel];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }


    return self;
}

<<<<<<< HEAD
=======
- (void)setChannel:(PNChannel *)channel {
    
    if (!channel.isChannelGroup) {
        
        _channel = channel;
    }
    else {
        
        _group = (PNChannelGroup *)channel;
    }
    if (self.unboundData) {
        
        [self addClientData:self.unboundData forChannel:channel];
        self.unboundData = nil;
    }
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
- (BOOL)isAnonymous {

    return [self.identifier isEqualToString:kPNAnonymousParticipantIdentifier];
}

<<<<<<< HEAD
=======
- (NSArray *)channels {
    
    return self.channelsWithState;
}

- (NSDictionary *)stateForChannel:(PNChannel *)channel {
    
    return (channel ? [self.clientData valueForKey:channel.name] : nil);
}

- (void)addClientData:(NSDictionary *)data forChannel:(PNChannel *)channel {
    
    if (data) {
        
        if (channel) {
            
            if (![self.channelsWithState containsObject:channel]) {
                
                [self.channelsWithState addObject:channel];
            }
            
            [self.clientData setValue:data forKey:channel.name];
        }
        else {
            
            self.unboundData = data;
        }
    }
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

#pragma mark - Misc methods

- (NSString *)description {

<<<<<<< HEAD
    return [NSString stringWithFormat:@"%@(%p) %@ on \"%@\" channel (%@)", NSStringFromClass([self class]), self,
                    self.identifier, self.channel.name, self.data];
=======
    return [NSString stringWithFormat:@"%@(%p) %@ on (%@) channel (%@)", NSStringFromClass([self class]), self,
            self.identifier, [[self.channels valueForKey:@"name"] componentsJoinedByString:@","], self.clientData];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
<<<<<<< HEAD
    return [NSString stringWithFormat:@"<%@|%@|%@>", (self.identifier ? self.identifier : [NSNull null]),
            (self.channel.name ? self.channel.name : [NSNull null]),
            (self.data ? [self.data performSelector:@selector(logDescription)] : [NSNull null])];
=======
    return [NSString stringWithFormat:@"<%@|%@|%@|%@>", (self.identifier ? self.identifier : [NSNull null]),
            (self.channels ? [self.clientData performSelector:@selector(logDescription)] : [NSNull null]),
            (self.group.name ? self.group.name : [NSNull null]),
            (self.clientData ? [self.clientData performSelector:@selector(logDescription)] : [NSNull null])];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    #pragma clang diagnostic pop
}

#pragma mark -


@end
