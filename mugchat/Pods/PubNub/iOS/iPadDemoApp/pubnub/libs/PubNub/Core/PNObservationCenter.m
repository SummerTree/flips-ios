//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNObservationCenter+Protected.h"
#import "PNMessagesHistory+Protected.h"
<<<<<<< HEAD
#import "PNHereNow+Protected.h"
#import "PNError+Protected.h"
#import "PubNub+Protected.h"
#import "PNNotifications.h"
#import "PNLoggerSymbols.h"
#import "PNClient.h"
=======
#import "PNChannelGroupChange.h"
#import "NSObject+PNAdditions.h"
#import "PNHereNow+Protected.h"
#import "PNError+Protected.h"
#import "PNNotifications.h"
#import "PNLoggerSymbols.h"
#import "PNWhereNow.h"
#import "PNChannel.h"
#import "PNClient.h"
#import "PNMacro.h"
#import "PubNub.h"
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


// ARC check
#if !__has_feature(objc_arc)
#error PubNub observation center must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on shared observation center instance
static PNObservationCenter *_sharedInstance = nil;
static dispatch_once_t onceToken;


struct PNObservationEventsStruct {

    __unsafe_unretained NSString *clientConnectionStateChange;
    __unsafe_unretained NSString *clientMetadataRetrieval;
    __unsafe_unretained NSString *clientMetadataUpdate;
<<<<<<< HEAD
=======
    __unsafe_unretained NSString *clientChannelGroupsRequest;
    __unsafe_unretained NSString *clientChannelGroupNamespacesRequest;
    __unsafe_unretained NSString *clientChannelGroupNamespaceRemoval;
    __unsafe_unretained NSString *clientChannelGroupRemoval;
    __unsafe_unretained NSString *clientChannelsForGroupRequest;
    __unsafe_unretained NSString *clientChannelsAdditionToGroup;
    __unsafe_unretained NSString *clientChannelsRemovalFromGroup;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    __unsafe_unretained NSString *clientSubscriptionOnChannels;
    __unsafe_unretained NSString *clientUnsubscribeFromChannels;
    __unsafe_unretained NSString *clientPresenceEnableOnChannels;
    __unsafe_unretained NSString *clientPresenceDisableOnChannels;
    __unsafe_unretained NSString *clientPushNotificationEnabling;
    __unsafe_unretained NSString *clientPushNotificationDisabling;
    __unsafe_unretained NSString *clientPushNotificationEnabledChannelsRetrieval;
    __unsafe_unretained NSString *clientPushNotificationRemovalForAllChannels;
    __unsafe_unretained NSString *clientTimeTokenReceivingComplete;
    __unsafe_unretained NSString *clientAccessRightsChange;
    __unsafe_unretained NSString *clientAccessRightsAudit;
    __unsafe_unretained NSString *clientMessageSendCompletion;
    __unsafe_unretained NSString *clientReceivedMessage;
    __unsafe_unretained NSString *clientReceivedPresenceEvent;
    __unsafe_unretained NSString *clientReceivedHistory;
    __unsafe_unretained NSString *clientReceivedParticipantsList;
    __unsafe_unretained NSString *clientParticipantChannelsList;
};

struct PNObservationObserverDataStruct {

    __unsafe_unretained NSString *observer;
    __unsafe_unretained NSString *observerCallbackBlock;
};

static struct PNObservationEventsStruct PNObservationEvents = {

    .clientConnectionStateChange = @"clientConnectionStateChangeEvent",
    .clientMetadataRetrieval = @"clientMetadataRetrieveEvent",
    .clientMetadataUpdate = @"clientMedataUpdateEvent",
<<<<<<< HEAD
=======
    .clientChannelGroupsRequest = @"clientChannelGroupsRequest",
    .clientChannelGroupNamespacesRequest = @"clientChannelGroupNamespacesRequest",
    .clientChannelGroupNamespaceRemoval = @"clientChannelGroupNamespaceRemoval",
    .clientChannelGroupRemoval = @"clientChannelGroupRemoval",
    .clientChannelsForGroupRequest = @"clientChannelsForGroupRequest",
    .clientChannelsAdditionToGroup = @"clientChannelsAdditionToGroup",
    .clientChannelsRemovalFromGroup = @"clientChannelsRemovalFromGroup",
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    .clientTimeTokenReceivingComplete = @"clientReceivingTimeTokenEvent",
    .clientSubscriptionOnChannels = @"clientSubscribtionOnChannelsEvent",
    .clientUnsubscribeFromChannels = @"clientUnsubscribeFromChannelsEvent",
    .clientPresenceEnableOnChannels = @"clientPresenceEnableOnChannels",
    .clientPresenceDisableOnChannels = @"clientPresenceDisableOnChannels",
    .clientPushNotificationEnabling = @"clientPushNotificationEnabling",
    .clientPushNotificationDisabling = @"clientPushNotificationDisabling",
    .clientPushNotificationEnabledChannelsRetrieval = @"clientPushNotificationEnabledChannelsRetrieval",
    .clientPushNotificationRemovalForAllChannels = @"clientPushNotificationRemovalForAllChannels",
    .clientAccessRightsChange = @"clientAccessRightsChange",
    .clientAccessRightsAudit = @"clientAccessRightsAudit",
    .clientMessageSendCompletion = @"clientMessageSendCompletionEvent",
    .clientReceivedMessage = @"clientReceivedMessageEvent",
    .clientReceivedPresenceEvent = @"clientReceivedPresenceEvent",
    .clientReceivedHistory = @"clientReceivedHistoryEvent",
    .clientReceivedParticipantsList = @"clientReceivedParticipantsListEvent",
    .clientParticipantChannelsList = @"clientParticipantChannelsProcessingEvent"
};

static struct PNObservationObserverDataStruct PNObservationObserverData = {

    .observer = @"observer",
    .observerCallbackBlock = @"observerCallbackBlock"
};


#pragma mark - Private interface methods

@interface PNObservationCenter ()


#pragma mark - Properties

<<<<<<< HEAD
// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
@property (nonatomic, strong) NSMutableDictionary *observers;

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
// This is FIFO observer type which means that as soon as event
// will occur observer will be removed from list
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;

=======
/**
 Stores mapped observers to events wich they want to track and execution block provided by subscriber.
 */
@property (nonatomic, strong) NSMutableDictionary *observers;

/**
 Stores mapped observers to events wich they want to track and execution block provided by subscriber.
 This is FIFO observer type which means that as soon as event will occur observer will be removed from list.
 */
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;

/**
 Stores reference on default observer which should be used by simplified observation methods.
 */
@property (nonatomic, pn_desired_weak) id defaultObserver;

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

#pragma mark - Instance methods

/**
 * Helper methods which will create collection for specified
 * event name if it doesn't exist or return existing.
 */
- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName;
- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName;

- (void)removeOneTimeObserversForEvent:(NSString *)eventName;

/**
 * Managing observation list
 */
- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block;
- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent;


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification;
- (void)handleClientMetadataRetrieveProcess:(NSNotification *)notification;
- (void)handleClientMetadataUpdateProcess:(NSNotification *)notification;
- (void)handleClientSubscriptionProcess:(NSNotification *)notification;
<<<<<<< HEAD
=======
- (void)handleClientChannelGroupsRequestProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupNamespacesRequestProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupNamespacesRemovalProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupRemovalProcess:(NSNotification *)notification;
- (void)handleClientChannelsForGroupRequestProcess:(NSNotification *)notification;
- (void)handleClientGroupChannelsListModificationProcess:(NSNotification *)notification;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationStateChange:(NSNotification *)notification;
- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification;
- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification;
- (void)handleClientDidReceiveMessage:(NSNotification *)notification;
- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification;
- (void)handleClientMessageHistoryProcess:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsChange:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsRequest:(NSNotification *)notification;
- (void)handleClientHereNowProcess:(NSNotification *)notification;
- (void)handleClientWhereNowProcess:(NSNotification *)notification;
- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification;


#pragma mark - Misc methods

/**
 * Retrieve full list of observers for specified event name
 */
- (NSMutableArray *)observersForEvent:(NSString *)eventName;


@end


#pragma mark - Public interface methods

@implementation PNObservationCenter


#pragma mark Class methods

+ (PNObservationCenter *)defaultCenter {

    dispatch_once(&onceToken, ^{
        
<<<<<<< HEAD
        _sharedInstance = [[[self class] alloc] init];
=======
        _sharedInstance = [self new];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    });
    
    
    return _sharedInstance;
}

<<<<<<< HEAD
+ (void)resetCenter {

    // Resetting one time observers (they bound to PubNub client instance)
    [[self defaultCenter].oneTimeObservers removeAllObjects];
}

=======
+ (PNObservationCenter *)observationCenterWithDefaultObserver:(id)defaultObserver; {
    
    return [[self alloc] initWithDefaultObserver:defaultObserver];
}

+ (void)resetCenter {
    
    [[self defaultCenter] pn_dispatchSynchronouslyBlock:^{
        
        // Resetting one time observers (they bound to PubNub client instance)
        [[self defaultCenter].oneTimeObservers removeAllObjects];
    }];
}
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

#pragma mark - Instance methods

- (id)init {
    
<<<<<<< HEAD
=======
    return [self initWithDefaultObserver:nil];
}

- (id)initWithDefaultObserver:(id)defaultObserver {
    
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.observers = [NSMutableDictionary dictionary];
        self.oneTimeObservers = [NSMutableDictionary dictionary];
<<<<<<< HEAD
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidConnectToOriginNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidDisconnectFromOriginNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientConnectionDidFailWithErrorNotification object:nil];

        [notificationCenter addObserver:self selector:@selector(handleClientMetadataRetrieveProcess:)
                                   name:kPNClientDidReceiveClientStateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataRetrieveProcess:)
                                   name:kPNClientStateRetrieveDidFailWithErrorNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataUpdateProcess:)
                                   name:kPNClientDidUpdateClientStateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataUpdateProcess:)
                                   name:kPNClientStateUpdateDidFailWithErrorNotification object:nil];


        // Handle subscription events
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionWillRestoreNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidRestoreNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidFailNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidFailNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification object:nil];

        // Handle presence events
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidFailNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidFailNotification object:nil];


        // Handle push notification state changing events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationEnableDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationEnableDidFailNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationDisableDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationDisableDidFailNotification object:nil];


        // Handle push notification remove events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationRemoveProcess:)
                                   name:kPNClientPushNotificationRemoveDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationRemoveProcess:)
                                   name:kPNClientPushNotificationRemoveDidFailNotification object:nil];


        // Handle push notification enabled channels retrieve events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationEnabledChannels:)
                                   name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationEnabledChannels:)
                                   name:kPNClientPushNotificationChannelsRetrieveDidFailNotification object:nil];


        // Handle access rights change events
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsChange:)
                                   name:kPNClientAccessRightsChangeDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsChange:)
                                   name:kPNClientAccessRightsChangeDidFailNotification object:nil];


        // Handle access rights audit events
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsRequest:)
                                   name:kPNClientAccessRightsAuditDidCompleteNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsRequest:)
                                   name:kPNClientAccessRightsAuditDidFailNotification object:nil];


        // Handle time token events
        [notificationCenter addObserver:self selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidReceiveTimeTokenNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidFailTimeTokenReceiveNotification object:nil];


        // Handle message processing events
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientWillSendMessageNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientDidSendMessageNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientMessageSendingDidFailNotification object:nil];

        // Handle messages/presence event arrival
        [notificationCenter addObserver:self selector:@selector(handleClientDidReceiveMessage:)
                                   name:kPNClientDidReceiveMessageNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientDidReceivePresenceEvent:)
                                   name:kPNClientDidReceivePresenceEventNotification object:nil];

        // Handle message history events arrival
        [notificationCenter addObserver:self selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientDidReceiveMessagesHistoryNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientHistoryDownloadFailedWithErrorNotification object:nil];

        // Handle participants list arrival
        [notificationCenter addObserver:self selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientDidReceiveParticipantsListNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientParticipantsListDownloadFailedWithErrorNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientWhereNowProcess:)
                                   name:kPNClientDidReceiveParticipantChannelsListNotification object:nil];
        [notificationCenter addObserver:self selector:@selector(handleClientWhereNowProcess:)
                                   name:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification object:nil];
