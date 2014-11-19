//
//  PNConnection.h
//  pubnub
//
//  This is core class for communication over the network with PubNub services.
//  It allow to establish socket connection and organize write packet requests into FIFO queue.
//  
//
//  Created by Sergey Mamontov on 12/10/12.
//
//

#import <Foundation/Foundation.h>
#import "PNConnectionDelegate.h"
#import "PNMacro.h"


<<<<<<< HEAD
=======
#pragma mark Class forward

@class PNConfiguration;


#pragma mark - Public interface declaration

>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
@interface PNConnection : NSObject


#pragma mark Properties

// Reference on object which will provide requests pool for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDataSource> dataSource;

// Stores reference on connection delegate which also will be packet provider for connection
@property (nonatomic, pn_desired_weak) id<PNConnectionDelegate> delegate;


#pragma mark - Class methods

/**
<<<<<<< HEAD
 * Depending on platform will be able to return few connections when on Mac OS and will reuse same connection on iOS
 */
+ (PNConnection *)connectionWithIdentifier:(NSString *)identifier;

/**
 * Closes all streams and remove connection from connections pool to completely free up resources
 */
+ (void)destroyConnection:(PNConnection *)connection;

/**
 * Close all opened connections which is stored inside connections pool for reuse
 */
+ (void)closeAllConnections;
=======
 Depending on platform will be able to return few connections when on Mac OS and will reuse same connection on iOS
 */
+ (PNConnection *)connectionWithConfiguration:(PNConfiguration *)configuration andIdentifier:(NSString *)identifier;
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba


#pragma mark - Instance methods

#pragma mark - Requests queue execution management

/**
<<<<<<< HEAD
 * Inform connection to schedule requests queue processing.
=======
 Inform connection to schedule requests queue processing.
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
 */
- (void)scheduleNextRequestExecution;

/**
<<<<<<< HEAD
 * Inform connection to stop requests queue processing (last active request will be sent)
=======
 Inform connection to stop requests queue processing (last active request will be sent)
>>>>>>> 0176047a5fd5f839466f621bacdb66d9affd19ba
 */
- (void)unscheduleRequestsExecution;


#pragma mark - Connection management

- (BOOL)connect;
- (BOOL)canRetryConnection;
- (void)retryConnection;
- (BOOL)isConnected;

- (void)disconnect;
- (BOOL)isDisconnected;

/**
 * Reconnect sockets and streams by user request
 */
- (void)reconnect;

/**
 * Suspend sockets (basically they will be closed w/o PNConnection instance destroy)
 */
- (void)suspend;
- (BOOL)isSuspended;

/**
 * Restore default sockets functions (sockets connection will be up again)
 */
- (void)resume;

#pragma mark -


@end
