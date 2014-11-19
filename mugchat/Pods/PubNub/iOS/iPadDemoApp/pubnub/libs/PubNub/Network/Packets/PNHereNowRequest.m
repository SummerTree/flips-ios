//
//  PNHereNowRequest.h
// 
//
//  Created by moonlight on 1/22/13.
//
//


#import "PNHereNowRequest.h"
#import "PNChannel+Protected.h"
#import "NSString+PNAddition.h"
#import "PNRequestsImport.h"
<<<<<<< HEAD
#import "PubNub+Protected.h"
=======
#import "PNConfiguration.h"
#import "PNMacro.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


// ARC check
#if !__has_feature(objc_arc)
#error PubNub here now request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNHereNowRequest ()


#pragma mark - Properties

<<<<<<< HEAD
// Stores reference on channel for which participants list will be requested
@property (nonatomic, strong) PNChannel *channel;

/**
 Stores whether request should fetch client identifiers or just get number of participants.
 */
@property (nonatomic, assign, getter = isClientIdentifiersRequired) BOOL clientIdentifiersRequired;

/**
 Stores whether request should fetch client's state or not.
 */
@property (nonatomic, assign, getter = shouldFetchClientState) BOOL fetchClientState;
=======
@property (nonatomic, strong) NSArray *channels;
@property (nonatomic, assign, getter = isClientIdentifiersRequired) BOOL clientIdentifiersRequired;
@property (nonatomic, assign, getter = shouldFetchClientState) BOOL fetchClientState;
@property (nonatomic, copy) NSString *subscriptionKey;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


@end


@implementation PNHereNowRequest


#pragma mark Class methods

<<<<<<< HEAD
+ (PNHereNowRequest *)whoNowRequestForChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                  clientState:(BOOL)shouldFetchClientState {

    return [[[self class] alloc] initWithChannel:channel clientIdentifiersRequired:isClientIdentifiersRequired
                                     clientState:shouldFetchClientState];
=======
+ (PNHereNowRequest *)whoNowRequestForChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
                                   clientState:(BOOL)shouldFetchClientState {

    return [[[self class] alloc] initWithChannels:channels clientIdentifiersRequired:isClientIdentifiersRequired
                                      clientState:shouldFetchClientState];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Instance methods

<<<<<<< HEAD
- (id)initWithChannel:(PNChannel *)channel clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
=======
- (id)initWithChannels:(NSArray *)channels clientIdentifiersRequired:(BOOL)isClientIdentifiersRequired
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
          clientState:(BOOL)shouldFetchClientState {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
<<<<<<< HEAD
        self.channel = channel;
=======
        self.channels = channels;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
        self.clientIdentifiersRequired = isClientIdentifiersRequired;
        self.fetchClientState = shouldFetchClientState;
    }


    return self;
}

<<<<<<< HEAD
=======
- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.channelParticipantsCallback;
}

- (NSString *)resourcePath {
<<<<<<< HEAD

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@%@?callback=%@_%@&disable_uuids=%@&state=%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey pn_percentEscapedString],
                                      (self.channel ? [NSString stringWithFormat:@"/channel/%@",
                                                                                 [self.channel escapedName]] : @""),
                                      [self callbackMethodName],
                                      self.shortIdentifier,
                                      (self.isClientIdentifiersRequired ? @"0" : @"1"),
                                      (self.shouldFetchClientState ? @"1" : @"0"),
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@",
                                                                                              [self authorizationField]] : @""),
=======
    
    NSString *channelsList = nil;
    NSString *groupsList = nil;
    if ([self.channels count]) {
        
        NSArray *channels = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = NO"]];
        NSArray *groups = [self.channels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = YES"]];
        if ([channels count]) {
            
            channelsList = [[channels valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
        if ([groups count]) {
            
            groupsList = [[groups valueForKey:@"escapedName"] componentsJoinedByString:@","];
            if (!channelsList) {
                
                channelsList = @",";
            }
        }
    }

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@%@?callback=%@_%@&disable_uuids=%@&state=%@%@%@&pnsdk=%@",
                                      [self.subscriptionKey pn_percentEscapedString],
                                      (channelsList ? [NSString stringWithFormat:@"/channel/%@", channelsList] : @""),
                                      [self callbackMethodName], self.shortIdentifier, (self.isClientIdentifiersRequired ? @"0" : @"1"),
                                      (self.shouldFetchClientState ? @"1" : @"0"),
                                      (groupsList ? [NSString stringWithFormat:@"&channel-group=%@", groupsList] : @""),
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {
<<<<<<< HEAD

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey pn_percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
=======
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