=======
        self.defaultObserver = (defaultObserver ? defaultObserver : [PubNub sharedInstance]);
        
        dispatch_queue_t targetQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self pn_setPrivateDispatchQueue:[self pn_serialQueueWithOwnerIdentifier:@"observer" andTargetQueue:targetQueue]];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidConnectToOriginNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidDisconnectFromOriginNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientConnectionDidFailWithErrorNotification object:self.defaultObserver];
        
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataRetrieveProcess:)
                                   name:kPNClientDidReceiveClientStateNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataRetrieveProcess:)
                                   name:kPNClientStateRetrieveDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataUpdateProcess:)
                                   name:kPNClientDidUpdateClientStateNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMetadataUpdateProcess:)
                                   name:kPNClientStateUpdateDidFailWithErrorNotification object:self.defaultObserver];
        
        // Handle channel registry events
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupsRequestProcess:)
                                   name:kPNClientChannelGroupsRequestCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupsRequestProcess:)
                                   name:kPNClientChannelGroupsRequestDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupNamespacesRequestProcess:)
                                   name:kPNClientChannelGroupNamespacesRequestCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupNamespacesRequestProcess:)
                                   name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupNamespacesRemovalProcess:)
                                   name:kPNClientChannelGroupNamespaceRemovalCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupNamespacesRemovalProcess:)
                                   name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupRemovalProcess:)
                                   name:kPNClientChannelGroupRemovalCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelGroupRemovalProcess:)
                                   name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelsForGroupRequestProcess:)
                                   name:kPNClientChannelsForGroupRequestCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelsForGroupRequestProcess:)
                                   name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientGroupChannelsListModificationProcess:)
                                   name:kPNClientGroupChannelsAdditionCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientGroupChannelsListModificationProcess:)
                                   name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientGroupChannelsListModificationProcess:)
                                   name:kPNClientGroupChannelsRemovalCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientGroupChannelsListModificationProcess:)
                                   name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification object:self.defaultObserver];
        
        // Handle subscription events
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification
                                 object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionWillRestoreNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidRestoreNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidFailNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification
                                 object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification
                                 object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidFailNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification
                                 object:self.defaultObserver];
        
        // Handle presence events
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidFailNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidFailNotification object:self.defaultObserver];
        
        
        // Handle push notification state changing events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationEnableDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationEnableDidFailNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationDisableDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationStateChange:)
                                   name:kPNClientPushNotificationDisableDidFailNotification object:self.defaultObserver];
        
        
        // Handle push notification remove events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationRemoveProcess:)
                                   name:kPNClientPushNotificationRemoveDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationRemoveProcess:)
                                   name:kPNClientPushNotificationRemoveDidFailNotification object:self.defaultObserver];
        
        
        // Handle push notification enabled channels retrieve events
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationEnabledChannels:)
                                   name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientPushNotificationEnabledChannels:)
                                   name:kPNClientPushNotificationChannelsRetrieveDidFailNotification object:self.defaultObserver];
        
        
        // Handle access rights change events
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsChange:)
                                   name:kPNClientAccessRightsChangeDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsChange:)
                                   name:kPNClientAccessRightsChangeDidFailNotification object:self.defaultObserver];
        
        
        // Handle access rights audit events
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsRequest:)
                                   name:kPNClientAccessRightsAuditDidCompleteNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientChannelAccessRightsRequest:)
                                   name:kPNClientAccessRightsAuditDidFailNotification object:self.defaultObserver];
        
        
        // Handle time token events
        [notificationCenter addObserver:self selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidReceiveTimeTokenNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidFailTimeTokenReceiveNotification object:self.defaultObserver];
        
        
        // Handle message processing events
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientWillSendMessageNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientDidSendMessageNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientMessageSendingDidFailNotification object:self.defaultObserver];
        
        // Handle messages/presence event arrival
        [notificationCenter addObserver:self selector:@selector(handleClientDidReceiveMessage:)
                                   name:kPNClientDidReceiveMessageNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientDidReceivePresenceEvent:)
                                   name:kPNClientDidReceivePresenceEventNotification object:self.defaultObserver];
        
        // Handle message history events arrival
        [notificationCenter addObserver:self selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientDidReceiveMessagesHistoryNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientHistoryDownloadFailedWithErrorNotification object:self.defaultObserver];
        
        // Handle participants list arrival
        [notificationCenter addObserver:self selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientDidReceiveParticipantsListNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientParticipantsListDownloadFailedWithErrorNotification
                                 object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientWhereNowProcess:)
                                   name:kPNClientDidReceiveParticipantChannelsListNotification object:self.defaultObserver];
        [notificationCenter addObserver:self selector:@selector(handleClientWhereNowProcess:)
                                   name:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification
                                 object:self.defaultObserver];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }
    
    
    return self;
}

- (BOOL)isSubscribedOnClientStateChange:(id)observer {
<<<<<<< HEAD

    NSMutableArray *observersData = [self oneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
    NSArray *observers = [observersData valueForKey:PNObservationObserverData.observer];


    return [observers containsObject:observer];
}

- (void)removeOneTimeObserversForEvent:(NSString *)eventName {

    [self.oneTimeObservers removeObjectForKey:eventName];
=======
    
    __block BOOL isSubscribedOnClientStateChange = NO;

    [self pn_dispatchSynchronouslyBlock:^{
        
        NSMutableArray *observersData = [self oneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
        NSArray *observers = [observersData valueForKey:PNObservationObserverData.observer];
        
        isSubscribedOnClientStateChange = [observers containsObject:observer];
    }];


    return isSubscribedOnClientStateChange;
}

- (void)removeOneTimeObserversForEvent:(NSString *)eventName {
    
    [self pn_dispatchAsynchronouslyBlock:^{

        [self.oneTimeObservers removeObjectForKey:eventName];
    }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block {

<<<<<<< HEAD
    NSMutableDictionary *observerData = [@{PNObservationObserverData.observer:observer,
                              PNObservationObserverData.observerCallbackBlock:block} mutableCopy];

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    [observers addObject:observerData];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent {

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    // Retrieve list of observing requests with specified observer
    NSString *filterFormat = [NSString stringWithFormat:@"%@ = %%@", PNObservationObserverData.observer];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, observer];

    NSArray *filteredObservers = [observers filteredArrayUsingPredicate:filterPredicate];

    
    if ([filteredObservers count] > 0) {

        // Removing first occurrence of observer request in list
        [observers removeObject:[filteredObservers objectAtIndex:0]];
    }
=======
    [self pn_dispatchAsynchronouslyBlock:^{
        
        id blockCopy = [block copy];
        NSMutableDictionary *observerData = [@{PNObservationObserverData.observer:observer,
                                               PNObservationObserverData.observerCallbackBlock:blockCopy} mutableCopy];
        
        // Retrieve reference on list of observers for specific event
        SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);
        
        // Turn off error warning on performSelector, because ARC
        // can't understand what is goingon there
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
        #pragma clang diagnostic pop
        
        [observers addObject:observerData];
    }];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent {
    
    [self pn_dispatchAsynchronouslyBlock:^{

        // Retrieve reference on list of observers for specific event
        SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

        // Turn off error warning on performSelector, because ARC
        // can't understand what is goingon there
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
        #pragma clang diagnostic pop

        // Retrieve list of observing requests with specified observer
        NSString *filterFormat = [NSString stringWithFormat:@"%@ = %%@", PNObservationObserverData.observer];
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, observer];

        NSArray *filteredObservers = [observers filteredArrayUsingPredicate:filterPredicate];

        
        if ([filteredObservers count] > 0) {

            // Removing first occurrence of observer request in list
            [observers removeObject:[filteredObservers objectAtIndex:0]];
        }
    }];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Client connection state observation

- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addClientConnectionStateObserver:observer oneTimeEvent:NO withCallbackBlock:callbackBlock];
}

- (void)removeClientConnectionStateObserver:(id)observer {

    [self removeClientConnectionStateObserver:observer oneTimeEvent:NO];
}

<<<<<<< HEAD
- (void)addClientConnectionStateObserver:(id)observer
                            oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientConnectionStateChange
         oneTimeEvent:isOneTimeEventObserver
            withBlock:callbackBlock];
=======
- (void)addClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange
         oneTimeEvent:isOneTimeEventObserver withBlock:callbackBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

}

- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientConnectionStateChange
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:isOneTimeEventObserver];
}


#pragma mark - Client state retrieval / update observation

- (void)addClientMetadataRequestObserver:(id)observer withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock {

    [self addClientStateRequestObserver:observer withBlock:handleBlock];
}

- (void)addClientStateRequestObserver:(id)observer withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:NO withBlock:handleBlock];
}

- (void)removeClientMetadataRequestObserver:(id)observer {

    [self removeClientStateRequestObserver:observer];
}

- (void)removeClientStateRequestObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:NO];
}

- (void)addClientMetadataUpdateObserver:(id)observer withBlock:(PNClientStateUpdateHandlingBlock)handleBlock {

    [self addClientStateUpdateObserver:observer withBlock:handleBlock];
}

- (void)addClientStateUpdateObserver:(id)observer withBlock:(PNClientStateUpdateHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:NO withBlock:handleBlock];
}

- (void)removeClientMetadataUpdateObserver:(id)observer {

    [self removeClientStateUpdateObserver:observer];
}

- (void)removeClientStateUpdateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:NO];
}

- (void)addClientAsStateRequestObserverWithBlock:(PNClientStateRetrieveHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance] forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientAsStateRequestObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance] forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:YES];
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientMetadataRetrieval oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsStateUpdateObserverWithBlock:(PNClientStateUpdateHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance] forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientAsStateUpdateObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance] forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:YES];
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientMetadataUpdate oneTimeEvent:YES];
}


#pragma mark - Client channel groups observation

- (void)addClientAsChannelGroupsRequestObserverWithCallbackBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupsRequest oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelGroupsRequestObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupsRequest oneTimeEvent:YES];
}

- (void)addChannelGroupsRequestObserver:(id)observer
                      withCallbackBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupsRequest oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelGroupsRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupsRequest oneTimeEvent:NO];
}

- (void)addClientAsChannelGroupNamespacesRequestObserverWithCallbackBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelGroupNamespacesRequestObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest oneTimeEvent:YES];
}

- (void)addChannelGroupNamespacesRequestObserver:(id)observer
                               withCallbackBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelGroupNamespacesRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest oneTimeEvent:NO];
}

- (void)addClientAsChannelGroupNamespaceRemovalObserverWithCallbackBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelGroupNamespaceRemovalObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval oneTimeEvent:YES];
}

- (void)addChannelGroupNamespaceRemovalObserver:(id)observer
                              withCallbackBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelGroupNamespaceRemovalObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval oneTimeEvent:NO];
}

- (void)addClientAsChannelGroupRemovalObserverWithCallbackBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupRemoval oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelGroupRemovalObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupRemoval oneTimeEvent:YES];
}

- (void)addChannelGroupRemovalObserver:(id)observer
                     withCallbackBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupRemoval oneTimeEvent:NO
            withBlock:callbackBlock];
    
}

- (void)removeChannelGroupRemovalObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupRemoval oneTimeEvent:NO];
}

- (void)addClientAsChannelsForGroupRequestObserverWithCallbackBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsForGroupRequest oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelsForGroupRequestObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsForGroupRequest oneTimeEvent:YES];
}

- (void)addChannelsForGroupRequestObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsForGroupRequest oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelsForGroupRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsForGroupRequest oneTimeEvent:NO];
}

- (void)addClientAsChannelsAdditionToGroupObserverWithCallbackBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsAdditionToGroup oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelsAdditionToGroupObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsAdditionToGroup oneTimeEvent:YES];
}

- (void)addChannelsAdditionToGroupObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsAdditionToGroup oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelsAdditionToGroupObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsAdditionToGroup oneTimeEvent:NO];
}

- (void)addClientAsChannelsRemovalFromGroupObserverWithCallbackBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock {
    
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsRemovalFromGroup oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsChannelsRemovalFromGroupObserver {
    
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelsRemovalFromGroup oneTimeEvent:YES];
}

- (void)addChannelsRemovalFromGroupObserver:(id)observer
                          withCallbackBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsRemovalFromGroup oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeChannelsRemovalFromGroupObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsRemovalFromGroup oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Client channels action/event observation

- (void)addClientChannelSubscriptionStateObserver:(id)observer

                           withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:callbackBlock];
}

- (void)removeClientChannelSubscriptionStateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:NO];
}

- (void)addClientChannelUnsubscriptionObserver:(id)observer
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:callbackBlock];
}

- (void)removeClientChannelUnsubscriptionObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:NO];
}


#pragma mark - Subscription observation

- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientAsSubscriptionObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientSubscriptionOnChannels
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientSubscriptionOnChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientAsUnsubscribeObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientUnsubscribeFromChannels
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientUnsubscribeFromChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}


#pragma mark - Channels presence enable/disable observers

- (void)addClientAsPresenceEnablingObserverWithBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPresenceEnableOnChannels
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPresenceEnableOnChannels oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientAsPresenceEnabling {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPresenceEnableOnChannels
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPresenceEnableOnChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientAsPresenceDisablingObserverWithBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPresenceDisableOnChannels
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPresenceDisableOnChannels oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientAsPresenceDisabling {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPresenceDisableOnChannels
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPresenceDisableOnChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientPresenceEnablingObserver:(id)observer withCallbackBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPresenceEnableOnChannels
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPresenceEnableOnChannels oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientPresenceEnablingObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPresenceEnableOnChannels
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPresenceEnableOnChannels oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientPresenceDisablingObserver:(id)observer withCallbackBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPresenceDisableOnChannels
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPresenceDisableOnChannels oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientPresenceDisablingObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPresenceDisableOnChannels
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPresenceDisableOnChannels oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - APNS interaction observation

- (void)addClientAsPushNotificationsEnableObserverWithBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationEnabling
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationEnabling oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsEnableObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationEnabling
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationEnabling
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsEnableObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationEnabling
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabling oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsEnableObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationEnabling
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabling oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsPushNotificationsDisableObserverWithBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationDisabling
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationDisabling oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsDisableObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationDisabling
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationDisabling
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsDisableObserver:(id)observer
                                withCallbackBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationDisabling
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationDisabling oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsDisableObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationDisabling
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationDisabling oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsPushNotificationsEnabledChannelsObserverWithBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:YES
            withBlock:handlerBlock];
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:YES withBlock:handlerBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeClientAsPushNotificationsEnabledChannelsObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsEnabledChannelsObserver:(id)observer
                                        withCallbackBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:NO
            withBlock:handlerBlock];
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:NO withBlock:handlerBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeClientPushNotificationsEnabledChannelsObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:NO];
}

