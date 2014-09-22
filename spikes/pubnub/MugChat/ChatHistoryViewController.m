//
//  ChatHistoryViewController.m
//  MugChat
//
//  Created by Diego Santiviago on 9/16/14.
//  Copyright (c) 2014 Diego Santiviago. All rights reserved.
//

#import "ChatHistoryViewController.h"

@interface ChatHistoryViewController ()
@property (strong, nonatomic) IBOutlet UITextView *history;
@property (strong, nonatomic) IBOutlet UITextField *message;
@property (strong, nonatomic) PNChannel *mugboys;

@end

@implementation ChatHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [PubNub setDelegate:self];
    PNConfiguration *configuration = [PNConfiguration
                                      configurationForOrigin:@"pubsub.pubnub.com"
                                      publishKey:@"pub-c-0f705157-1c76-450a-99e9-59342f271f12"
                                      subscribeKey:@"sub-c-8047a8dc-3853-11e4-8736-02ee2ddab7fe"
                                      secretKey:nil];
    
    [PubNub setConfiguration:configuration];
    [PubNub connect];
    self.mugboys = [PNChannel channelWithName:@"$2a$10$Uh7yA063il4uCHwQhG4DBeKk2LtJ6BlwRBocUZr8BZ2AHc1IugA6" shouldObservePresence:YES];
    
    [PubNub subscribeOnChannel:self.mugboys];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self retrieveOfflineMessages];
}

-(void)dismissKeyboard {
    [self.message resignFirstResponder];
    [self.history resignFirstResponder];
}

- (IBAction)sendMessageTapped:(id)sender {
    NSMutableDictionary *message = [NSMutableDictionary new];
    [message setObject:@"Diego" forKey:@"user"];
    [message setObject:self.message.text forKey:@"text"];
    
    [PubNub sendMessage:message toChannel:self.mugboys];
    self.message.text = @"";
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    self.history.text = [NSString stringWithFormat:@"%@\n%@> %@", self.history.text, message.message[@"user"], message.message[@"text"]];
}

- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel startingFrom:(PNDate *)startDate to:(PNDate *)endDate {
    for (PNMessage *message in messages) {
        self.history.text = [NSString stringWithFormat:@"%@\n%@> %@", self.history.text, message.message[@"user"], message.message[@"text"]];
    }
}

- (void)retrieveOfflineMessages {
    
    NSDateComponents *component = [NSDateComponents new];
    [component setDay:16];
    [component setYear:2014];
    [component setMonth:9];
    [component setHour:11];
    [component setMinute:31];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:component];
    
    [PubNub requestHistoryForChannel:self.mugboys from:[PNDate dateWithDate:date] to:[PNDate dateWithDate:[NSDate new]] includingTimeToken:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
