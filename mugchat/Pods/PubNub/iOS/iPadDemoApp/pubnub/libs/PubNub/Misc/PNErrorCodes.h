//
//  PNErrorCodes.h
//  pubnub
//
//  Describes all available error codes
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark - Client error codes

// Unknown error
static NSInteger const kPNUnknownError = -1;

// PubNub client find out that it wasn't fully configured and can't process his work
static NSInteger const kPNClientConfigurationError = 100;

// PubNub client tried to connect while it already has opened connection to PubNub services
static NSInteger const kPNClientTriedConnectWhileConnectedError = 101;

// PubNub client failed to connect to PubNub services because internet went down
static NSInteger const kPNClientConnectionFailedOnInternetFailureError = 102;

// PubNub client disconnected because of network issues
static NSInteger const kPNClientConnectionClosedOnInternetFailureError = 103;

// PubNub client disconnected because of SSL issues
static NSInteger const kPNClientConnectionClosedOnSSLNegotiationFailureError = 104;

// PubNub client disconnected because of server request (connection refure/reset)
static NSInteger const kPNClientConnectionClosedOnServerRequestError = 105;

// PubNub client disconnected because system wasn't able to initalize and support connection sockets
static NSInteger const kPNClientConnectionClosedOnSocketsError = 106;

// PubNub client failed to execute request because there is no connection which can be used to reach PubNub services
static NSInteger const kPNRequestExecutionFailedOnInternetFailureError = 107;

// PubNub client failed to execute request because of client not ready
static NSInteger const kPNRequestExecutionFailedClientNotReadyError = 108;

// PubNub client failed to execute request because of client suspended
static NSInteger const kPNRequestExecutionFailedClientSuspendedError = 109;

// PubNub client failed to execute request because of timeout
static NSInteger const kPNRequestExecutionFailedByTimeoutError = 110;

// PubNub client failed to use presence API because it is not enabled in used account
static NSInteger const kPNPresenceAPINotAvailableError = 111;

// PubNub service refuse to process request because it has wrong JSON format
static NSInteger const kPNInvalidJSONError = 112;

// PubNub service refuse to process request because it has wrong subscribe/publish key
static NSInteger const kPNInvalidSubscribeOrPublishKeyError = 113;

// PubNub service refuse to process message sending because it is too long
static NSInteger const kPNTooLongMessageError = 114;

<<<<<<< HEAD
// PubNub service reported that restricted characters has been used in channel name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelNameError = 115;

// PubNub service reported that there is no authorization key specified and resource not available w/o it
static NSInteger const kPNAPIUnauthorizedAccessError = 116;

// PubNub service reported that wrong authorization has been used for request
static NSInteger const kPNAPIAccessForbiddenError = 117;
=======
// PubNub service reported that restricted characters has been used in channel group name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelGroupNameError = 115;

// PubNub service reported that restricted characters has been used in channel group namespace name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelGroupNamespaceNameError = 116;

// PubNub service reported that restricted characters has been used in channel name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelNameError = 117;

/**
 @brief PubNub service reported that developer tried to subscribe on channel group which doesn't have any registered
 channels in it.
 
 @since 3.7.0
 */
static NSInteger const kPNEmptyChannelGroupError = 118;

/**
 @brief  PubNub service reported that developer tried to add to many channels into single group and exceeded limit.
 
 @since 3.7.0
 */
static NSInteger const kPNEmptyChannelGroupSizeExceededError = 119;

// PubNub service reported that there is no authorization key specified and resource not available w/o it
static NSInteger const kPNAPIUnauthorizedAccessError = 120;

// PubNub service reported that wrong authorization has been used for request
static NSInteger const kPNAPIAccessForbiddenError = 121;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 \b PubNub service reported that requested API not enabled or not available.
 */
<<<<<<< HEAD
static NSInteger const kPNAPINotAvailableOrNotEnabledError = 118;
=======
static NSInteger const kPNAPINotAvailableOrNotEnabledError = 122;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Scheduled request can't be processed w/o initial API calling based on object data.
 */
<<<<<<< HEAD
static NSInteger const kPNRequestCantBeProcessedWithOutRescheduleError = 119;
=======
static NSInteger const kPNRequestCantBeProcessedWithOutRescheduleError = 123;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Cryptography error

// Developer tried to initialize Cryptor helper with configuration which doesn't has cipher key in it
<<<<<<< HEAD
static NSInteger const kPNCryptoEmptyCipherKeyError = 120;

// Error occurred during cryptor initialization because of error in provided parameters
static NSInteger const kPNCryptoIllegalInitializationParametersError = 121;

// Error occurred because buffer with insufficient size was provided for encrypted/decrypted data output
static NSInteger const kPNCryptoInsufficentBufferSizeError = 122;