- (void)addClientAsPushNotificationsRemoveObserverWithBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:YES
            withBlock:handlerBlock];
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:YES withBlock:handlerBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeClientAsPushNotificationsRemoveObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsRemoveObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:NO
            withBlock:handlerBlock];
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:NO withBlock:handlerBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeClientPushNotificationsRemoveObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:NO];
}


#pragma mark - Time token observation

- (void)addClientAsTimeTokenReceivingObserverWithCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:YES
            withBlock:callbackBlock];
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:YES withBlock:callbackBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeClientAsTimeTokenReceivingObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addTimeTokenReceivingObserver:(id)observer
                    withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:NO
            withBlock:callbackBlock];
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:NO withBlock:callbackBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeTimeTokenReceivingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete oneTimeEvent:NO];
}


#pragma mark - Message sending observers

- (void)addClientAsMessageProcessingObserverWithBlock:(PNClientMessageProcessingBlock)handleBlock {

<<<<<<< HEAD
    [self addMessageProcessingObserver:[PubNub sharedInstance] withBlock:handleBlock oneTimeEvent:YES];
=======
    [self addMessageProcessingObserver:self.defaultObserver withBlock:handleBlock oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

}
- (void)removeClientAsMessageProcessingObserver {

<<<<<<< HEAD
    [self removeMessageProcessingObserver:[PubNub sharedInstance] oneTimeEvent:YES];
=======
    [self removeMessageProcessingObserver:self.defaultObserver oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addMessageProcessingObserver:observer withBlock:handleBlock oneTimeEvent:NO];
}

- (void)removeMessageProcessingObserver:(id)observer {

    [self removeMessageProcessingObserver:observer oneTimeEvent:NO];
}

<<<<<<< HEAD
- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:isOneTimeEventObserver
            withBlock:handleBlock];
=======
- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self addObserver:observer forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:isOneTimeEventObserver withBlock:handleBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeMessageProcessingObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientMessageSendCompletion
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientMessageSendCompletion
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:isOneTimeEventObserver];
}

- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedMessage
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedMessage oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeMessageReceiveObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedMessage
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedMessage oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Presence observing

- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedPresenceEvent
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedPresenceEvent oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removePresenceEventObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedPresenceEvent
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedPresenceEvent oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - History observers

- (void)addClientAsHistoryDownloadObserverWithBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientReceivedHistory oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientAsHistoryDownloadObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:YES];
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientReceivedHistory oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:NO
            withBlock:handleBlock];
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedHistory oneTimeEvent:NO withBlock:handleBlock];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)removeMessageHistoryProcessingObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedHistory oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - PAM observer

- (void)addClientAsAccessRightsChangeObserverWithBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientAccessRightsChange
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsChange oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeClientAsAccessRightsChangeObserver {
    
<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientAccessRightsChange
            oneTimeEvent:YES];
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsChange oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addAccessRightsChangeObserver:(id)observer withBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientAccessRightsChange
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientAccessRightsChange oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}
- (void)removeAccessRightsObserver:(id)observer {
    
<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientAccessRightsChange
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientAccessRightsChange oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsAccessRightsAuditObserverWithBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientAccessRightsAudit
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsAudit oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
    
}

- (void)removeClientAsAccessRightsAuditObserver {
    
<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientAccessRightsAudit
            oneTimeEvent:YES];
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsAudit oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addAccessRightsAuditObserver:(id)observer withBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientAccessRightsAudit
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientAccessRightsAudit oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handlerBlock];
}

- (void)removeAccessRightsAuditObserver:(id)observer {
    
<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientAccessRightsAudit
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientAccessRightsAudit oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Participants observer

- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedParticipantsList oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeChannelParticipantsListProcessingObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedParticipantsList oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsParticipantsListDownloadObserverWithBlock:(PNClientParticipantsHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:YES
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientReceivedParticipantsList oneTimeEvent:YES
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];

}

- (void)removeClientAsParticipantsListDownloadObserver {

<<<<<<< HEAD
    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedParticipantsList
=======
    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientReceivedParticipantsList
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            oneTimeEvent:YES];
}

- (void)addClientParticipantChannelsListDownloadObserver:(id)observer
                                               withBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:observer
             forEvent:PNObservationEvents.clientParticipantChannelsList
         oneTimeEvent:NO
=======
    [self addObserver:observer forEvent:PNObservationEvents.clientParticipantChannelsList oneTimeEvent:NO
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
            withBlock:handleBlock];
}

- (void)removeClientParticipantChannelsListDownloadObserver:(id)observer {

<<<<<<< HEAD
    [self removeObserver:observer
                forEvent:PNObservationEvents.clientParticipantChannelsList
            oneTimeEvent:NO];
=======
    [self removeObserver:observer forEvent:PNObservationEvents.clientParticipantChannelsList oneTimeEvent:NO];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)addClientAsParticipantChannelsListDownloadObserverWithBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

<<<<<<< HEAD
    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientParticipantChannelsList
         oneTimeEvent:YES
            withBlock:handleBlock];
}
- (void)removeClientAsParticipantChannelsListDownloadObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientParticipantChannelsList
            oneTimeEvent:YES];
