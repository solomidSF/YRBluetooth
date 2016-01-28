//
//  ChatServerViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ServerChatViewController.h"

// Sessions
#import "ServerChatSession.h"

// Events
#import "EventObject.h"
#import "ConnectionEvent.h"
#import "NewMessageEvent.h"

// Entities
#import "ServerUser.h"

// Cells
#import "BaseEventTableCell.h"
#import "InformativeTableCell.h"
#import "MessageTableCell.h"
#import "MyMessageTableCell.h"

@interface ServerChatViewController ()
<
ServerChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ServerChatViewController {
    ServerChatSession *_serverSession;
    NSMutableArray <EventObject *> *_datasource;
    
    id _keyboardObserver;

    __weak IBOutlet UITableView *_messagesTableView;
    __weak IBOutlet UITextField *_messageTextField;
    __weak IBOutlet NSLayoutConstraint *_messageBottomConstraint;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _datasource = [NSMutableArray new];
    
    _messagesTableView.rowHeight = UITableViewAutomaticDimension;
    _messagesTableView.estimatedRowHeight = 50.0f;

    _serverSession = [ServerChatSession sessionWithNickname:self.nickname];
    
    [_serverSession addObserver:self];
    
    // TODO: temp solution
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_serverSession startAdvertising];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __typeof(self) __weak weakSelf = self;
    _keyboardObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf)
        {
            CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            
            CGFloat localY = [[UIApplication sharedApplication].keyWindow convertPoint:keyboardRect.origin toView:strongSelf.view].y;
            
            [UIView animateWithDuration:duration animations:^()
             {
                 strongSelf->_messageBottomConstraint.constant = MIN(0, localY - CGRectGetHeight(strongSelf.view.bounds));
                 
                 [strongSelf.view layoutIfNeeded];
             }];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_keyboardObserver];
}

- (void)dealloc {
    [_serverSession stopAdvertising];
    
    [_serverSession endSession];
}

#pragma mark - Callbacks

- (IBAction)sendClicked:(id)sender {
    [_serverSession sendMessage:_messageTextField.text];
    
    _messageTextField.text = nil;
}

#pragma mark - <UITableViewDelegate/Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventObject *event = _datasource[indexPath.row];
    
    __kindof BaseEventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:event.reuseIdentifier];
    cell.event = event;
    
    return cell;
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session userDidConnect:(ServerUser *)user timestamp:(NSTimeInterval)timestamp {
    ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:_serverSession.chat
                                                              user:user
                                                         eventType:kEventTypeConnected
                                                         timestamp:timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"%@ connected!", user.name];
        notification.soundName = @"ding.mp3";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)chatSession:(ServerChatSession *)session userDidDisconnect:(ServerUser *)user timestamp:(NSTimeInterval)timestamp {
    ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:_serverSession.chat
                                                              user:user
                                                         eventType:kEventTypeDisconnected
                                                         timestamp:timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

- (void)chatSession:(ServerChatSession *)session didReceiveNewMessage:(Message *)message {
    NewMessageEvent *event = [[NewMessageEvent alloc] initWithChat:_serverSession.chat
                                                           message:message
                                                         timestamp:message.timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"New message from %@:\n%@", message.sender.name, message.messageText];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

@end