// Error occurred in case if during cryptor operation there was not enough memory for it's operation
static NSInteger const kPNCryptoInsufficentMemoryError = 123;

// Error occurred because input data wasn't properly aligned
static NSInteger const kPNCryptoAligmentInputDataError = 124;

// Error occurred during input data encode/decode process
static NSInteger const kPNCryptoInputDataProcessingError = 125;

// Error occurred if developer try to use one of features which is not available in specified algorithm
static NSInteger const kPNCryptoUnavailableFeatureError = 126;
=======
static NSInteger const kPNCryptoEmptyCipherKeyError = 124;

// Error occurred during cryptor initialization because of error in provided parameters
static NSInteger const kPNCryptoIllegalInitializationParametersError = 125;

// Error occurred because buffer with insufficient size was provided for encrypted/decrypted data output
static NSInteger const kPNCryptoInsufficentBufferSizeError = 126;

// Error occurred in case if during cryptor operation there was not enough memory for it's operation
static NSInteger const kPNCryptoInsufficentMemoryError = 127;

// Error occurred because input data wasn't properly aligned
static NSInteger const kPNCryptoAligmentInputDataError = 128;

// Error occurred during input data encode/decode process
static NSInteger const kPNCryptoInputDataProcessingError = 129;

// Error occurred if developer try to use one of features which is not available in specified algorithm
static NSInteger const kPNCryptoUnavailableFeatureError = 130;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Developers error (caused by developer)

// Developer tries to submit empty (nil) request by passing no message object to PubNub service
<<<<<<< HEAD
static NSInteger const kPNMessageObjectError = 127;

// Developer tried to submit message w/o text to PubNub service
static NSInteger const kPNMessageHasNoContentError = 128;

// Developer tried to submit message w/o target channel to PubNub service
static NSInteger const kPNMessageHasNoChannelError = 129;
=======
static NSInteger const kPNMessageObjectError = 131;

// Developer tried to submit message w/o text to PubNub service
static NSInteger const kPNMessageHasNoContentError = 132;

// Developer tried to submit message w/o target channel to PubNub service
static NSInteger const kPNMessageHasNoChannelError = 133;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Developer tried to push state w/ invalid content (used keys with forbidden prefix or unsupported values).
 */
<<<<<<< HEAD
static NSInteger const kPNInvalidStatePayloadError = 130;
=======
static NSInteger const kPNInvalidStatePayloadError = 134;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Developer tried to push state for channel on which client not subscribed at this moment.
 */
<<<<<<< HEAD
static NSInteger const kPNCantUpdateStateForNotSubscribedChannelsError = 131;

// Developer tried to use APNS API w/o enabling push notifications support on admin.punub.com
static NSInteger const kPNPushNotificationsNotEnabledError = 132;
=======
static NSInteger const kPNCantUpdateStateForNotSubscribedChannelsError = 135;

// Developer tried to use APNS API w/o enabling push notifications support on admin.punub.com
static NSInteger const kPNPushNotificationsNotEnabledError = 136;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

/**
 Developer tried to use PAM API w/o specifying \a 'secret' key.
 */
<<<<<<< HEAD
static NSInteger const kPNSecretKeyNotSpecifiedError = 133;

// Developer tried to use empty device push notification to enable push notification on specified channel
static NSInteger const kPNDevicePushTokenIsEmptyError = 134;

// Developer tried to to obtain history in the same time when it is disabled on portal.
static NSInteger const kPNStorageNotEnabledError = 135;
=======
static NSInteger const kPNSecretKeyNotSpecifiedError = 137;

// Developer tried to use empty device push notification to enable push notification on specified channel
static NSInteger const kPNDevicePushTokenIsEmptyError = 138;

// Developer tried to to obtain history in the same time when it is disabled on portal.
static NSInteger const kPNStorageNotEnabledError = 139;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Service error (caused by remote server)

// Server responded that developer used concrete API too much and exceeded access rate.
<<<<<<< HEAD
static NSInteger const kPNAPIRateExceededError = 136;

// Server provided response which can't be decoded with UTF8
static NSInteger const kPNResponseEncodingError = 137;

// Server provided response with malformed JSON in it (in such cases library will try to resend request to
// remote origin)
static NSInteger const kPNResponseMalformedJSONError = 138;
=======
static NSInteger const kPNAPIRateExceededError = 140;

// Server provided response which can't be decoded with UTF8
static NSInteger const kPNResponseEncodingError = 141;

// Server provided response with malformed JSON in it (in such cases library will try to resend request to
// remote origin)
static NSInteger const kPNResponseMalformedJSONError = 142;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Connection (transport layer) error codes

// Was unable to configure connection because of some errors
<<<<<<< HEAD
static NSInteger const kPNConnectionErrorOnSetup = 139;
=======
static NSInteger const kPNConnectionErrorOnSetup = 143;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