=======
    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientParticipantChannelsList oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsParticipantChannelsListDownloadObserver {

    [self removeObserver:self.defaultObserver forEvent:PNObservationEvents.clientParticipantChannelsList oneTimeEvent:YES];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    
    // Default field values
    BOOL connected = YES;
    PNError *connectionError = nil;
<<<<<<< HEAD
    NSString *origin = [PubNub sharedInstance].configuration.origin;
=======
    NSString *origin = nil;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    
    if([notification.name isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notification.name isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {
        
        origin = (NSString *)notification.userInfo;
        connected = [notification.name isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notification.name isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {
        
        connected = NO;
        connectionError = (PNError *)notification.userInfo;
<<<<<<< HEAD
=======
        origin = (NSString *)connectionError.associatedObject;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientConnectionStateChange];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
<<<<<<< HEAD
    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientConnectionStateChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(origin, connected, connectionError);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientConnectionStateChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(origin, connected, connectionError);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientMetadataRetrieveProcess:(NSNotification *)notification {

    PNError *error = nil;
    PNClient *client = nil;
    if ([[notification name] isEqualToString:kPNClientDidReceiveClientStateNotification]) {

        client = (PNClient *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        client = (PNClient *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientMetadataRetrieval];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientMetadataRetrieval];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientStateRetrieveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(client, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientStateRetrieveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(client, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientMetadataUpdateProcess:(NSNotification *)notification {

    PNError *error = nil;
    PNClient *client = nil;
    if ([[notification name] isEqualToString:kPNClientDidUpdateClientStateNotification]) {

        client = (PNClient *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        client = (PNClient *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientMetadataUpdate];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientMetadataUpdate];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientStateUpdateHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(client, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientStateUpdateHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(client, error);
            }
        }];
    });
}

- (void)handleClientChannelGroupsRequestProcess:(NSNotification *)notification {
    
    NSArray *groups = nil;
    NSString *namespaceName = nil;
    PNError *error = nil;
    
    // Check whether arrived notification that channel groups retrieved or not
    if ([notification.name isEqualToString:kPNClientChannelGroupsRequestCompleteNotification]) {
        
        if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
            
            namespaceName = [[(NSDictionary *)notification.userInfo allKeys] lastObject];
            if (namespaceName) {
                
                groups = [(NSDictionary *)notification.userInfo valueForKey:namespaceName];
            }
        }
        else {
            
            groups = (NSArray *)notification.userInfo;
        }
    }
    else {
        
        error = (PNError *)notification.userInfo;
        namespaceName = error.associatedObject;
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientChannelGroupsRequest];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupsRequest];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientChannelGroupsRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(namespaceName, groups, error);
            }
        }];
    });
}

- (void)handleClientChannelGroupNamespacesRequestProcess:(NSNotification *)notification {
    
    NSArray *namespaces = nil;
    PNError *error = nil;
    
    // Check whether arrived notification that channel group namespaces retrieved or not
    if ([notification.name isEqualToString:kPNClientChannelGroupNamespacesRequestCompleteNotification]) {
        
        namespaces = (NSArray *)notification.userInfo;
    }
    else {
        
        error = (PNError *)notification.userInfo;
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientChannelGroupNamespacesRequest];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupNamespacesRequest];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientChannelGroupNamespacesRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(namespaces, error);
            }
        }];
    });
}

- (void)handleClientChannelGroupNamespacesRemovalProcess:(NSNotification *)notification {
    
    NSString *namespace = nil;
    PNError *error = nil;
    
    // Check whether arrived notification that channel group namespace removed or not
    if ([notification.name isEqualToString:kPNClientChannelGroupNamespaceRemovalCompleteNotification]) {
        
        namespace = (NSString *)notification.userInfo;
    }
    else {
        
        error = (PNError *)notification.userInfo;
        namespace = error.associatedObject;
        if ([namespace isKindOfClass:[NSArray class]]) {
            
            namespace = [(NSArray *)namespace lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientChannelGroupNamespaceRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(namespace, error);
            }
        }];
    });
}

- (void)handleClientChannelGroupRemovalProcess:(NSNotification *)notification {
    
    PNChannelGroup *group = nil;
    PNError *error = nil;
    
    // Check whether arrived notification that channel group removed or not
    if ([notification.name isEqualToString:kPNClientChannelGroupRemovalCompleteNotification]) {
        
        group = (PNChannelGroup *)notification.userInfo;
    }
    else {
        
        error = (PNError *)notification.userInfo;
        group = error.associatedObject;
        if ([group isKindOfClass:[NSArray class]]) {
            
            group = [(NSArray *)group lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientChannelGroupRemoval];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupRemoval];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientChannelGroupRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(group, error);
            }
        }];
    });
}

- (void)handleClientChannelsForGroupRequestProcess:(NSNotification *)notification {
    
    PNChannelGroup *group = nil;
    PNError *error = nil;
    
    // Check whether arrived notification that channels list for group retrieved or not
    if ([notification.name isEqualToString:kPNClientChannelsForGroupRequestCompleteNotification]) {
        
        group = (PNChannelGroup *)notification.userInfo;
    }
    else {
        
        error = (PNError *)notification.userInfo;
        group = (PNChannelGroup *)error.associatedObject;
        if ([group isKindOfClass:[NSArray class]]) {
            
            group = [(NSArray *)group lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientChannelsForGroupRequest];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelsForGroupRequest];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Call handling blocks
            PNClientChannelsForGroupRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                block(group, error);
            }
        }];
    });
}

