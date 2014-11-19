//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  message sending request which will be
//  scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/28/12.
//
//

#import "PNMessagePostRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNMessage+Protected.h"
#import "PNChannel+Protected.h"
<<<<<<< HEAD
#import "PubNub+Protected.h"
#import "PNLoggerSymbols.h"
#import "PNCryptoHelper.h"
#import "PNConstants.h"
#import "PNHelper.h"
=======
#import "PNLoggerSymbols.h"
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNHelper.h"
#import "PNMacro.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


// ARC check
#if !__has_feature(objc_arc)
#error PubNub message post request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNMessagePostRequest ()


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, strong) PNMessage *message;

// Stores reference on prepared message
@property (nonatomic, strong) NSString *preparedMessage;

<<<<<<< HEAD
// Stores reference on client identifier on the
// moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;
=======
@property (nonatomic, copy) NSString *subscriptionKey;
@property (nonatomic, copy) NSString *publishKey;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Instance methods

/**
 * Retrieve message post request signature
 */
- (NSString *)signature;


@end


#pragma mark Public interface methods

@implementation PNMessagePostRequest


#pragma mark - Class methods

+ (PNMessagePostRequest *)postMessageRequestWithMessage:(PNMessage *)message; {

    return [[[self class] alloc] initWithMessage:message];
}


#pragma mark - Instance methods

- (id)initWithMessage:(PNMessage *)message {

    // Check whether initialization was successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.message = message;
<<<<<<< HEAD
        self.clientIdentifier = [PubNub escapedClientIdentifier];
=======
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }


    return self;
}

<<<<<<< HEAD
=======
- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.publishKey = configuration.publishKey;
    self.clientIdentifier = clientIdentifier;
}

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.sendMessageCallback;
}

- (PNRequestHTTPMethod)HTTPMethod {
    
    return self.message.shouldCompressMessage ? PNRequestPOSTMethod : PNRequestGETMethod;
}

- (BOOL)shouldCompressPOSTBody {
    
    return self.message.shouldCompressMessage;
}

- (NSData *)POSTBody {
    
    return [self.preparedMessage dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)preparedMessage {
    
    if (_preparedMessage == nil) {
        
        id message = self.message.message;
<<<<<<< HEAD
        if ([message isKindOfClass:[NSNumber class]]) {
            
            message = [(NSNumber *)message stringValue];
        }
        
        // Retrieve reference on encrypted message (if possible)
        PNError *encryptionError;
        if ([PNCryptoHelper sharedInstance].isReady) {
            
            message = [PubNub AESEncrypt:message error:&encryptionError];
            
            if (encryptionError != nil) {

                [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{

                    return @[PNLoggerSymbols.requests.messagePost.messageBodyEncryptionError,
                            (encryptionError ? encryptionError : [NSNull null])];
                }];
            }
        }
=======
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
        
        if ([self HTTPMethod] == PNRequestGETMethod) {
            
            // Encode message with % so it will be delivered w/o damages to
            // the PubNub service
#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            self.preparedMessage = [message pn_percentEscapedString];
#else
            self.preparedMessage = [message pn_nonStringPercentEscapedString];
#endif
        }
        else {
            
            self.preparedMessage = message;
        }
    }
    
    
    return _preparedMessage;
}

- (NSString *)resourcePath {
    
    NSMutableString *resourcePath = [NSMutableString stringWithFormat:@"/publish/%@/%@/%@/%@/%@_%@",
<<<<<<< HEAD
                                                                      [[PubNub sharedInstance].configuration.publishKey pn_percentEscapedString],
                                                                      [[PubNub sharedInstance].configuration.subscriptionKey pn_percentEscapedString],
=======
                                                                      [self.publishKey pn_percentEscapedString],
                                                                      [self.subscriptionKey pn_percentEscapedString],
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
                                                                      [self signature],
                                                                      [self.message.channel escapedName],
                                                                      [self callbackMethodName],
                                                                      self.shortIdentifier];
    
    if (!self.message.shouldCompressMessage) {
        
        [resourcePath appendFormat:@"/%@", self.preparedMessage];
    }
    
<<<<<<< HEAD
    [resourcePath appendFormat:@"?uuid=%@%@&pnsdk=%@", self.clientIdentifier,
=======
    [resourcePath appendFormat:@"?uuid=%@%@&pnsdk=%@", [self.clientIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
                               ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
                               [self clientInformationField]];
    
    if (!self.message.shouldStoreInHistory) {
        
        [resourcePath appendString:@"&store=0"];
    }
    

    return resourcePath;
}

- (NSString *)debugResourcePath {
<<<<<<< HEAD

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:2 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.publishKey pn_percentEscapedString])];
    [resourcePathComponents replaceObjectAtIndex:3 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey pn_percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
=======
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    NSString *publishKey = [self.publishKey pn_percentEscapedString];
    NSString *debugResourcePath = [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];

    
    return [debugResourcePath stringByReplacingOccurrencesOfString:publishKey withString:PNObfuscateString(publishKey)];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSString *)signature {

    NSString *signature = @"0";
#if PN_SHOULD_USE_SIGNATURE
<<<<<<< HEAD
    NSString *secretKey = [PubNub sharedInstance].configuration.secretKey;
    if ([secretKey length] > 0) {

        NSString *signedRequestPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@%@",
                        [PubNub sharedInstance].configuration.publishKey,
                        [PubNub sharedInstance].configuration.subscriptionKey, secretKey,
                        [self.message.channel escapedName], self.message.message,
=======
    NSString *secretKey = self.secretKey;
    if ([secretKey length] > 0) {

        NSString *signedRequestPath = [NSString stringWithFormat:@"%@/%@/%@/%@/%@%@", self.publishKey, self.subscriptionKey,
                                       secretKey, [self.message.channel escapedName], self.message.message,
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
                        ([self authorizationField] ? [NSString stringWithFormat:@"?%@", [self authorizationField]] : @""),
                        ([self authorizationField] ? [NSString stringWithFormat:@"&pnsdk=%@", [self clientInformationField]] :
                                                     [NSString stringWithFormat:@"?pnsdk=%@", [self clientInformationField]])];
        
        signature = [PNEncryptionHelper HMACSHA256FromString:signedRequestPath withKey:secretKey];
    }
#endif

    return signature;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
