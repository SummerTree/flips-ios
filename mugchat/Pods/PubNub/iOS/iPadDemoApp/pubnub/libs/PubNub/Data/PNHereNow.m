/**

 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.

 */

#import "PNHereNow+Protected.h"
<<<<<<< HEAD
=======
#import "PNChannel.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


<<<<<<< HEAD
#pragma mark Externs
=======
#pragma mark Structures

struct PNChannelParticipantsEntryStructure {
    
    // List of \b PNChannel instances stored under this key
    __unsafe_unretained NSString *participants;
    
    // Number of channel participants stored under this key
    __unsafe_unretained NSString *participantsCount;
};

struct PNChannelParticipantsEntryStructure PNChannelParticipantsEntry = {
    
    .participants = @"participants",
    .participantsCount = @"count"
};


#pragma mark - Externs
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Used for \b PNClient instances in case if client identifier is unknown.
 */
NSString * const kPNAnonymousParticipantIdentifier = @"unknown";


#pragma mark - Public interface methods

@implementation PNHereNow


<<<<<<< HEAD
=======
#pragma mark - Instance methods

- (instancetype)init {
    
    // Check whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.participantsMap = [NSMutableDictionary dictionary];
    }
    
    
    return self;
}

- (NSArray *)channels {
    
    return ([self.participantsMap count] ? [PNChannel channelsWithNames:[self.participantsMap allKeys]] : @[]);
}

- (NSArray *)participantsForChannel:(PNChannel *)channel {
    
    return [[[self presenceInformationForChannel:channel] valueForKey:PNChannelParticipantsEntry.participants] copy];
}

- (void)addParticipant:(PNClient *)participant forChannel:(PNChannel *)channel {
    
    [[[self presenceInformationForChannel:channel] valueForKey:PNChannelParticipantsEntry.participants] addObject:participant];
}

- (NSUInteger)participantsCountForChannel:(PNChannel *)channel {
    
    return [[[self presenceInformationForChannel:channel] valueForKey:PNChannelParticipantsEntry.participantsCount] unsignedIntegerValue];
}

- (void)setParticipantsCount:(NSUInteger)count forChannel:(PNChannel *)channel {
    
    [[self presenceInformationForChannel:channel] setValue:@(count) forKey:PNChannelParticipantsEntry.participantsCount];
}


#pragma mark - Misc method

- (NSMutableDictionary *)presenceInformationForChannel:(PNChannel *)channel {
    
    NSMutableDictionary *information = nil;
    if (channel) {
        
        information = [self.participantsMap valueForKey:channel.name];
        if (!information) {
            
            information = [@{PNChannelParticipantsEntry.participants:[NSMutableArray array],
                             PNChannelParticipantsEntry.participantsCount:@(0)} mutableCopy];
            
            [self.participantsMap setValue:information forKey:channel.name];
        }
    }
    
    
    return information;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"%@", self.participantsMap];
}

- (NSString *)logDescription {
    
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [NSString stringWithFormat:@"<%@>", 
            (self.participantsMap ? [self.participantsMap performSelector:@selector(logDescription)] : [NSNull null])];
    #pragma clang diagnostic pop
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
#pragma mark -


@end