- (void)handleClientGroupChannelsListModificationProcess:(NSNotification *)notification {
    
    PNChannelGroupChange *change = nil;
    BOOL addingChannels = YES;
    PNError *error = nil;
    
    NSString *eventName = PNObservationEvents.clientChannelsAdditionToGroup;
    if ([notification.name isEqualToString:kPNClientGroupChannelsRemovalCompleteNotification] ||
        [notification.name isEqualToString:kPNClientGroupChannelsRemovalDidFailWithErrorNotification]) {
        
        addingChannels = NO;
        eventName = PNObservationEvents.clientChannelsRemovalFromGroup;
    }
    if ([notification.name isEqualToString:kPNClientGroupChannelsAdditionCompleteNotification] ||
        [notification.name isEqualToString:kPNClientGroupChannelsRemovalCompleteNotification]) {
        
        change = (PNChannelGroupChange *)notification.userInfo;
    }
    else {
        
        error = (PNError *)notification.userInfo;
        change = error.associatedObject;
    }
    
    
    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:eventName];
    
    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:eventName];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {
            
            // Receive reference on handling block
            id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {
                
                if (addingChannels) {
                    
                    ((PNClientChannelsAdditionToGroupHandlingBlock)block)(change.group, change.channels, error);
                }
                else {
                    
                    ((PNClientChannelsRemovalFromGroupHandlingBlock)block)(change.group, change.channels, error);
                }
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;

    // Check whether arrived notification that subscription failed or not
    if ([notification.name isEqualToString:kPNClientSubscriptionDidFailNotification] ||
        [notification.name isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {

        error = (PNError *)notification.userInfo;
        channels = error.associatedObject;
    }
    else {

        // Retrieve list of channels on which event is occurred
        channels = (NSArray *)notification.userInfo;
        state = PNSubscriptionProcessSubscribedState;

        // Check whether arrived notification that subscription will be restored
        if ([notification.name isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {

            state = PNSubscriptionProcessWillRestoreState;
        }
        // Check whether arrived notification that subscription restored
        else if ([notification.name isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {

            state = PNSubscriptionProcessRestoredState;
        }
    }


    // Retrieving list of observers (including one time and persistent observers)
    __block NSArray *observers = [self observersForEvent:PNObservationEvents.clientSubscriptionOnChannels];
    if ([notification.name isEqualToString:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification] ||
        [notification.name isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {

        NSArray *oneTimeEventObservers = [self oneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels];
        if ([oneTimeEventObservers count]) {

            [oneTimeEventObservers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

<<<<<<< HEAD
                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:[PubNub sharedInstance]]) {
=======
                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:self.defaultObserver]) {
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

                    observers = @[observerData];
                    [self removeObserver:[observerData valueForKey:PNObservationObserverData.observer]
                                forEvent:PNObservationEvents.clientSubscriptionOnChannels
                            oneTimeEvent:YES];
                    *observerDataEnumeratorStop = YES;
                }
            }];
        }
    }
    else {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels];
    }
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelSubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientChannelSubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(state, channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientUnsubscriptionDidCompleteNotification] ||
        [notification.name isEqualToString:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    __block NSArray *observers = [self observersForEvent:PNObservationEvents.clientUnsubscribeFromChannels];
    if ([notification.name isEqualToString:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification] ||
        [notification.name isEqualToString:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification]) {

        NSArray *oneTimeEventObservers = [self oneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels];
        if ([oneTimeEventObservers count]) {

<<<<<<< HEAD
            [oneTimeEventObservers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                                NSUInteger observerDataIdx,
                                                                BOOL *observerDataEnumeratorStop) {

                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:[PubNub sharedInstance]]) {
=======
            [oneTimeEventObservers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                                BOOL *observerDataEnumeratorStop) {

                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:self.defaultObserver]) {
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

                    observers = @[observerData];
                    [self removeObserver:[observerData valueForKey:PNObservationObserverData.observer]
                                forEvent:PNObservationEvents.clientUnsubscribeFromChannels
                            oneTimeEvent:YES];
                    *observerDataEnumeratorStop = YES;
                }
            }];
        }
    }
    else {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels];
    }
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelUnsubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientChannelUnsubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPresenceEnablingDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPresenceEnableOnChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceEnableOnChannels];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceEnableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientPresenceEnableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPresenceDisablingDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPresenceDisableOnChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceDisableOnChannels];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceDisableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientPresenceDisableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientPushNotificationStateChange:(NSNotification *)notification {

    BOOL isEnablingPushNotifications = YES;
    NSString *eventName = PNObservationEvents.clientPushNotificationEnabling;
<<<<<<< HEAD
    if ([notification.name isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification]) {
=======
    if ([notification.name isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification] ||
        [notification.name isEqualToString:kPNClientPushNotificationDisableDidFailNotification]) {
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

        isEnablingPushNotifications = NO;
        eventName = PNObservationEvents.clientPushNotificationDisabling;
    }
    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPushNotificationEnableDidCompleteNotification] ||
        [notification.name isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = error.associatedObject;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:eventName];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:eventName];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            if (isEnablingPushNotifications) {

                ((PNClientPushNotificationsEnableHandlingBlock)block)(channels, error);
            }
            else {

                ((PNClientPushNotificationsDisableHandlingBlock)block)(channels, error);
            }
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Receive reference on handling block
            id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                if (isEnablingPushNotifications) {

                    ((PNClientPushNotificationsEnableHandlingBlock)block)(channels, error);
                }
                else {

                    ((PNClientPushNotificationsDisableHandlingBlock)block)(channels, error);
                }
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification {

    PNError *error = nil;
    if (![notification.name isEqualToString:kPNClientPushNotificationRemoveDidCompleteNotification]) {

        error = (PNError *)notification.userInfo;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        PNClientPushNotificationsRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Receive reference on handling block
            PNClientPushNotificationsRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        PNClientPushNotificationsEnabledChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Receive reference on handling block
            PNClientPushNotificationsEnabledChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification {

    PNMessageState state = PNMessageSending;
    id processingData = nil;
    BOOL shouldUnsubscribe = NO;
    if ([notification.name isEqualToString:kPNClientMessageSendingDidFailNotification]) {

        state = PNMessageSendingError;
        shouldUnsubscribe = YES;
        processingData = (PNError *)notification.userInfo;
    }
    else {

        shouldUnsubscribe = [notification.name isEqualToString:kPNClientDidSendMessageNotification];
        if (shouldUnsubscribe) {

            state = PNMessageSent;
        }
        processingData = (PNMessage *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientMessageSendCompletion];

    if (shouldUnsubscribe) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientMessageSendCompletion];
    }
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageProcessingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, processingData);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientMessageProcessingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(state, processingData);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {

    // Retrieve reference on message which was received
    PNMessage *message = (PNMessage *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedMessage];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(message);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientMessageHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(message);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {

    // Retrieve reference on presence event which was received
    PNPresenceEvent *presenceEvent = (PNPresenceEvent *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedPresenceEvent];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceEventHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(presenceEvent);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientPresenceEventHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(presenceEvent);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientMessageHistoryProcess:(NSNotification *)notification {

    // Retrieve reference on history object
    PNMessagesHistory *history = nil;
    PNChannel *channel = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveMessagesHistoryNotification]) {

        history = (PNMessagesHistory *)notification.userInfo;
        channel = ([history.channel isKindOfClass:[NSArray class]] ? [(NSArray *)history.channel lastObject] : history.channel);
    }
    else {

        error = (PNError *)notification.userInfo;
        channel = ([error.associatedObject isKindOfClass:[NSArray class]] ? [(NSArray *)error.associatedObject lastObject] : error.associatedObject);
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedHistory];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedHistory];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientHistoryLoadHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(history.messages, channel, history.startDate, history.endDate, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientHistoryLoadHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(history.messages, channel, history.startDate, history.endDate, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientChannelAccessRightsChange:(NSNotification *)notification {

    PNAccessRightsCollection *collection = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientAccessRightsChangeDidCompleteNotification]) {

        collection = (PNAccessRightsCollection *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientAccessRightsChange];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientAccessRightsChange];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelAccessRightsChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(collection, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientChannelAccessRightsChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(collection, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientChannelAccessRightsRequest:(NSNotification *)notification {

    PNAccessRightsCollection *collection = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientAccessRightsAuditDidCompleteNotification]) {

        collection = (PNAccessRightsCollection *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientAccessRightsAudit];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientAccessRightsAudit];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelAccessRightsAuditBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(collection, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientChannelAccessRightsAuditBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(collection, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientHereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNHereNow *participants = nil;
<<<<<<< HEAD
    PNChannel *channel = nil;
=======
    NSArray *channels = nil;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveParticipantsListNotification]) {

        participants = (PNHereNow *)notification.userInfo;
<<<<<<< HEAD
        channel = ([participants.channel isKindOfClass:[NSArray class]] ? [(NSArray *)participants.channel lastObject] : participants.channel);
=======
        channels = [participants channels];
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }
    else {

        error = (PNError *)notification.userInfo;
<<<<<<< HEAD
        channel = ([error.associatedObject isKindOfClass:[NSArray class]] ? [(NSArray *)error.associatedObject lastObject] : error.associatedObject);
=======
        channels = error.associatedObject;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedParticipantsList];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedParticipantsList];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientParticipantsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(participants.participants, channel, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientParticipantsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(participants, channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientWhereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNWhereNow *channelsList = nil;
    NSString *identifier = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveParticipantChannelsListNotification]) {

        channelsList = (PNWhereNow *)notification.userInfo;
        identifier = channelsList.identifier;
    }
    else {

        error = (PNError *)notification.userInfo;
        identifier = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientParticipantChannelsList];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientParticipantChannelsList];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientParticipantChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(identifier, channelsList.channels, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientParticipantChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(identifier, channelsList.channels, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification {

    PNError *error = nil;
    NSNumber *timeToken = nil;
    if ([[notification name] isEqualToString:kPNClientDidReceiveTimeTokenNotification]) {

        timeToken = (NSNumber *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];
<<<<<<< HEAD

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientTimeTokenReceivingCompleteBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(timeToken, error);
        }
    }];
=======
    dispatch_async(dispatch_get_main_queue(), ^{

        [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData, NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

            // Call handling blocks
            PNClientTimeTokenReceivingCompleteBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
            if (block) {

                block(timeToken, error);
            }
        }];
    });
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}


