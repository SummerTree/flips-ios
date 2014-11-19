//
//  PNWhereNowRequest.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNWhereNowRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
<<<<<<< HEAD
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
=======
#import "PNConfiguration.h"
#import "PNMacro.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark Private interface declaration

@interface PNWhereNowRequest ()


#pragma mark - Properties

<<<<<<< HEAD
@property (nonatomic, copy) NSString *clientIdentifier;
=======
/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNWhereNowRequest


#pragma mark - Class methods

+ (PNWhereNowRequest *)whereNowRequestForIdentifier:(NSString *)clientIdentifier {

    return [[self alloc] initWithIdentifier:clientIdentifier];
}


#pragma mark - Instance methods

- (id)initWithIdentifier:(NSString *)clientIdentifier {

    // Check whether initialization has been successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.clientIdentifier = clientIdentifier;
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

    return PNServiceResponseCallbacks.participantChannelsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v2/presence/sub-key/%@/uuid/%@?callback=%@_%@%@&pnsdk=%@",
<<<<<<< HEAD
                                      [[PubNub sharedInstance].configuration.subscriptionKey pn_percentEscapedString],
=======
                                      [self.subscriptionKey pn_percentEscapedString],
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
                                      [self.clientIdentifier pn_percentEscapedString], [self callbackMethodName],
                                      self.shortIdentifier,
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@",
                                                                                              [self authorizationField]] : @""),
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