#pragma mark - Misc methods

- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName {

<<<<<<< HEAD
    if ([self.observers valueForKey:eventName] == nil) {
        
        [self.observers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.observers valueForKey:eventName];
=======
    __block NSMutableArray *persistentObserversForEvent = nil;
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        if ([self.observers valueForKey:eventName] == nil) {
            
            [self.observers setValue:[NSMutableArray array] forKey:eventName];
        }
        
        persistentObserversForEvent = [self.observers valueForKey:eventName];
    }];
    
    
    return persistentObserversForEvent;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName {
    
<<<<<<< HEAD
    if ([self.oneTimeObservers valueForKey:eventName] == nil) {
        
        [self.oneTimeObservers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.oneTimeObservers valueForKey:eventName];
=======
    __block NSMutableArray *oneTimeObserversForEvent = nil;
    
    [self pn_dispatchSynchronouslyBlock:^{
        
        if ([self.oneTimeObservers valueForKey:eventName] == nil) {
            
            [self.oneTimeObservers setValue:[NSMutableArray array] forKey:eventName];
        }
        
        oneTimeObserversForEvent = [self.oneTimeObservers valueForKey:eventName];
    }];
    
    
    return oneTimeObserversForEvent;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
}

- (NSMutableArray *)observersForEvent:(NSString *)eventName {

    NSMutableArray *persistentObservers = [self persistentObserversForEvent:eventName];
    NSMutableArray *oneTimeEventObservers = [self oneTimeObserversForEvent:eventName];


    // Composing full observers list depending on whether at least
    // one object exist in retrieved arrays
    NSMutableArray *allObservers = [NSMutableArray array];
    if ([persistentObservers count] > 0) {

        [allObservers addObjectsFromArray:persistentObservers];
    }

    if ([oneTimeEventObservers count] > 0) {

        [allObservers addObjectsFromArray:oneTimeEventObservers];
    }


    return allObservers;
}


#pragma mark - Memory management

- (void)dealloc {

    // Unsubscribe from all notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
<<<<<<< HEAD
    [notificationCenter removeObserver:self name:kPNClientDidConnectToOriginNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidDisconnectFromOriginNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientConnectionDidFailWithErrorNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveClientStateNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientStateRetrieveDidFailWithErrorNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidUpdateClientStateNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientStateUpdateDidFailWithErrorNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionWillRestoreNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidRestoreNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientPushNotificationEnableDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationEnableDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationDisableDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationDisableDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationRemoveDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationRemoveDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationChannelsRetrieveDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientAccessRightsChangeDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsChangeDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsAuditDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsAuditDidFailNotification object:nil];


    [notificationCenter removeObserver:self name:kPNClientDidReceiveTimeTokenNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidFailTimeTokenReceiveNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientWillSendMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidSendMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientMessageSendingDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidReceivePresenceEventNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessagesHistoryNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientHistoryDownloadFailedWithErrorNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveParticipantsListNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientParticipantsListDownloadFailedWithErrorNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidReceiveParticipantChannelsListNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification object:nil];
=======
    [notificationCenter removeObserver:self name:kPNClientDidConnectToOriginNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidDisconnectFromOriginNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientConnectionDidFailWithErrorNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveClientStateNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientStateRetrieveDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidUpdateClientStateNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientStateUpdateDidFailWithErrorNotification object:_defaultObserver];
    
    [notificationCenter removeObserver:self name:kPNClientChannelGroupsRequestCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupsRequestDidFailWithErrorNotification object:_defaultObserver];
    
    
    [notificationCenter removeObserver:self name:kPNClientChannelGroupNamespacesRequestCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupNamespaceRemovalCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelsForGroupRequestCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientGroupChannelsAdditionCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientGroupChannelsRemovalCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification object:_defaultObserver];
    
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification
                                object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionWillRestoreNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidRestoreNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification
                                object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification
                                object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification
                                object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidFailNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientPushNotificationEnableDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationEnableDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationDisableDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationDisableDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationRemoveDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationRemoveDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
                                object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientPushNotificationChannelsRetrieveDidFailNotification
                                object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientAccessRightsChangeDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsChangeDidFailNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsAuditDidCompleteNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientAccessRightsAuditDidFailNotification object:_defaultObserver];


    [notificationCenter removeObserver:self name:kPNClientDidReceiveTimeTokenNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidFailTimeTokenReceiveNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientWillSendMessageNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidSendMessageNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientMessageSendingDidFailNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessageNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidReceivePresenceEventNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessagesHistoryNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientHistoryDownloadFailedWithErrorNotification object:_defaultObserver];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveParticipantsListNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientParticipantsListDownloadFailedWithErrorNotification
                                object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientDidReceiveParticipantChannelsListNotification object:_defaultObserver];
    [notificationCenter removeObserver:self name:kPNClientParticipantChannelsListDownloadFailedWithErrorNotification
                                object:_defaultObserver];
    
    _defaultObserver = nil;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.observationCenter.destroyed];
    }];
}

#pragma mark -


@end
